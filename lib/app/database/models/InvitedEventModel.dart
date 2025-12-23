// ignore_for_file: file_names

class InvitedEventModel {
  final int eventId;
  final String title;
  final String eventDate; // yyyy-MM-dd
  final String startTime; // HH:mm or 07:30 PM
  final String endTime; // HH:mm or 09:00 PM

  /// Optional event description
  String? description;

  /// User invitation state (editable)
  String status;

  /// Event banner / poster image
  String? imagePath;

  InvitedEventModel({
    required this.eventId,
    required this.title,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.description,
    this.imagePath,
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
    };
  }

  // ------------------- STATUS HELPERS ------------------- //

  bool get isPending => status.toUpperCase() == "PENDING";
  bool get isAccepted => status.toUpperCase() == "ACCEPTED";
  bool get isRejected => status.toUpperCase() == "REJECTED";

  // ---------------- DATE + TIME COMBINATIONS -------------- //

  /// Full Start DateTime = 2025-02-12 19:30:00
  DateTime get eventStartDateTime {
    return _combine(eventDate, startTime);
  }

  /// Full End DateTime = 2025-02-12 21:00:00
  DateTime get eventEndDateTime {
    return _combine(eventDate, endTime);
  }

  /// Example Result → "07:30 PM - 09:00 PM"
  String get formattedTimeRange => "$startTime - $endTime";

  // ---------------- SAFE DATETIME BUILDER ----------------- //

  DateTime _combine(String d, String t) {
    // Support: "09:20", "7:30 PM", "7PM", "7:15am"
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

    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }
}
