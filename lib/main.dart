// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:ui';
import 'package:bellybutton/app/utils/preference.dart';
import 'package:bellybutton/app_initializer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/core/constants/app_colors.dart';
import 'app/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize GetStorage (optional)
      await GetStorage.init();
      // Initialize Hive
      await Hive.initFlutter();
      var hiveBox = await Hive.openBox('appBox');

      // Initialize Preference with Hive box ✅
      Preference.init(hiveBox);

      // Register Hive box in GetX
      Get.put<Box>(hiveBox);

      print('✅ Hive Initialized');

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase Initialized');

      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );

      // Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      // Determine initial route using Hive Preference
      String initialRoute =
          Preference.isLoggedIn ? Routes.DASHBOARD : Routes.ONBOARDING;

      // App services
      await AppInitializer.initialize();

      // Orientation Lock
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // System UI
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppTheme.lightTheme.primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
      );

      // Lifecycle observer
      WidgetsBinding.instance.addObserver(AppLifecycleHandler());
      runApp(
        GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Application",
          initialRoute: initialRoute,
          getPages: AppPages.routes,
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.light,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.trackpad,
            },
          ),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}
