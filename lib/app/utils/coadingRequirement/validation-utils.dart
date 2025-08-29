// ignore_for_file: prefer_interpolation_to_compose_strings, file_names

import 'package:intl/intl.dart';

class Validation {
  static bool isEmpty(String input) {
    return input.isEmpty || input.toLowerCase() == 'null';
  }

  static String stringFormatter(String input) {
    return isEmpty(input) ? "" : input;
  }

  static int integerFormatter(String input) {
    try {
      return int.parse(input);
    } catch (e) {
      return 0;
    }
  }

  static String languageFormatter(String input) {
    return isEmpty(input) ? "en" : input;
  }

  static int integerFormat(String input) {
    return isEmpty(input) || input.contains('.') ? 0 : int.parse(input);
  }

  static double doubleFormat(String input) {
    try {
      return isEmpty(input) ? 0.0 : double.parse(input);
    } catch (e) {
      return 0.0;
    }
  }

  static double doubleValueFormatter(String input) {
    try {
      final numberFormat = NumberFormat("##.00");
      return numberFormat.parse(input).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  static String decimalValueConverter(String input) {
    try {
      final numberFormat = NumberFormat("##.00");
      return numberFormat.format(doubleFormat(input));
    } catch (e) {
      return "";
    }
  }

  static String getFormattedValue(String value) {
    try {
      final formatted = doubleFormat(value);
      return NumberFormat().format(formatted);
    } catch (e) {
      return "";
    }
  }

  static String getFormattedValueWithSymbol(String value) {
    try {
      final formatted = doubleFormat(value);
      return "₹ " + NumberFormat().format(formatted);
    } catch (e) {
      return "";
    }
  }

  static String numberToWords(int number) {
    if (number == 0) {
      return "zero";
    }

    final snumber = number.toString().padLeft(12, '0');

    final billions = int.parse(snumber.substring(0, 3));
    final millions = int.parse(snumber.substring(3, 6));
    final hundredThousands = int.parse(snumber.substring(6, 9));
    final thousands = int.parse(snumber.substring(9, 12));

    final tradBillions = _convertLessThanOneThousand(billions);
    final tradMillions = _convertLessThanOneThousand(millions);
    final tradHundredThousands = _convertLessThanOneThousand(hundredThousands);
    final tradThousand = _convertLessThanOneThousand(thousands);

    return "$tradBillions $tradMillions $tradHundredThousands $tradThousand"
        .replaceAll(RegExp(r'^\s+'), '')
        .replaceAll(RegExp(r'\b\s{2,}\b'), ' ');
  }

  static String _convertLessThanOneThousand(int number) {
    final tensNames = [
      "",
      "ten",
      "twenty",
      "thirty",
      "forty",
      "fifty",
      "sixty",
      "seventy",
      "eighty",
      "ninety"
    ];
    final numNames = [
      "",
      "one",
      "two",
      "three",
      "four",
      "five",
      "six",
      "seven",
      "eight",
      "nine",
      "ten",
      "eleven",
      "twelve",
      "thirteen",
      "fourteen",
      "fifteen",
      "sixteen",
      "seventeen",
      "eighteen",
      "nineteen"
    ];

    final soFar = number % 100 < 20
        ? numNames[number % 100]
        : tensNames[number % 10] + numNames[number % 10];

    if (number == 0) return soFar;
    return "${numNames[number ~/ 100]} hundred $soFar";
  }

  static String getStringDate(DateTime date) {
    final dateFormat = date.year == DateTime.now().year
        ? DateFormat('E, dd MMM')
        : DateFormat('E, dd MMM yyyy');

    return dateFormat.format(date);
  }

  static DateTime setStartDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime setEndDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime setStartWeek(DateTime date) {
    date = setStartDay(date);
    date = date.subtract(Duration(days: date.weekday - 1));
    return date;
  }

  static DateTime setEndWeek(DateTime date) {
    date = setEndDay(date);
    date = date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
    return date;
  }

  static DateTime setStartMonth(DateTime date) {
    date = setStartDay(date);
    date = DateTime(date.year, date.month, 1);
    return date;
  }

  static DateTime setEndMonth(DateTime date) {
    date = setEndDay(date);
    date = DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
    return date;
  }

  static bool isValidGSTNumber(String gstNumber) {
    RegExp gstRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$',
    );

    if (!gstRegex.hasMatch(gstNumber)) {
      return false;
    }

    // Checksum validation logic (you may need to implement this)
    // ...

    return true;
  }
}
