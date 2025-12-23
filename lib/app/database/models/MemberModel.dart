// ignore_for_file: file_names

class MemberModel {
  final String name;
  final String? profileImage;
  final String? email;
  final String? role;

  MemberModel({
    required this.name,
    this.profileImage,
    this.email,
    this.role,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      name: json["name"] ?? "",
      profileImage: json["profileImage"],
      email: json["email"],
      role: json["role"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "profileImage": profileImage,
      "email": email,
      "role": role,
    };
  }
}
