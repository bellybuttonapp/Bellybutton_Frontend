// ignore_for_file: non_constant_identifier_names, file_names, avoid_print

import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class EventModel extends HiveObject {
  @HiveField(0)
  int id;

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
  String? imagePath; // 👈 Added optional image field

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.invitedPeople,
    this.imagePath, // 👈 Added to constructor
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final dateString = json['eventDate'];
    final localDate = DateTime.parse(dateString).toLocal();

    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      eventDate: DateTime(localDate.year, localDate.month, localDate.day),
      startTime: json['startTime'],
      endTime: json['endTime'],
      invitedPeople: json['invitedPeople'] ?? [],
      imagePath: json['imagePath'], // 👈 Added
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'invitedPeople': invitedPeople,
      'imagePath': imagePath, // 👈 Added
    };
  }

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
      print('⚠️ Error parsing event time: $e');
      return eventDate;
    }
  }
}

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
      id: fields[0] as int,
      title: fields[1] as String,
      description: fields[2] as String,
      eventDate: fields[3] as DateTime,
      startTime: fields[4] as String,
      endTime: fields[5] as String,
      invitedPeople: (fields[6] as List).cast<dynamic>(),
      imagePath: fields[7] as String?, // 👈 Added
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer
      ..writeByte(8) // updated field count
      ..writeByte(0)
      ..write(obj.id)
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
      ..write(obj.imagePath); // 👈 Added
  }
}
