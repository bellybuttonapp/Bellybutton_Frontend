// ignore_for_file: avoid_print, strict_top_level_inference

import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import '../core/utils/helpers/dimensions.dart';

class FirebaseApi {
  static final FirebaseApi _singleton = FirebaseApi._internal();

  factory FirebaseApi() {
    return _singleton;
  }

  FirebaseApi._internal();

  /// ------------------------------------------------------
  ///  1. Initialize Firebase + Request Notification Permission
  /// ------------------------------------------------------
  static Future<void> initialize() async {
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp();
    print('🔥 Firebase initialized.');

    await _requestNotificationPermission();

    // Foreground listener
    _foregroundMessageListener();
  }

  /// ------------------------------------------------------
  /// 2. Request OS-level Notification Permission
  /// ------------------------------------------------------
  static Future<void> _requestNotificationPermission() async {
    if (Platform.isIOS) {
      print('📱 Requesting iOS notification permissions...');
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('📱 iOS notification permissions granted.');
    } else {
      print('🤖 Requesting Android notification permissions...');
      await FirebaseMessaging.instance.requestPermission(
        sound: true,
        badge: true,
      );
      print('🤖 Android notification permissions granted.');
    }
  }

  /// ------------------------------------------------------
  /// 3. Foreground Message Listener
  /// ------------------------------------------------------
  static void _foregroundMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Received foreground message: ${message.messageId}');
      inAppNotificationView(message);
    });
  }

  /// ------------------------------------------------------
  /// 4. Get device FCM token
  /// ------------------------------------------------------
  static Future<String?> getDeviceToken() async {
    print('🔑 Fetching FCM device token...');
    String? token = await FirebaseMessaging.instance.getToken();
    print('🔥 Device token: $token');
    return token;
  }

  /// ------------------------------------------------------
  /// 5. Notification Tap Listener
  /// ------------------------------------------------------
  static void setupFirebaseMessaging() async {
    print('🟡 Setting up Firebase Messaging listeners...');

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🟢 Notification tapped: ${message.messageId}');
   
    });

    print('🟢 Firebase Messaging listeners setup complete.');
  }

  /// ------------------------------------------------------
  /// 6. Topic Subscribe / Unsubscribe
  /// ------------------------------------------------------
  static void subscribeToTopic(String topic) {
    print('📌 Subscribing to topic: $topic');
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static void unsubscribeFromTopic(String topic) {
    print('❌ Unsubscribing from topic: $topic');
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}

/// ------------------------------------------------------
/// IN-APP POPUP NOTIFICATION UI
/// ------------------------------------------------------
inAppNotificationView(RemoteMessage message) {
  print('🟦 Displaying in-app notification...');

  return InAppNotifications.show(
    title: message.notification?.title ?? '',
    description: message.notification?.body ?? '',
    leading: Icon(
      Icons.message,
      color: Colors.green,
      size: Dimensions.PADDING_SIZE_OVER_LARGE,
    ),
    onTap: () {
      print('🟢 In-app notification tapped.');
      
    },
  );
}
