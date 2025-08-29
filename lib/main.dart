// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:ui';
import 'package:bellybutton/app_initializer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/core/constants/app_colors.dart';
import 'app/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize local storage For Remember Me
      await GetStorage.init();

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase Initialized');

      // Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      // SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      Get.put<SharedPreferences>(prefs);

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
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
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
