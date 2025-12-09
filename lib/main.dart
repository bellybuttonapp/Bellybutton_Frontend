// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:bellybutton/app/core/utils/storage/preference.dart';
import 'package:bellybutton/app/core/utils/initializer/app_initializer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/core/constants/app_colors.dart';
import 'app/core/services/local_notification_service.dart';
import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/database/models/EventModel.dart';
import 'app/core/services/firebase_notification_service.dart';

/// ----------------------------------------------------------
/// 1️⃣ BACKGROUND HANDLER — MUST BE TOP LEVEL
/// ----------------------------------------------------------
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("🌙 Background message received → ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// ----------------------------------------------------------
  /// 2️⃣ REGISTER BACKGROUND HANDLER (ONLY ONCE)
  /// ----------------------------------------------------------
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  /// ----------------------------------------------------------
  /// 3️⃣ LOCAL STORAGE (Hive + GetStorage)
  /// ----------------------------------------------------------
  await GetStorage.init();

  await Hive.initFlutter();
  Hive.registerAdapter(EventModelAdapter());

  final hiveBox = await Hive.openBox('appBox');
  await Hive.openBox<EventModel>('eventsBox');

  Preference.init(hiveBox);
  Get.put(hiveBox);
  debugPrint('✅ Hive Initialized');

  /// ----------------------------------------------------------
  /// 4️⃣ FIREBASE INIT
  /// ----------------------------------------------------------
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('✅ Firebase Initialized');

  if (kDebugMode) {
    debugPrint("📌 FCM Token: ${await FirebaseMessaging.instance.getToken()}");
  }

  /// ----------------------------------------------------------
  /// 5️⃣ Firebase App Check
  /// ----------------------------------------------------------
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
  );

  /// ----------------------------------------------------------
  /// 6️⃣ Crashlytics
  /// ----------------------------------------------------------
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

  /// ----------------------------------------------------------
  /// 7️⃣ FCM NOTIFICATION SYSTEM (Foreground / Tap / Terminated)
  /// ----------------------------------------------------------
  await FirebaseNotificationService.init();

  /// ----------------------------------------------------------
  /// LOCAL NOTIFICATIONS INIT + RANDOM DAILY TRIGGER
  /// ----------------------------------------------------------
  await LocalNotificationService.init();
  await LocalNotificationService.scheduleRandomTwoDaily();

  /// ----------------------------------------------------------
  /// 8️⃣ App Initializer (connectivity, etc.)
  /// ----------------------------------------------------------
  await AppInitializer.initialize();

  /// ----------------------------------------------------------
  /// 9️⃣ Orientation + Status Bar
  /// ----------------------------------------------------------
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppTheme.lightTheme.primaryColor,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  /// ----------------------------------------------------------
  /// 🔟 Start Page (Dashboard or Onboarding)
  /// ----------------------------------------------------------
  final initialRoute =
      Preference.isLoggedIn ? Routes.DASHBOARD : Routes.ONBOARDING;

  /// ----------------------------------------------------------
  /// 1️⃣1️⃣ RUN THE APP
  /// ----------------------------------------------------------
  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      themeMode: ThemeMode.light,
      darkTheme: ThemeData.dark(),
    ),
  );

  /// ----------------------------------------------------------
  /// 1️⃣2️⃣ Initialize Local Notifications AFTER UI builds
  /// ----------------------------------------------------------
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FirebaseNotificationService.initLocalNotifications();
  });
}
