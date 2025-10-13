// ignore_for_file: avoid_print, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app/helper/app_permission.dart';

/// ✅ Handles essential app startup tasks — permissions, Firebase, Crashlytics, etc.
class AppInitializer {
  static Future<void> initialize() async {
    try {
      // Request necessary permissions
      await AppPermission.requestAllPermissions();

      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult != ConnectivityResult.none) {
        // Initialize Firebase / Crashlytics
        // await FirebaseApi.initialize(); // Uncomment if using Firebase API wrapper

        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          true,
        );
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
        debugPrint('✅ Firebase Crashlytics initialized');
      } else {
        debugPrint('⚠️ No internet connection. Firebase services skipped.');
      }
    } catch (e, stack) {
      debugPrint('❌ App initialization failed: $e');
      FirebaseCrashlytics.instance.recordError(e, stack);
    }
  }
}

/// 🧩 Monitors and logs app lifecycle changes globally.
class AppLifecycleHandler extends WidgetsBindingObserver {
  final void Function(AppLifecycleState state)? onStateChanged;

  AppLifecycleHandler({this.onStateChanged});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint("📱 App lifecycle changed → $state");

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("✅ App is visible and interactive.");
        break;
      case AppLifecycleState.inactive:
        debugPrint("⚠️ App is inactive (e.g., receiving a call or overlay).");
        break;
      case AppLifecycleState.paused:
        debugPrint("⏸️ App is in the background.");
        break;
      case AppLifecycleState.detached:
        debugPrint("🧩 App is detached from the Flutter engine.");
        break;
      case AppLifecycleState.hidden:
        debugPrint("👻 App is hidden (rare state, mostly on desktop/web).");
        break;
    }

    // Trigger callback if provided
    onStateChanged?.call(state);
  }
}
