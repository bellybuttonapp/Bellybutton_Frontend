import 'package:permission_handler/permission_handler.dart';

class AppPermission {
  static Future<Map<Permission, PermissionStatus>>
      requestAllPermissions() async {
    var permissions = [
      Permission.camera,
      Permission.location,
      Permission.storage,
      Permission.contacts,
      Permission.location,
      Permission.sms,
    ];

    return await permissions.request();
  }
}
