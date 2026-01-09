// ignore_for_file: prefer_interpolation_to_compose_strings, file_names, curly_braces_in_flow_control_structures

import 'package:intl/intl.dart';
import '../../constants/app_texts.dart';
import 'date_converter.dart';

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
  // MOBILE NUMBER VALIDATOR (Global)
  //----------------------------------------------------
  static String? validatePhone(String value, {int minLength = 7, int maxLength = 15}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return "Mobile number is required";

    // Only digits allowed
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return "Enter digits only";
    }

    // Global phone number length validation (7-15 digits)
    if (trimmed.length < minLength) {
      return "Minimum $minLength digits required";
    }
    if (trimmed.length > maxLength) {
      return "Maximum $maxLength digits allowed";
    }

    return null;
  }

  /// Country-specific phone number length map
  /// Returns (minLength, maxLength) for each country code
  static (int, int) getPhoneLengthForCountry(String countryCode) {
    final lengths = {
      // South Asia
      'IN': (10, 10), // India
      'PK': (10, 10), // Pakistan
      'BD': (10, 10), // Bangladesh
      'LK': (9, 9),   // Sri Lanka
      'NP': (10, 10), // Nepal

      // North America
      'US': (10, 10), // USA
      'CA': (10, 10), // Canada
      'MX': (10, 10), // Mexico

      // Europe
      'GB': (10, 10), // UK
      'DE': (10, 11), // Germany
      'FR': (9, 9),   // France
      'IT': (9, 10),  // Italy
      'ES': (9, 9),   // Spain
      'NL': (9, 9),   // Netherlands
      'BE': (9, 9),   // Belgium
      'PT': (9, 9),   // Portugal
      'AT': (10, 13), // Austria
      'CH': (9, 9),   // Switzerland
      'PL': (9, 9),   // Poland
      'SE': (9, 9),   // Sweden
      'NO': (8, 8),   // Norway
      'DK': (8, 8),   // Denmark
      'FI': (9, 10),  // Finland
      'IE': (9, 9),   // Ireland
      'GR': (10, 10), // Greece

      // Middle East
      'AE': (9, 9),   // UAE
      'SA': (9, 9),   // Saudi Arabia
      'QA': (8, 8),   // Qatar
      'KW': (8, 8),   // Kuwait
      'BH': (8, 8),   // Bahrain
      'OM': (8, 8),   // Oman
      'IL': (9, 9),   // Israel
      'TR': (10, 10), // Turkey

      // East Asia
      'CN': (11, 11), // China
      'JP': (10, 11), // Japan
      'KR': (10, 11), // South Korea
      'HK': (8, 8),   // Hong Kong
      'TW': (9, 9),   // Taiwan
      'SG': (8, 8),   // Singapore
      'MY': (9, 10),  // Malaysia
      'TH': (9, 9),   // Thailand
      'VN': (9, 10),  // Vietnam
      'ID': (10, 12), // Indonesia
      'PH': (10, 10), // Philippines

      // Oceania
      'AU': (9, 9),   // Australia
      'NZ': (9, 10),  // New Zealand

      // Africa
      'ZA': (9, 9),   // South Africa
      'NG': (10, 10), // Nigeria
      'EG': (10, 10), // Egypt
      'KE': (9, 9),   // Kenya
      'GH': (9, 9),   // Ghana

      // South America
      'BR': (10, 11), // Brazil
      'AR': (10, 10), // Argentina
      'CO': (10, 10), // Colombia
      'CL': (9, 9),   // Chile
      'PE': (9, 9),   // Peru
    };

    return lengths[countryCode.toUpperCase()] ?? (7, 15);
  }

  /// Validate phone with country-specific length
  static String? validatePhoneForCountry(String value, String countryCode) {
    final (minLen, maxLen) = getPhoneLengthForCountry(countryCode);
    return validatePhone(value, minLength: minLen, maxLength: maxLen);
  }

  // Indian specific phone validation
  static String? validateIndianPhone(String value) {
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

  /// Comprehensive start time validation with date context
  /// Returns null if valid, error message if invalid
  static String? validateStartTimeWithContext({
    required String startTime,
    required String eventDate,
    int bufferMinutes = 5,
  }) {
    if (startTime.trim().isEmpty) return "Select start time";
    if (eventDate.trim().isEmpty) return "Select date first";

    try {
      final eventDateTime = _parseTimeWithDate(startTime, eventDate);
      final now = DateTime.now();
      final minAllowedTime = now.add(Duration(minutes: bufferMinutes));

      if (eventDateTime.isBefore(minAllowedTime)) {
        return "Time too soon";
      }

      return null;
    } catch (_) {
      return "Invalid time";
    }
  }

  /// Comprehensive end time validation with start time context
  /// Returns null if valid, error message if invalid
  static String? validateEndTimeWithContext({
    required String endTime,
    required String startTime,
    required String eventDate,
    int minDurationMinutes = 15,
    int maxDurationMinutes = 120,
    bool skipPastCheck = false,
  }) {
    if (endTime.trim().isEmpty) return "Select end time";
    if (startTime.trim().isEmpty) return "Set start time first";
    if (eventDate.trim().isEmpty) return "Select date first";

    try {
      final start = _parseTimeWithDate(startTime, eventDate);
      var end = _parseTimeWithDate(endTime, eventDate);
      final now = DateTime.now();

      // Check if start time is in the past (skip in edit mode)
      if (!skipPastCheck && start.isBefore(now)) {
        return "Start time passed";
      }

      // Handle overnight events (end time crosses midnight)
      // If end appears before start, it means next day
      if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
        end = end.add(const Duration(days: 1));
      }

      // Check duration
      final durationMinutes = end.difference(start).inMinutes;

      if (durationMinutes < minDurationMinutes) {
        return "Min $minDurationMinutes min required";
      }

      if (durationMinutes > maxDurationMinutes) {
        final hours = maxDurationMinutes ~/ 60;
        return "Max $hours hr${hours > 1 ? 's' : ''} allowed";
      }

      return null;
    } catch (_) {
      return "Invalid time";
    }
  }

  /// Helper to parse time string with date context
  /// Supports multiple date formats globally using DateConverter
  static DateTime _parseTimeWithDate(String time, String date) {
    // Use DateConverter for locale-aware date parsing
    final datePart = DateConverter.parseDate(date);
    if (datePart == null) {
      throw FormatException('Invalid date format: $date');
    }

    // Convert time to 24-hour format using DateConverter
    final time24 = DateConverter.convertTo24Hour(time);
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return DateTime(datePart.year, datePart.month, datePart.day, hour, minute);
  }

  static String? validateOtp(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return "OTP cannot be empty";
    if (!RegExp(r'^\d{6}$').hasMatch(trimmed))
      return "Please enter a valid 6-digit OTP";
    return null;
  }
}