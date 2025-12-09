// ignore_for_file: prefer_interpolation_to_compose_strings, file_names, curly_braces_in_flow_control_structures

import 'package:intl/intl.dart';
import '../../constants/app_texts.dart';

class Validation {
  //----------------------------------------------------
  // GENERIC CHECKS
  //----------------------------------------------------
  static bool isEmpty(String input) {
    return input.isEmpty || input.toLowerCase() == 'null';
  }

  //----------------------------------------------------
  // STRING FORMATTERS
  //----------------------------------------------------
  static String stringFormatter(String input) {
    return isEmpty(input) ? "" : input;
  }

  //----------------------------------------------------
  // INTEGER FORMATTERS
  //----------------------------------------------------
  static int integerFormatter(String input) {
    try {
      return int.parse(input);
    } catch (_) {
      return 0;
    }
  }

  static int integerFormat(String input) {
    return isEmpty(input) || input.contains('.') ? 0 : int.parse(input);
  }

  //----------------------------------------------------
  // DOUBLE FORMATTERS
  //----------------------------------------------------
  static double doubleFormat(String input) {
    try {
      return isEmpty(input) ? 0.0 : double.parse(input);
    } catch (_) {
      return 0.0;
    }
  }

  static double doubleValueFormatter(String input) {
    try {
      return NumberFormat("##.00").parse(input).toDouble();
    } catch (_) {
      return 0.0;
    }
  }

  //----------------------------------------------------
  // CURRENCY FORMATTERS
  //----------------------------------------------------
  static String decimalValueConverter(String input) {
    try {
      return NumberFormat("##.00").format(doubleFormat(input));
    } catch (_) {
      return "";
    }
  }

  static String getFormattedValue(String value) {
    try {
      return NumberFormat().format(doubleFormat(value));
    } catch (_) {
      return "";
    }
  }

  static String getFormattedValueWithSymbol(String value) {
    try {
      return "₹ ${NumberFormat().format(doubleFormat(value))}";
    } catch (_) {
      return "";
    }
  }

  //----------------------------------------------------
  // NUMBER → WORDS
  //----------------------------------------------------
  static String numberToWords(int number) {
    if (number == 0) return "zero";

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
      "ninety",
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
      "nineteen",
    ];

    final soFar =
        number % 100 < 20
            ? numNames[number % 100]
            : tensNames[number ~/ 10] + numNames[number % 10];

    if (number == 0) return soFar;

    return "${numNames[number ~/ 100]} hundred $soFar";
  }

  //----------------------------------------------------
  // DATE HELPERS
  //----------------------------------------------------
  static String getStringDate(DateTime date) {
    final dateFormat =
        date.year == DateTime.now().year
            ? DateFormat('E, dd MMM')
            : DateFormat('E, dd MMM yyyy');

    return dateFormat.format(date);
  }

  static DateTime setStartDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime setEndDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  //----------------------------------------------------
  // GST VALIDATOR
  //----------------------------------------------------
  static bool isValidGSTNumber(String gstNumber) {
    final gstRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$',
    );

    return gstRegex.hasMatch(gstNumber);
  }

  //----------------------------------------------------
  // FORM VALIDATIONS
  //----------------------------------------------------
  static String? validateName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Name cannot be empty';
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(trimmed))
      return 'Name must contain only letters';
    if (trimmed.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  // PRODUCTION GRADE EMAIL VALIDATION (from your controller)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return AppTexts.EMAIL_REQUIRED;

    final email = value.trim();

    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+"
      r"@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
      r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );

    if (!emailRegex.hasMatch(email)) return AppTexts.EMAIL_INVALID;
    if (email.contains("..")) return AppTexts.EMAIL_CONSECUTIVE_DOTS;
    if (email.endsWith(".")) return AppTexts.EMAIL_ENDS_WITH_DOT;

    final parts = email.split('@');
    if (parts.length != 2) return AppTexts.EMAIL_INVALID;

    final local = parts[0];
    final domain = parts[1];

    if (local.isEmpty) return AppTexts.EMAIL_INVALID;
    if (domain.isEmpty) return AppTexts.EMAIL_INVALID;

    final domainParts = domain.split('.');
    if (domainParts.length < 2 || domainParts.any((part) => part.isEmpty)) {
      return AppTexts.EMAIL_DOMAIN_INVALID;
    }

    if (local.length > 64) return AppTexts.EMAIL_LOCAL_TOO_LONG;
    if (email.length > 254) return AppTexts.EMAIL_TOO_LONG;

    return null;
  }

  static String? validatePassword(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Password cannot be empty';
    if (trimmed.length < 8) return 'Minimum 8 characters required';
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(trimmed)) {
      return 'Include uppercase, lowercase, and a number';
    }
    return null;
  }

  //----------------------------------------------------
  // MOBILE NUMBER VALIDATOR
  //----------------------------------------------------
  static String? validatePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return "Mobile number is required";

    // 10-digit Indian mobile number (starts with 6-9)
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed)) {
      return "Enter valid 10-digit number";
    }
    return null;
  }

  // ---------------------------------------------
  // EVENT FORM VALIDATIONS (MOVED FROM CONTROLLER)
  // ---------------------------------------------
  static String? validateEventTitle(String value) {
    final trimmed = value.trim();
    return trimmed.length < 3 ? "Title must be at least 3 characters" : null;
  }

  static String? validateEventDescription(String value) {
    final trimmed = value.trim();
    return trimmed.length < 5
        ? "Description must be at least 5 characters"
        : null;
  }

  static String? validateEventDate(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? "Please select date" : null;
  }

  static String? validateEventStart(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? "Please select start time" : null;
  }

  static String? validateEventEnd(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? "Please select end time" : null;
  }

  static String? validateOtp(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return "OTP cannot be empty";
    if (!RegExp(r'^\d{6}$').hasMatch(trimmed))
      return "Please enter a valid 6-digit OTP";
    return null;
  }
}
