// ignore_for_file: file_names

class InvitedEventModel {
  final int eventId;
  final String title;
  final String eventDate; // yyyy-MM-dd (UTC date)
  final String startTime; // HH:mm:ss (UTC time)
  final String endTime; // HH:mm:ss (UTC time)

  /// Optional event description
  String? description;

  /// User invitation state (editable)
  String status;

  /// Event banner / poster image
  String? imagePath;

  /// Creator's timezone name (e.g., "Asia/Kolkata")
  String? timezone;

  /// Creator's timezone offset (e.g., "+05:30")
  String? timezoneOffset;

  InvitedEventModel({
    required this.eventId,
    required this.title,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.description,
    this.imagePath,
    this.timezone,
    this.timezoneOffset,
  });

  // ------------------- JSON CONVERTORS ------------------- //

  factory InvitedEventModel.fromJson(Map<String, dynamic> json) {
    return InvitedEventModel(
      eventId: json["eventId"] ?? 0,
      title: json["title"] ?? "",
      eventDate: json["eventDate"] ?? "",
      startTime: json["startTime"] ?? "",
      endTime: json["endTime"] ?? "",
      status: json["status"] ?? "",
      description: json["description"],
      imagePath: json["imagePath"],
      timezone: json["timezone"],
      timezoneOffset: json["timezoneOffset"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "eventId": eventId,
      "title": title,
      "eventDate": eventDate,
      "startTime": startTime,
      "endTime": endTime,
      "status": status,
      "description": description,
      "imagePath": imagePath,
      "timezone": timezone,
      "timezoneOffset": timezoneOffset,
    };
  }

  // ------------------- STATUS HELPERS ------------------- //

  bool get isPending => status.toUpperCase() == "PENDING";
  bool get isAccepted => status.toUpperCase() == "ACCEPTED";
  bool get isRejected => status.toUpperCase() == "REJECTED";

  // ---------------- DATE + TIME COMBINATIONS -------------- //

  /// Full Start DateTime (UTC) = 2025-02-12 19:30:00 UTC
  DateTime get eventStartDateTime {
    return _combineAsUtc(eventDate, startTime);
  }

  /// Full End DateTime (UTC) = 2025-02-12 21:00:00 UTC
  DateTime get eventEndDateTime {
    return _combineAsUtc(eventDate, endTime);
  }

  /// Example Result → "07:30 PM - 09:00 PM"
  String get formattedTimeRange => "$startTime - $endTime";

  // ============================
  // 🌍 TIMEZONE HANDLING (GLOBAL SUPPORT)
  // Backend stores UTC times
  // Flutter converts UTC → Local for display
  // ============================

  /// Get start DateTime in viewer's local timezone
  /// Converts UTC (stored) → viewer's local timezone
  DateTime get localStartDateTime {
    try {
      final utcDateTime = _combineAsUtc(eventDate, startTime);
      return utcDateTime.toLocal();
    } catch (e) {
      // Fallback: return current time if parsing fails
      return DateTime.now();
    }
  }

  /// Get end DateTime in viewer's local timezone
  /// Converts UTC (stored) → viewer's local timezone
  DateTime get localEndDateTime {
    try {
      final utcDateTime = _combineAsUtc(eventDate, endTime);
      return utcDateTime.toLocal();
    } catch (e) {
      // Fallback: return current time + 1 hour if parsing fails
      return DateTime.now().add(const Duration(hours: 1));
    }
  }

  /// Get creator's timezone info for display
  /// Example: "Created in IST (+05:30)"
  String get creatorTimezoneInfo {
    if (timezone != null && timezoneOffset != null) {
      return "$timezone ($timezoneOffset)";
    } else if (timezone != null) {
      return timezone!;
    } else if (timezoneOffset != null) {
      return "UTC$timezoneOffset";
    }
    return "";
  }

  // ---------------- SAFE DATETIME BUILDER ----------------- //

  /// Combines date and time into a UTC DateTime object
  /// Server stores UTC times, so we return UTC DateTime
  DateTime _combineAsUtc(String d, String t) {
    // Support: "09:20", "7:30 PM", "7PM", "7:15am", "HH:mm:ss"
    var time = t.trim().toUpperCase();

    // Detect AM/PM
    bool pm = time.contains("PM");
    bool am = time.contains("AM");

    // Remove AM / PM
    time = time.replaceAll("AM", "").replaceAll("PM", "").trim();
    final parts = time.split(":");

    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    int second = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;

    if (pm && hour < 12) hour += 12;
    if (am && hour == 12) hour = 0;

    final date = DateTime.parse(d);

    // Return as UTC DateTime since server stores UTC times
    return DateTime.utc(date.year, date.month, date.day, hour, minute, second);
  }
}
