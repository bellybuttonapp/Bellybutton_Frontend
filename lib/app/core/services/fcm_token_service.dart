// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import '../utils/storage/preference.dart';
// import 'notification_service.dart';

// class FcmTokenService {
//   static Future<void> init() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     // 🔔 Permission
//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // 📌 Initial token
//     String? token = await messaging.getToken();
//     if (token != null) {
//       _sendToBackend(token);
//     }

//     // 🔥 Token refresh listener (MAIN FIX)
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//       debugPrint("🔁 FCM Token refreshed: $newToken");
//       _sendToBackend(newToken);
//     });
//   }

//   static Future<void> _sendToBackend(String token) async {
//     if (!Preference.isLoggedIn) return;

//     await NotificationService.to.updateFcmToken(
//       token: token,
//       platform: Platform.isIOS ? 'ios' : 'android',
//     );
//   }
// }
