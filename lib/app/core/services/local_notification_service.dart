// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:io';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// ============================================================
  /// 🔥 Initialize (iOS + Android SAFE)
  /// ============================================================
  static Future<void> init() async {
    /// 🔴 Android-only permissions
    if (Platform.isAndroid) {
      await Permission.notification.request();

      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings, // ✅ REQUIRED
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (resp) {
        print("🔔 Notification Clicked → ${resp.payload}");
      },
    );

    tz.initializeTimeZones();
  }

  /// ============================================================
  /// 1️⃣ IMMEDIATE NOTIFICATION
  /// ============================================================
  static Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      _id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'local_basic',
          'Basic Notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
      payload: payload,
    );
  }

  /// ============================================================
  /// 2️⃣ RANDOM NOTIFICATIONS (2 PER DAY)
  /// ============================================================
  static Future<void> scheduleRandomTwoDaily({
    int minGapHours = 2,
    int maxGapHours = 6,
  }) async {
    if (Platform.isAndroid &&
        !await Permission.scheduleExactAlarm.isGranted) {
      print("⛔ Exact Alarm Permission Denied");
      return;
    }

    final random = Random();
    int totalMinutes = 0;

    for (int i = 0; i < 2; i++) {
      final gap = (minGapHours * 60) +
          random.nextInt((maxGapHours * 60) - (minGapHours * 60));

      totalMinutes += gap;
      final time = DateTime.now().add(Duration(minutes: totalMinutes));

      await schedule(
        title: _randomTitle(),
        body: _randomBody(),
        when: time,
      );
    }

    print("📌 TWO Random Notifications Scheduled");
  }

  /// ============================================================
  /// 3️⃣ SCHEDULED NOTIFICATION
  /// ============================================================
  static Future<void> schedule({
    required String title,
    required String body,
    required DateTime when,
  }) async {
    await _plugin.zonedSchedule(
      _id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'random_daily',
          'Random Daily Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static String _randomTitle() {
    const titles = [
      "Hey there 👋",
      "Quick Reminder ⚡",
      "Photo Time 📸",
      "Ping 🔔",
    ];
    return titles[Random().nextInt(titles.length)];
  }

  static String _randomBody() {
    const bodies = [
      "Upload a moment today!",
      "Revisit your memories ✨",
      "Share something new ❤️",
      "Photos might be waiting 👀",
    ];
    return bodies[Random().nextInt(bodies.length)];
  }

  static int get _id => DateTime.now().millisecondsSinceEpoch ~/ 1000;
}
