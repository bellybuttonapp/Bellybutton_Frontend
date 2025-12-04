import 'package:permission_handler/permission_handler.dart';

class AppPermission {
  /// Requests all essential permissions for the app.
  static Future<Map<Permission, PermissionStatus>>
  requestAllPermissions() async {
    final permissions = <Permission>[
      Permission.camera,
      Permission.location,
      Permission.storage,
      Permission.contacts,
      Permission.sms,
    ];

    // Request permissions and store the results
    final statuses = await permissions.request();

    // Log denied permissions for debugging
    statuses.forEach((permission, status) {
      if (status.isDenied || status.isPermanentlyDenied) {
        // ignore: avoid_print
        print("⚠️ Permission denied: $permission ($status)");
      }
    });

    return statuses;
  }

  /// Checks if all required permissions are granted
  static Future<bool> areAllGranted() async {
    final statuses = await requestAllPermissions();
    return statuses.values.every((status) => status.isGranted);
  }

  /// Opens the app settings for manual permission enablement
  static Future<void> openSettings() async {
    if (await openAppSettings()) {
      // ignore: avoid_print
      print("⚙️ Opened app settings for permissions.");
    }
  }
}
