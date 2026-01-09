// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'app/core/services/deep_link_service.dart';
import 'app/core/services/firebase_notification_service.dart';
import 'app/core/services/showcase_service.dart';
import 'app/core/utils/initializer/app_lifecycle_handler.dart';
import 'app/core/utils/initializer/main_initializer.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

/// ----------------------------------------------------------
/// BACKGROUND HANDLER — MUST BE TOP LEVEL
/// ----------------------------------------------------------
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("🌙 Background message received → ${message.messageId}");
}

/// ----------------------------------------------------------
/// MAIN ENTRY POINT
/// ----------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register Firebase background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize local storage (Hive)
  await MainInitializer.initializeHive();

  // Check for cold start deep links early
  final deepLinkInfo = await MainInitializer.checkInitialDeepLink();

  // Initialize Firebase services
  await MainInitializer.initializeFirebase();

  // Configure error handling
  MainInitializer.configureErrorHandling();

  // Initialize notification services
  await FirebaseNotificationService.init();
  await MainInitializer.initializeNotifications();

  // Initialize app services
  await MainInitializer.initializeAppServices();

  // Configure UI settings
  await MainInitializer.configureUI();

  // Determine initial route
  final initialRoute = MainInitializer.getInitialRoute(deepLinkInfo);

  // Register app lifecycle handler
  final lifecycleHandler = AppLifecycleHandler(
    onResumed: () => debugPrint('🟢 App resumed'),
    onPaused: () => debugPrint('🟡 App paused'),
  );
  lifecycleHandler.register();

  // Run the app
  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      themeMode: ThemeMode.light,
      darkTheme: ThemeData.dark(),
      builder: InAppNotifications.init(),
    ),
  );

  // Initialize post-frame services
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Initialize local notification UI
    FirebaseNotificationService.initLocalNotifications();

    // Initialize deep link service
    Future.delayed(const Duration(milliseconds: 1000), () {
      DeepLinkService.init();
    });

    // Handle public gallery deep link (no auth required)
    if (deepLinkInfo.publicGalleryToken != null) {
      _handlePublicGalleryDeepLink(deepLinkInfo.publicGalleryToken!);
    }
  });
}

/// Handle public gallery deep link navigation
void _handlePublicGalleryDeepLink(String token) {
  debugPrint('📸 Processing public gallery deep link after app init...');
  Future.delayed(const Duration(milliseconds: 1500), () {
    debugPrint('📸 Navigating to SHARED_EVENT_GALLERY with token: $token');
    ShowcaseService.hasPendingDeepLink = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.toNamed(Routes.SHARED_EVENT_GALLERY, arguments: token);
      }
    });
  });
}
