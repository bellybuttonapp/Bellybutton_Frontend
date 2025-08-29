// ignore_for_file: avoid_print, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app/helper/app_permission.dart';

class AppInitializer {
  /// Runs startup tasks like Permissions, Firebase, Crashlytics, etc.
  static Future<void> initialize() async {
    // ✅ Request Permissions
    await AppPermission.requestAllPermissions();

    // ✅ Check Connectivity before initializing Firebase services
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        // await FirebaseApi.initialize();

        // Crashlytics
        FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
        print('✅ Firebase services initialized');
      } catch (e) {
        debugPrint("⚠️ Firebase services init failed: $e");
      }
    } else {
      debugPrint('⚠️ No internet connection. Skipping Firebase services.');
    }
  }
}

class AppLifecycleHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("📱 App state: $state");
  }
}
