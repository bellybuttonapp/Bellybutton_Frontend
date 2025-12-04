// ignore_for_file: avoid_print, strict_top_level_inference

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:get/get.dart';

/// =============================================================
/// BACKGROUND HANDLER (MUST BE TOP LEVEL)
/// =============================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  try {
    print('🌙 [background] Message: ${message.messageId}');

    final FlutterLocalNotificationsPlugin bgLocal =
        FlutterLocalNotificationsPlugin();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    await bgLocal.initialize(
      const InitializationSettings(android: androidInit),
    );

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'App Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    await bgLocal.show(
      message.hashCode & 0x7fffffff,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  } catch (e) {
    print('⚠️ Background error: $e');
  }
}

/// =============================================================
/// FIREBASE NOTIFICATION SERVICE
/// =============================================================
class FirebaseNotificationService {
  FirebaseNotificationService._();
  static final _instance = FirebaseNotificationService._();
  factory FirebaseNotificationService() => _instance;

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// =============================================================
  /// MAIN INIT FUNCTION (called inside main BEFORE runApp)
  /// =============================================================
  static Future<void> init() async {
    print('🔥 FirebaseNotificationService.init() start');

    await _requestPermission();
    await _initLocalNotifications();
    await _createNotificationChannel();

    _setupForegroundListener();
    _setupOnMessageOpenedAppListener();
    await _handleInitialMessageIfAny();

    print('🔥 FirebaseNotificationService.init() done');
  }

  /// =============================================================
  /// PUBLIC: Initialize Local Notifications AFTER runApp
  /// =============================================================
  static Future<void> initLocalNotifications() async {
    await _initLocalNotifications();
  }

  /// =============================================================
  /// PERMISSIONS
  /// =============================================================
  static Future<void> _requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print("🔔 Permission: ${settings.authorizationStatus}");
    } catch (e) {
      print("⚠️ Permission error: $e");
    }
  }

  /// =============================================================
  /// LOCAL NOTIFICATION INITIALIZATION
  /// =============================================================
  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    final initSettings = InitializationSettings(android: androidInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handlePayloadTap(response.payload);
      },
    );
  }

  /// =============================================================
  /// ANDROID NOTIFICATION CHANNEL
  /// =============================================================
  static Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'default_channel',
      'App Notifications',
      importance: Importance.max,
    );

    final plugin =
        _local
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (plugin != null) {
      await plugin.createNotificationChannel(channel);
    }
  }

  /// =============================================================
  /// FOREGROUND NOTIFICATIONS
  /// =============================================================
  static void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((message) async {
      print("📩 Foreground: ${message.messageId}");

      await _showLocalNotification(message);
      _showInAppBanner(message);
    });
  }

  /// =============================================================
  /// BACKGROUND TAP HANDLER
  /// =============================================================
  static void _setupOnMessageOpenedAppListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("🟢 Tapped (background): ${message.messageId}");
      _navigateOnMessageTap(message);
    });
  }

  /// =============================================================
  /// TERMINATED STATE HANDLER
  /// =============================================================
  static Future<void> _handleInitialMessageIfAny() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      Future.microtask(() => _navigateOnMessageTap(message));
    }
  }

  /// =============================================================
  /// SHOW LOCAL NOTIFICATION
  /// =============================================================
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'App Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _local.show(
      message.hashCode & 0x7fffffff,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: message.data.toString(),
    );
  }

  /// =============================================================
  /// IN-APP BANNER
  /// =============================================================
  static void _showInAppBanner(RemoteMessage message) {
    try {
      InAppNotifications.show(
        title: message.notification?.title ?? '',
        description: message.notification?.body ?? '',
        leading: const Icon(Icons.notifications, color: Colors.white),
        onTap: () => _navigateOnMessageTap(message),
      );
    } catch (e) {
      print("⚠️ InApp banner error: $e");
    }
  }

  /// =============================================================
  /// NAVIGATION ON TAP
  /// =============================================================
  static void _navigateOnMessageTap(RemoteMessage message) {
    final screen = message.data['screen'] ?? message.data['route'];

    if (screen != null) {
      Get.toNamed(screen.toString());
    } else {
      Get.toNamed('/home');
    }
  }

  /// =============================================================
  /// PAYLOAD TAP HANDLER
  /// =============================================================
  static void _handlePayloadTap(String? payload) {
    if (payload == null) return;

    if (payload.contains("screen")) {
      final cleaned = payload.replaceAll(RegExp(r"[{} ]"), "");
      final parts = cleaned.split(',');

      for (var p in parts) {
        if (p.startsWith("screen")) {
          final screen = p.split(":")[1];
          Get.toNamed(screen);
        }
      }
    }
  }

  /// =============================================================
  /// GET DEVICE TOKEN
  /// =============================================================
  static Future<String?> getDeviceToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
