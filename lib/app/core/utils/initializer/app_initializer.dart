import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AppInitializer {
  static Future<void> initialize() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult.isNotEmpty &&
          !connectivityResult.contains(ConnectivityResult.none);

      if (hasConnection) {
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
