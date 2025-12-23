// ignore_for_file: non_constant_identifier_names, file_names, avoid_print

import 'package:hive/hive.dart';

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

  EventModel({
    this.id, // ✅ FIXED
    required this.title,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.invitedPeople,
    this.imagePath,
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
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.imagePath);
  }
}