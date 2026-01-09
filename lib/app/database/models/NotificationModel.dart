// ignore_for_file: file_names

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final DateTime createdAt; // Stored in UTC
  final String fullName;
  final String? profileImageUrl;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.fullName,
    this.profileImageUrl,
    required this.read,
  });

  /// Parse UTC timestamp and store as UTC DateTime
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null
          ? _parseUtcDateTime(json['createdAt'])
          : DateTime.now(),
      fullName: json['fullName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      read: json['read'] ?? false,
    );
  }

  /// Parse datetime string as UTC
  /// Handles both ISO 8601 format and formats with/without Z suffix
  static DateTime _parseUtcDateTime(String dateTimeStr) {
    try {
      // If string already ends with Z, parse directly (already UTC)
      if (dateTimeStr.endsWith('Z')) {
        return DateTime.parse(dateTimeStr);
      }
      // If string has timezone offset like +00:00, parse directly
      if (dateTimeStr.contains('+') || (dateTimeStr.length > 10 && dateTimeStr.substring(10).contains('-'))) {
        return DateTime.parse(dateTimeStr);
      }
      // Otherwise, treat as UTC by appending Z
      return DateTime.parse('${dateTimeStr}Z');
    } catch (e) {
      // Fallback to regular parse if UTC parsing fails
      return DateTime.parse(dateTimeStr);
    }
  }

  // ============================
  // 🌍 LOCAL TIMEZONE SUPPORT
  // ============================

  /// Get createdAt in viewer's LOCAL timezone for display
  DateTime get localCreatedAt => createdAt.toLocal();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'read': read,
    };
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    DateTime? createdAt,
    String? fullName,
    String? profileImageUrl,
    bool? read,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      read: read ?? this.read,
    );
  }
}