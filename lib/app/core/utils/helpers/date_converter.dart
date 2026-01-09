// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Global Date/Time Converter
/// Handles timezone-aware conversions and locale-based formatting
/// Works globally with any timezone and locale settings
class DateConverter {
  // ============================================
  // TIMEZONE UTILITIES
  // ============================================

  /// Get current device timezone offset as string (e.g., "+05:30", "-08:00")
  static String getTimezoneOffset() {
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';
    return '$sign$hours:$minutes';
  }

  /// Get timezone name (e.g., "IST", "EST", "PST")
  static String getTimezoneName() {
    return DateTime.now().timeZoneName;
  }

  // ============================================
  // TIME CONVERSION (12hr ↔ 24hr)
  // ============================================

  /// Convert 12-hour format to 24-hour format for API/storage
  /// Input: "5:08 PM", "05:08 PM", "5:08PM"
  /// Output: "17:08:00"
  static String convertTo24Hour(String time) {
    if (time.isEmpty) return "00:00:00";

    // Remove any unwanted characters (non-ASCII)
    String cleanedTime = time.replaceAll(RegExp(r'[^\x00-\x7F]'), '').trim();

    // If already in 24-hour HH:mm:ss format, return as is
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(cleanedTime)) {
      return cleanedTime;
    }

    // If already in 24-hour HH:mm format, add seconds
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(cleanedTime)) {
      return '$cleanedTime:00';
    }

    // Try multiple formats for 12-hour time
    final formats = [
      DateFormat.jm(), // "5:08 PM" (locale-aware)
      DateFormat('h:mm a'), // "5:08 PM"
      DateFormat('hh:mm a'), // "05:08 PM"
      DateFormat('h:mma'), // "5:08PM"
      DateFormat('hh:mma'), // "05:08PM"
      DateFormat('H:mm'), // "17:08" (24-hour)
      DateFormat('HH:mm'), // "17:08" (24-hour)
    ];

    for (final format in formats) {
      try {
        final parsedTime = format.parse(cleanedTime);
        final result = DateFormat('HH:mm:ss').format(parsedTime);
        print("✅ Converted '$time' → '$result' using ${format.pattern}");
        return result;
      } catch (_) {
        // Try next format
      }
    }

    // Manual parsing as fallback
    try {
      final regex =
          RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)?', caseSensitive: false);
      final match = regex.firstMatch(cleanedTime);

      if (match != null) {
        int hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        final period = match.group(3)?.toUpperCase();

        if (period != null) {
          if (period == 'PM' && hour != 12) hour += 12;
          if (period == 'AM' && hour == 12) hour = 0;
        }

        final result =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
        print("✅ Manually converted '$time' → '$result'");
        return result;
      }
    } catch (e) {
      print("❌ Manual parsing failed: $e");
    }

    print("❌ Error converting time, input: '$time'");
    return "00:00:00";
  }

  /// Convert 24-hour format to locale-aware display format
  /// Input: "17:08:00"
  /// Output: "5:08 PM" (12hr locale) or "17:08" (24hr locale)
  static String convertToLocaleTime(String time24hr, {bool use24Hour = false}) {
    if (time24hr.isEmpty) return "";

    try {
      final parts = time24hr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final dateTime = DateTime(2000, 1, 1, hour, minute);

      if (use24Hour) {
        return DateFormat('HH:mm').format(dateTime);
      } else {
        return DateFormat.jm().format(dateTime); // Locale-aware 12hr format
      }
    } catch (e) {
      print("❌ Error converting to locale time: $e");
      return time24hr;
    }
  }

  /// Convert TimeOfDay to locale-aware string
  static String timeOfDayToLocaleString(TimeOfDay time, {bool use24Hour = false}) {
    final dateTime = DateTime(2000, 1, 1, time.hour, time.minute);

    if (use24Hour) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat.jm().format(dateTime);
    }
  }

  // ============================================
  // DATE FORMATTING (Locale-Aware)
  // ============================================

  /// Format date for display based on user's locale
  /// Examples:
  /// - en_US: "Dec 30, 2025"
  /// - en_GB: "30 Dec 2025"
  /// - de_DE: "30. Dez. 2025"
  static String formatDateLocale(DateTime date, {String? locale}) {
    try {
      return DateFormat.yMMMd(locale).format(date);
    } catch (e) {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  /// Format date for API (ISO 8601 standard)
  /// Output: "2025-12-30"
  static String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format date with day name for display
  /// Example: "Mon, Dec 30, 2025" or "Mon, 30 Dec 2025"
  static String formatDateWithDay(DateTime date, {String? locale}) {
    try {
      return DateFormat.yMMMEd(locale).format(date);
    } catch (e) {
      return DateFormat('E, dd MMM yyyy').format(date);
    }
  }

  /// Format date for event display (shorter format)
  /// Example: "30 Dec" or "Dec 30"
  static String formatDateShort(DateTime date, {String? locale}) {
    try {
      if (date.year == DateTime.now().year) {
        return DateFormat.MMMd(locale).format(date);
      }
      return DateFormat.yMMMd(locale).format(date);
    } catch (e) {
      return DateFormat('dd MMM').format(date);
    }
  }

  // ============================================
  // DATE PARSING
  // ============================================

  /// Parse date from multiple common formats
  /// Supports: "dd MMM yyyy", "yyyy-MM-dd", "MM/dd/yyyy", "dd/MM/yyyy"
  static DateTime? parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;

    final formats = [
      DateFormat('dd MMM yyyy'), // "30 Dec 2025"
      DateFormat('yyyy-MM-dd'), // "2025-12-30" (ISO)
      DateFormat('MM/dd/yyyy'), // "12/30/2025" (US)
      DateFormat('dd/MM/yyyy'), // "30/12/2025" (EU)
      DateFormat('MMM dd, yyyy'), // "Dec 30, 2025"
      DateFormat.yMMMd(), // Locale-aware
    ];

    for (final format in formats) {
      try {
        return format.parse(dateStr);
      } catch (_) {
        // Try next format
      }
    }

    // Try DateTime.parse as fallback (handles ISO 8601)
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      print("❌ Could not parse date: '$dateStr'");
      return null;
    }
  }

  // ============================================
  // UTC CONVERSION (Global Timezone Support)
  // ============================================

  /// Convert local DateTime to UTC for storage
  static DateTime toUtc(DateTime localDateTime) {
    return localDateTime.toUtc();
  }

  /// Convert UTC DateTime to local for display
  static DateTime toLocal(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }

  /// Create DateTime from date string and time string
  /// dateStr: "30 Dec 2025" or "2025-12-30"
  /// timeStr: "17:30:00" or "5:30 PM"
  static DateTime? combineDateAndTime(String dateStr, String timeStr) {
    final date = parseDate(dateStr);
    if (date == null) return null;

    final time24 = convertTo24Hour(timeStr);
    final timeParts = time24.split(':');

    try {
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
      );
    } catch (e) {
      print("❌ Error combining date and time: $e");
      return null;
    }
  }

  // ============================================
  // GLOBAL TIMEZONE CONVERSION
  // ============================================

  /// Convert local date+time to UTC DateTime for storage
  /// This ensures events work globally across all timezones
  ///
  /// Example:
  /// - India user creates event at "Dec 31, 2025 9:00 PM IST"
  /// - Stored as UTC: "Dec 31, 2025 3:30 PM UTC"
  /// - USA user sees: "Dec 31, 2025 10:30 AM EST"
  static DateTime? localToUtc(String dateStr, String timeStr) {
    final localDateTime = combineDateAndTime(dateStr, timeStr);
    if (localDateTime == null) return null;
    return localDateTime.toUtc();
  }

  /// Convert UTC DateTime to local date string for display
  /// Automatically converts to user's device timezone
  static String utcToLocalDateString(DateTime utcDateTime, {String? locale}) {
    final localDateTime = utcDateTime.toLocal();
    return formatDateLocale(localDateTime, locale: locale);
  }

  /// Convert UTC DateTime to local time string for display
  /// Automatically converts to user's device timezone
  static String utcToLocalTimeString(DateTime utcDateTime, {bool use24Hour = false}) {
    final localDateTime = utcDateTime.toLocal();

    if (use24Hour) {
      return DateFormat('HH:mm').format(localDateTime);
    } else {
      return DateFormat.jm().format(localDateTime);
    }
  }

  /// Convert UTC time string (HH:mm:ss) with UTC date to local time string
  /// Used when event stores date and time separately
  static String utcTimeToLocalTime(
    DateTime utcDate,
    String utcTimeStr,
    {bool use24Hour = false}
  ) {
    final timeParts = utcTimeStr.split(':');
    final utcDateTime = DateTime.utc(
      utcDate.year,
      utcDate.month,
      utcDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
      timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
    );

    final localDateTime = utcDateTime.toLocal();

    if (use24Hour) {
      return DateFormat('HH:mm').format(localDateTime);
    } else {
      return DateFormat.jm().format(localDateTime);
    }
  }

  /// Convert local time string to UTC time string for storage
  /// Used when creating/updating events
  static String localTimeToUtcTime(DateTime localDate, String localTimeStr) {
    final time24 = convertTo24Hour(localTimeStr);
    final timeParts = time24.split(':');

    final localDateTime = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
      timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
    );

    final utcDateTime = localDateTime.toUtc();
    return DateFormat('HH:mm:ss').format(utcDateTime);
  }

  /// Get the full UTC DateTime from local date and time strings
  /// Returns both the UTC date and time for storage
  static Map<String, dynamic>? getUtcDateTimeForStorage(
    String localDateStr,
    String localTimeStr
  ) {
    final localDate = parseDate(localDateStr);
    if (localDate == null) return null;

    final time24 = convertTo24Hour(localTimeStr);
    final timeParts = time24.split(':');

    final localDateTime = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
      timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
    );

    final utcDateTime = localDateTime.toUtc();

    return {
      'utcDate': DateTime.utc(utcDateTime.year, utcDateTime.month, utcDateTime.day),
      'utcTime': DateFormat('HH:mm:ss').format(utcDateTime),
      'utcDateTime': utcDateTime,
      'creatorTimezone': getTimezoneName(),
      'creatorOffset': getTimezoneOffset(),
    };
  }

  /// Get local date and time from UTC stored values
  /// Used when displaying events to users in different timezones
  static Map<String, dynamic> getLocalDateTimeForDisplay(
    DateTime utcDate,
    String utcTimeStr,
    {bool use24Hour = false}
  ) {
    final timeParts = utcTimeStr.split(':');
    final utcDateTime = DateTime.utc(
      utcDate.year,
      utcDate.month,
      utcDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
      timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
    );

    final localDateTime = utcDateTime.toLocal();

    return {
      'localDate': DateTime(localDateTime.year, localDateTime.month, localDateTime.day),
      'localDateString': formatDateLocale(localDateTime),
      'localTimeString': use24Hour
          ? DateFormat('HH:mm').format(localDateTime)
          : DateFormat.jm().format(localDateTime),
      'localDateTime': localDateTime,
      'viewerTimezone': getTimezoneName(),
    };
  }

  /// Check if date changes when converting between timezones
  /// Important for events that cross midnight
  static bool doesDateChangeInTimezone(DateTime utcDate, String utcTimeStr) {
    final timeParts = utcTimeStr.split(':');
    final utcDateTime = DateTime.utc(
      utcDate.year,
      utcDate.month,
      utcDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    final localDateTime = utcDateTime.toLocal();

    return localDateTime.day != utcDate.day ||
           localDateTime.month != utcDate.month ||
           localDateTime.year != utcDate.year;
  }

  // ============================================
  // RELATIVE TIME (for display)
  // ============================================

  /// Get relative time string (e.g., "in 2 hours", "tomorrow", "in 3 days")
  static String getRelativeTime(DateTime eventDateTime) {
    final now = DateTime.now();
    final difference = eventDateTime.difference(now);

    if (difference.isNegative) {
      // Past event
      if (difference.inDays.abs() == 0) return "Today";
      if (difference.inDays.abs() == 1) return "Yesterday";
      return "${difference.inDays.abs()} days ago";
    } else {
      // Future event
      if (difference.inMinutes < 60) return "in ${difference.inMinutes} min";
      if (difference.inHours < 24) return "in ${difference.inHours} hours";
      if (difference.inDays == 0) return "Today";
      if (difference.inDays == 1) return "Tomorrow";
      if (difference.inDays < 7) return "in ${difference.inDays} days";
      return formatDateShort(eventDateTime);
    }
  }

  // ============================================
  // DURATION FORMATTING
  // ============================================

  /// Format duration between two times
  /// Example: "2h 30m" or "45m"
  static String formatDuration(String startTime24, String endTime24) {
    try {
      final startParts = startTime24.split(':');
      final endParts = endTime24.split(':');

      final startMinutes =
          int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      var endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      // Handle overnight events
      if (endMinutes <= startMinutes) {
        endMinutes += 24 * 60;
      }

      final durationMinutes = endMinutes - startMinutes;
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;

      if (hours > 0 && minutes > 0) {
        return "${hours}h ${minutes}m";
      } else if (hours > 0) {
        return "${hours}h";
      } else {
        return "${minutes}m";
      }
    } catch (e) {
      return "";
    }
  }
}
