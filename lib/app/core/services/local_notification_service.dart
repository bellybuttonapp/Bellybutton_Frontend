// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:math';
import 'package:permission_handler/permission_handler.dart'; // REQUIRED
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// ============================================================
  /// 🔥 Initialize – MUST Request Permissions First
  /// ============================================================
  static Future<void> init() async {
    // Android 13+ Notification Permission
    await Permission.notification.request();

    // Android Exact Alarm Permission (REQUIRED for scheduled)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (resp) {
        print("🔔 Notification Clicked → ${resp.payload}");
      },
    );

    tz.initializeTimeZones(); // 🔥 REQUIRED for scheduling
  }

  /// ============================================================
  /// 1️⃣ BASIC NOTIFICATION (Immediate)
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
      ),
      payload: payload,
    );
  }

  /// ============================================================
  /// 2️⃣ RANDOM NOTIFICATIONS — 2 Per Day
  /// ============================================================
  static Future<void> scheduleRandomTwoDaily({
    int minGapHours = 2,
    int maxGapHours = 6,
  }) async {
    // 🚨 Prevent crash if permission not allowed
    if (!await Permission.scheduleExactAlarm.isGranted) {
      print("⛔ Exact Alarm Permission Denied – Scheduling Blocked");
      return;
    }

    final random = Random();
    int totalMinutes = 0;

    for (int i = 0; i < 2; i++) {
      int gap =
          (minGapHours * 60) +
          random.nextInt((maxGapHours * 60) - (minGapHours * 60));

      totalMinutes += gap;

      final time = DateTime.now().add(Duration(minutes: totalMinutes));

      await schedule(title: _randomTitle(), body: _randomBody(), when: time);
    }

    print("📌 TWO Random Notifications Scheduled Today 🚀");
  }

  /// ============================================================
  /// 3️⃣ SCHEDULER — WORKS EVEN IN TERMINATED MODE
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
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 🔥 Key
      matchDateTimeComponents: null,
    );
  }

  // Random title
  static String _randomTitle() {
    const titles = [
      "Hey there 👋",
      "Quick Reminder ⚡",
      "Photo Time 📸",
      "Ping 🔔",
    ];
    return titles[Random().nextInt(titles.length)];
  }

  // Random body
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
