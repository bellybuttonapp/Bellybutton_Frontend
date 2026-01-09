// ignore_for_file: non_constant_identifier_names, file_names, avoid_print

import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

@HiveType(typeId: 0)
class EventModel extends HiveObject {
  @HiveField(0)
  int? id; // ✅ FIX: id is now nullable

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime eventDate;

  @HiveField(4)
  String startTime;

  @HiveField(5)
  String endTime;

  @HiveField(6)
  List<dynamic> invitedPeople;

  @HiveField(7)
  String? imagePath;

  @HiveField(8)
  String? shareToken;

  @HiveField(9)
  int? creatorId;

  @HiveField(10)
  String? status; // UPCOMING, EXPIRED, etc.

  @HiveField(11)
  String? timezone; // e.g., "Asia/Kolkata", "America/New_York"

  @HiveField(12)
  String? timezoneOffset; // e.g., "+05:30", "-08:00"

  EventModel({
    this.id, // ✅ FIXED
    required this.title,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.invitedPeople,
    this.imagePath,
    this.shareToken,
    this.creatorId,
    this.status,
    this.timezone,
    this.timezoneOffset,
  });

  // ============================
  // 🔥 FIXED: fromJson()
  // ============================
  factory EventModel.fromJson(Map<String, dynamic> json) {
    final parsedDate = DateTime.parse(json['eventDate']);

    return EventModel(
      id: json['id'], // nullable safe
      title: json['title'],
      description: json['description'],
      eventDate: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      startTime: json['startTime'],
      endTime: json['endTime'],
      invitedPeople: json['invitedPeople'] ?? [],
      imagePath: json['imagePath'],
      shareToken: json['shareToken'],
      creatorId: json['creatorId'],
      status: json['status'],
      timezone: json['timezone'],
      timezoneOffset: json['timezoneOffset'],
    );
  }

  // ============================
  // 🔥 NEW: fromCreateResponse() - For create event API response
  // Uses data.invitedPeople (has id) instead of data.event.invitedPeople (no id)
  // ============================
  factory EventModel.fromCreateResponse(Map<String, dynamic> response) {
    final event = response['event'] as Map<String, dynamic>;
    final invitedPeopleWithId = response['invitedPeople'] as List<dynamic>? ?? [];
    final parsedDate = DateTime.parse(event['eventDate']);

    return EventModel(
      id: event['id'],
      title: event['title'],
      description: event['description'],
      eventDate: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      startTime: event['startTime'],
      endTime: event['endTime'],
      invitedPeople: invitedPeopleWithId, // Use the one with id!
      imagePath: event['imagePath'],
      shareToken: event['shareToken'],
      creatorId: event['creatorId'],
      status: event['status'],
      timezone: event['timezone'],
      timezoneOffset: event['timezoneOffset'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // nullable OK
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'invitedPeople': invitedPeople,
      'imagePath': imagePath,
      'shareToken': shareToken,
      'creatorId': creatorId,
      'status': status,
      'timezone': timezone,
      'timezoneOffset': timezoneOffset,
    };
  }

  // ============================
  // 🔥 FIXED: fullEventDateTime() - Start Time
  // ============================
  DateTime get fullEventDateTime {
    try {
      final parts = startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final second = parts.length > 2 ? int.parse(parts[2]) : 0;
      return DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        hour,
        minute,
        second,
      );
    } catch (e) {
      print("⚠ Error computing fullEventDateTime: $e");
      return eventDate;
    }
  }

  // ============================
  // 🔥 NEW: fullEventEndDateTime() - End Time
  // ============================
  DateTime get fullEventEndDateTime {
    try {
      final parts = endTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final second = parts.length > 2 ? int.parse(parts[2]) : 0;
      return DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        hour,
        minute,
        second,
      );
    } catch (e) {
      print("⚠ Error computing fullEventEndDateTime: $e");
      return eventDate;
    }
  }

  // ============================
  // 🌍 TIMEZONE HANDLING (GLOBAL SUPPORT)
  // Backend stores UTC times
  // Flutter converts UTC → Local for display
  // ============================

  /// Get start time as local DateTime
  /// Converts UTC (stored) → viewer's local timezone
  DateTime get localStartDateTime {
    // fullEventDateTime gives us the raw DateTime from server
    // Server stores UTC, so we treat it as UTC and convert to local
    final utcDateTime = DateTime.utc(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      fullEventDateTime.hour,
      fullEventDateTime.minute,
      fullEventDateTime.second,
    );
    final localDateTime = utcDateTime.toLocal();

    // 🔍 DEBUG: Print timezone conversion when displaying event
    print('═══════════════════════════════════════════════════════');
    print('🌍 DISPLAY TIMEZONE CONVERSION DEBUG:');
    print('───────────────────────────────────────────────────────');
    print('📥 Received from Backend:');
    print('   Event ID: $id');
    print('   Title: $title');
    print('   eventDate: ${DateFormat('yyyy-MM-dd').format(eventDate)}');
    print('   startTime: $startTime');
    print('   timezone: $timezone');
    print('   timezoneOffset: $timezoneOffset');
    print('───────────────────────────────────────────────────────');
    print('🔄 UTC DateTime Constructed:');
    print('   $utcDateTime UTC');
    print('───────────────────────────────────────────────────────');
    print('🌐 Device Timezone:');
    print('   ${DateTime.now().timeZoneName} (${DateTime.now().timeZoneOffset})');
    print('───────────────────────────────────────────────────────');
    print('✅ Converted to Local:');
    print('   ${DateFormat('yyyy-MM-dd HH:mm:ss').format(localDateTime)} ${DateTime.now().timeZoneName}');
    print('   Display: ${DateFormat('E, d MMMM - h:mm a').format(localDateTime)}');
    print('═══════════════════════════════════════════════════════');

    return localDateTime;
  }

  /// Get end time as local DateTime
  /// Converts UTC (stored) → viewer's local timezone
  DateTime get localEndDateTime {
    final utcDateTime = DateTime.utc(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      fullEventEndDateTime.hour,
      fullEventEndDateTime.minute,
      fullEventEndDateTime.second,
    );
    return utcDateTime.toLocal();
  }

  /// Get formatted local start time string
  /// Example: "3:00 PM" or "15:00" based on device setting
  String getLocalStartTimeString({bool use24Hour = false}) {
    final local = localStartDateTime;
    if (use24Hour) {
      return DateFormat('HH:mm').format(local);
    }
    return DateFormat.jm().format(local);
  }

  /// Get formatted local end time string
  String getLocalEndTimeString({bool use24Hour = false}) {
    final local = localEndDateTime;
    if (use24Hour) {
      return DateFormat('HH:mm').format(local);
    }
    return DateFormat.jm().format(local);
  }

  /// Get formatted local date string
  /// Automatically adapts to user's locale
  String getLocalDateString({String? locale}) {
    final local = localStartDateTime;
    try {
      return DateFormat.yMMMd(locale).format(local);
    } catch (e) {
      return DateFormat('dd MMM yyyy').format(local);
    }
  }

  /// Get the local date (may differ from UTC date due to timezone)
  DateTime get localEventDate {
    final local = localStartDateTime;
    return DateTime(local.year, local.month, local.day);
  }

  /// Check if the event date is different in viewer's timezone
  /// Important for events that cross midnight
  bool get dateChangesInLocalTimezone {
    final utcDay = eventDate.day;
    final localDay = localStartDateTime.day;
    return utcDay != localDay;
  }

  /// Get formatted time range string in local timezone
  /// Example: "3:00 PM - 5:00 PM" or "15:00 - 17:00"
  String getLocalTimeRangeString({bool use24Hour = false}) {
    return "${getLocalStartTimeString(use24Hour: use24Hour)} - ${getLocalEndTimeString(use24Hour: use24Hour)}";
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
    return "Unknown timezone";
  }
}

// ============================
// 🔥 FULL FIXED HIVE ADAPTER
// ============================

class EventModelAdapter extends TypeAdapter<EventModel> {
  @override
  final int typeId = 0;

  @override
  EventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return EventModel(
      id: fields[0] as int?, // ✅ FIX: nullable
      title: fields[1] as String,
      description: fields[2] as String,
      eventDate: fields[3] as DateTime,
      startTime: fields[4] as String,
      endTime: fields[5] as String,
      invitedPeople: (fields[6] as List).cast<dynamic>(),
      imagePath: fields[7] as String?,
      shareToken: fields[8] as String?,
      creatorId: fields[9] as int?,
      status: fields[10] as String?,
      timezone: fields[11] as String?,
      timezoneOffset: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id) // nullable safe
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.eventDate)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.invitedPeople)
      ..writeByte(7)
      ..write(obj.imagePath)
      ..writeByte(8)
      ..write(obj.shareToken)
      ..writeByte(9)
      ..write(obj.creatorId)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.timezone)
      ..writeByte(12)
      ..write(obj.timezoneOffset);
  }
}