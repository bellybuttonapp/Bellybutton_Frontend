// ignore_for_file: avoid_print, strict_top_level_inference

import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';

import '../core/themes/dimensions.dart';

class FirebaseApi {
  static final FirebaseApi _singleton = FirebaseApi._internal();

  factory FirebaseApi() {
    return _singleton;
  }

  FirebaseApi._internal();

  // Initialize Firebase and configure Firebase Messaging
  static Future<void> initialize() async {
    print('Initializing Firebase...');
    await Firebase.initializeApp();
    // FirebaseMessaging.onBackgroundMessage(
        // FirebaseApi.firebaseMessagingBackgroundHandler);
    print('Firebase initialized.');

    // Configure foreground notification presentation options
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.messageId}');
      // handleForegroundMessage(message);
    });

    // Request notification permissions for iOS
    if (Platform.isIOS) {
      print('Requesting iOS notification permissions...');
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      print('iOS notification permissions granted.');
    } else if (Platform.isAndroid) {
      print('Requesting Android notification permissions...');
      await FirebaseMessaging.instance.requestPermission(
        sound: true,
        badge: true,
      );
      print('Android notification permissions granted.');
    } else {
      print('Requesting provisional notification permissions...');
      await FirebaseMessaging.instance.requestPermission(provisional: true);
      print('Provisional notification permissions granted.');
    }
  }

  // Get the device token for push notifications
  static Future<String?> getDeviceToken() async {
    print('Fetching device token...');
    String? token = await FirebaseMessaging.instance.getToken();
    print('Device token: $token');
    return token;
  }

  // Configure Firebase Messaging listeners
  static void setupFirebaseMessaging() async {
    print('Setting up Firebase Messaging listeners...');

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped: ${message.messageId}');
      // tapToMoveNotification(message);
    });
    print('Firebase Messaging listeners setup complete.');
  }

  // static void handleForegroundMessage(RemoteMessage message) async {
  //   print('Handling foreground message...');
  //   print('Message data: ${message.data}');
  //   MainController.instance.fetchNotifications();
  //   Map<String, dynamic> dataMap = json.decode(message.data["data"]);
  //   // Access the jobcard_id value
  //   int jobcardId = dataMap['jobcard_id'];
  //   // Print the jobcard_id value
  //   debugPrint('jobcard id...$jobcardId');
  //   if (jobcardId != 0) {
  //     await Get.find<VehiclesController>().getCustomerJobcard();
  //   }
  //   inAppNotificationView(message);
  // }

  // static void handleNotificationTap(RemoteMessage message) async {
  //   print('Handling notification tap...');
  //   MainController.instance.fetchNotifications();
  //   tapToMoveNotification(message);
  // }

  // static Future<void> firebaseMessagingBackgroundHandler(
  //     RemoteMessage message) async {
  //   print('Handling background message...');
  //   print('Message data: ${message.data}');
  //   MainController.instance.fetchNotifications();
  //   tapToMoveNotification(message);
  // }

  static void requestNotificationPermissions() {
    print('Requesting notification permissions...');
    FirebaseMessaging.instance.requestPermission();
  }

  static void subscribeToTopic(String topic) {
    print('Subscribing to topic: $topic');
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static void unsubscribeFromTopic(String topic) {
    print('Unsubscribing from topic: $topic');
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}

inAppNotificationView(RemoteMessage message) {
  print('Displaying in-app notification...');
  return InAppNotifications.show(
      title: message.notification?.title ?? '',
      leading: Icon(
        Icons.message,
        color: Colors.green,
        size: Dimensions.PADDING_SIZE_OVER_LARGE,
      ),
      description: message.notification?.body ?? '',
      onTap: () async {
        print('In-app notification tapped.');
        // tapToMoveNotification(message);
      });
}

// void tapToMoveNotification(RemoteMessage message) async {
//   print('Navigating on notification tap...');
//   MainController.instance.fetchNotifications();
//   print('jobcard id...${message.data["data"]}');
//   // Parse the JSON string into a Map
//   Map<String, dynamic> dataMap = json.decode(message.data["data"]);
//   // Access the jobcard_id value
//   int jobcardId = dataMap['jobcard_id'];
//   // Print the jobcard_id value
//   debugPrint('jobcard id...$jobcardId');
//   if (jobcardId != 0) {
//     await Get.find<VehiclesController>().getCustomerJobcard();
//   }
//   print('Navigating to notification view.');
//   Get.toNamed(Routes.NOTIFICATION);

//   Preference.isNotificaitonTapped = false;
// }
