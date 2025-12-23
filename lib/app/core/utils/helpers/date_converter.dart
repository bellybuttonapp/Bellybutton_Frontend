// ignore_for_file: avoid_print

import 'package:intl/intl.dart';

class DateConverter {
  static String convertTo24Hour(String time) {
    if (time.isEmpty) return "00:00:00";

    // Remove any unwanted characters (non-ASCII)
    String cleanedTime = time.replaceAll(RegExp(r'[^\x00-\x7F]'), '').trim();

    // If already in 24-hour HH:mm:ss format, return as is
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(cleanedTime)) {
      return cleanedTime;
    }

    // Try multiple formats for 12-hour time
    final formats = [
      DateFormat.jm(),           // "5:08 PM"
      DateFormat('h:mm a'),      // "5:08 PM"
      DateFormat('hh:mm a'),     // "05:08 PM"
      DateFormat('h:mma'),       // "5:08PM"
      DateFormat('hh:mma'),      // "05:08PM"
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
      final regex = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)', caseSensitive: false);
      final match = regex.firstMatch(cleanedTime);

      if (match != null) {
        int hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        final period = match.group(3)!.toUpperCase();

        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;

        final result = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
        print("✅ Manually converted '$time' → '$result'");
        return result;
      }
    } catch (e) {
      print("❌ Manual parsing failed: $e");
    }

    print("❌ Error converting time, input: '$time'");
    return "00:00:00";
  }
}