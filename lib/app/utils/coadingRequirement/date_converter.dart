// ignore_for_file: non_constant_identifier_names, avoid_print, unnecessary_brace_in_string_interps

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../preference.dart';

class DateConverter {
  static String currentWeekDayInWord() {
    final currentday = DateTime.now().weekday;
    String day = '';
    switch (currentday) {
      case 1:
        {
          day = 'monday';
          break;
        }
      case 2:
        {
          day = 'tuesday';
          break;
        }
      case 3:
        {
          day = 'wednesday';
          break;
        }
      case 4:
        {
          day = 'thursday';
          break;
        }

      case 5:
        {
          day = 'friday';
          break;
        }
      case 6:
        {
          day = 'saturday';
          break;
        }
      case 7:
        {
          day = 'sunday';
          break;
        }
    }
    debugPrint('Current day : $day');
    return day;
  }

  static String getCurrentMonthInWord() {
    final currentMonth = DateTime.now().month;
    final monthFormat = DateFormat.MMMM(
        Preference.languageCode); // Use the specified language code
    final month = monthFormat.format(DateTime(2000, currentMonth));
    debugPrint('Current month : $month');
    return month;
  }

  static String getTomorrowWeekday() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final weekdayFormat = DateFormat('EEEE');
    final tomorrowWeekday = weekdayFormat.format(tomorrow);
    debugPrint('Next day : $tomorrowWeekday');
    return tomorrowWeekday;
  }

  static String dayInWordbyNumber(int dayInNum) {
    List<String> daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    if (dayInNum >= 1 && dayInNum <= 7) {
      return daysOfWeek[dayInNum - 1];
    } else {
      return 'Invalid Day';
    }
  }

  static bool endsWithAMorPM(String input) {
    final regex = RegExp(r'^(.*)(AM|PM)$');
    return regex.hasMatch(input);
  }

  static String timeOfDayTo12Hour(TimeOfDay time) {
    // Format hours
    int hours = time.hourOfPeriod;
    String formattedHours = hours.toString().padLeft(2, '0');

    // Format minutes
    String formattedMinutes = time.minute.toString().padLeft(2, '0');

    // Determine AM or PM
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    // Combine everything
    String formattedTime = '$formattedHours:$formattedMinutes $period';
    print(formattedTime);
    return formattedTime;
  }

  static String serverDateTimeToStringDate(String serverDateTime) {
    try {
      // Parse the server date-time string
      DateTime parsedDateTime = DateTime.parse(serverDateTime);

      // Format the date according to your requirements
      String formattedDate =
          "${parsedDateTime.day}/${parsedDateTime.month}/${parsedDateTime.year}";

      return formattedDate;
    } catch (e) {
      // Handle parsing errors, if any
      print("Error parsing server date-time: $e");
      return "Invalid Date";
    }
  }

  static String DateTimeToNormal(DateTime dateTime) {
    // Format the DateTime to "dd-MMM-yyyy" (e.g., "11-Feb-2023")
    String formattedDate =
        "${dateTime.day}-${getMonthAbbreviation(dateTime.month)}-${dateTime.year}";
    return formattedDate;
  }

  static String getMonthAbbreviation(int month) {
    // Convert month number to month abbreviation
    const List<String> monthAbbreviations = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return monthAbbreviations[month];
  }

  static DateTime dateTimeFromString(String serverDateString) {
    // Assuming the server date string is in "yyyy-MM-dd HH:mm:ss" format
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateTime dateTime = format.parse(serverDateString);
    return dateTime;
  }

  static String serviceCalenderFormat(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMM yyyy')
          .format(dateTime); // Format the date as "Feb 08 2024"
    } catch (e) {
      // Return the original string if parsing fails
      return dateTimeString;
    }
  }

  static String spareOrderFormat(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd-MMM-yyyy')
          .format(dateTime); // Format the date as "Feb-08-2024"
    } catch (e) {
      // Return the original string if parsing fails
      return dateTimeString;
    }
  }

  static String fullDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('dd MMMM yyyy')
        .format(dateTime); // Format the date as "Feb 08 2024"
  }

  static int getDaysInMonth({required int year, required int month}) {
    // To handle leap years, February has 29 days if the year is divisible by 4
    // but not divisible by 100 unless it is also divisible by 400
    if (month == 2) {
      if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
        return 29;
      } else {
        return 28;
      }
    }

    // For other months, simply return the number of days based on the month
    switch (month) {
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      default:
        return 31;
    }
  }

  static String convertToServerFormat(String inputDate) {
    if (inputDate == "") {
      return ""; // Return empty string if input is empty
    }

    // Parse input string into a DateTime object
    DateTime parsedDate = DateFormat('d-MMM-yyyy').parse(inputDate);

    // Format the DateTime object to the desired server format
    String serverDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);

    return serverDateTime;
  }

  static String getTimeAgo(String dateTimeString, String locale) {
    // Parse the given datetime string into a DateTime object
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Get the current DateTime object
    DateTime now = DateTime.now();

    // Calculate the difference between now and the given datetime
    Duration difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return Intl.message('just now', locale: locale);
    } else if (difference.inMinutes < 60) {
      return Intl.plural(
        difference.inMinutes,
        zero: Intl.message('just now', locale: locale),
        one: Intl.message('${difference.inMinutes} minute ago', locale: locale),
        other:
            Intl.message('${difference.inMinutes} minutes ago', locale: locale),
      );
    } else if (difference.inHours < 24) {
      return Intl.plural(
        difference.inHours,
        one: Intl.message('${difference.inHours} hour ago', locale: locale),
        other: Intl.message('${difference.inHours} hours ago', locale: locale),
      );
    } else if (difference.inDays < 7) {
      return Intl.plural(
        difference.inDays,
        one: Intl.message('${difference.inDays} day ago', locale: locale),
        other: Intl.message('${difference.inDays} days ago', locale: locale),
      );
    } else if (difference.inDays < 30) {
      int weeks = (difference.inDays / 7).floor();
      return Intl.plural(
        weeks,
        one: Intl.message('${weeks} week ago', locale: locale),
        other: Intl.message('${weeks} weeks ago', locale: locale),
      );
    } else if (difference.inDays < 365) {
      int months = now.month - dateTime.month + (now.year - dateTime.year) * 12;
      return Intl.plural(
        months,
        one: Intl.message('${months} month ago', locale: locale),
        other: Intl.message('${months} months ago', locale: locale),
      );
    } else {
      int years = (difference.inDays / 365).floor();
      return Intl.plural(
        years,
        one: Intl.message('${years} year ago', locale: locale),
        other: Intl.message('${years} years ago', locale: locale),
      );
    }
  }
}

String extractVideoId(String youtubeLink) {
  // Split the link by '/'
  List<String> parts = youtubeLink.split('/');

  // Get the last part of the URL
  String lastPart = parts.last;

  // Split the last part by '?' to get video ID
  List<String> idParts = lastPart.split('?');

  // Return the video ID with the query parameters

  return "https://www.youtube.com/embed/${idParts.first}";
}
