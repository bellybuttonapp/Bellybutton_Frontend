// ignore_for_file: file_names

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final DateTime createdAt;
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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      fullName: json['fullName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      read: json['read'] ?? false,
    );
  }

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