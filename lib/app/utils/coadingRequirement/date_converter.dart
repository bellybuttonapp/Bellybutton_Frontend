// ignore_for_file: avoid_print

import 'package:intl/intl.dart';

class DateConverter {
  static String convertTo24Hour(String time) {
    if (time.isEmpty) return "00:00:00";

    // Remove any unwanted characters
    String cleanedTime = time.replaceAll(RegExp(r'[^\x00-\x7F]'), '').trim();

    // If already in 24-hour HH:mm:ss format, return as is
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(cleanedTime)) {
      return cleanedTime;
    }

    // Otherwise, assume 12-hour format and convert
    try {
      final parsedTime = DateFormat.jm().parse(cleanedTime);
      return DateFormat('HH:mm:ss').format(parsedTime);
    } catch (e) {
      print("Error converting time: $e, input: '$time'");
      return "00:00:00";
    }
  }
}
