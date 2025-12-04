// ignore_for_file: avoid_print, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AppInitializer {
  static Future<void> initialize() async {
    try {
      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult != ConnectivityResult.none) {
        debugPrint('🌐 Connected → AppInitializer basic setup completed.');
      } else {
        debugPrint('⚠️ No internet connection. Firebase services skipped.');
      }
    } catch (e, stack) {
      debugPrint('❌ AppInitializer failed: $e');
      FirebaseCrashlytics.instance.recordError(e, stack);
    }
  }
}

class AppLifecycleHandler extends WidgetsBindingObserver {
  final void Function(AppLifecycleState state)? onStateChanged;

  AppLifecycleHandler({this.onStateChanged});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("📱 App lifecycle changed → $state");
    onStateChanged?.call(state);
  }
}
