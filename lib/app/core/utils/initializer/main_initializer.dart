// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
// app_links removed - causes cold start crash
import '../../../database/models/EventModel.dart';
import '../../../routes/app_pages.dart';
import '../../constants/app_texts.dart';
import '../../services/app_badge_service.dart';
import '../../services/cache_manager_service.dart';
import '../../services/event_invitations_service.dart';
import '../../services/local_notification_service.dart';
import '../../services/notification_service.dart';
import '../../services/showcase_service.dart';
import '../storage/preference.dart';
import '../../../global_widgets/ErrorWidget/custom_error_widget.dart';
import '../../../modules/SharedEventGallery/controllers/shared_event_gallery_controller.dart';
import '../../../../firebase_options.dart';
import 'app_initializer.dart';


/// ----------------------------------------------------------
/// MAIN APP INITIALIZER
/// Handles all initialization logic for the app startup
/// ----------------------------------------------------------
class MainInitializer {
  /// Initialize Hive local storage
  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(EventModelAdapter());

    final hiveBox = await Hive.openBox('appBox');
    await Hive.openBox<EventModel>('eventsBox');

    Preference.init(hiveBox);
    Get.put(hiveBox);
    debugPrint('✅ Hive Initialized');
  }

  // Deep link checking is now done in main.dart using native platform channel
  // to avoid the app_links cold start crash

  /// Initialize Firebase services
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('✅ Firebase Initialized');

    // Activate Firebase App Check
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
  }

  /// Configure error handling for Flutter and Crashlytics
  static void configureErrorHandling() {
    // Send Flutter errors to Crashlytics
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Custom error widget for release mode
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (!kDebugMode) {
        return CustomErrorWidget(
          errorDetails: details,
          message: AppTexts.ERROR_CRASH_MESSAGE,
        );
      }
      return ErrorWidget(details.exception);
    };

    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  /// Initialize notification services
  static Future<void> initializeNotifications() async {
    // Local notifications with daily scheduling
    await LocalNotificationService.init();
    await LocalNotificationService.scheduleRandomTwoDaily();
  }

  /// Initialize app services (connectivity, badges, cache, etc.)
  static Future<void> initializeAppServices() async {
    await AppInitializer.initialize();
    await Get.putAsync(() => CacheManagerService().init());
    await Get.putAsync(() => AppBadgeService().init());
    await Get.putAsync(() => NotificationService().init());
    await Get.putAsync(() => EventInvitationsService().init());
  }

  /// Configure UI settings (orientation, status bar)
  static Future<void> configureUI() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF070B17),
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// Get initial route based on deep link info and auth state
  static String getInitialRoute(DeepLinkInfo info) {
    if (info.publicGalleryToken != null) {
      SharedEventGalleryController.pendingToken = info.publicGalleryToken;
      debugPrint('📸 Starting directly with SHARED_EVENT_GALLERY for token: ${info.publicGalleryToken}');
      return Routes.SHARED_EVENT_GALLERY;
    }

    // Check auth state and onboarding completion
    if (Preference.isLoggedIn) {
      debugPrint('🚀 Initial route: DASHBOARD');
      return Routes.DASHBOARD;
    }

    // Not logged in - check if onboarding is complete
    if (Preference.onboardingComplete) {
      debugPrint('🚀 Initial route: PHONE_LOGIN (onboarding done)');
      return Routes.PHONE_LOGIN;
    }

    // First time user - show onboarding
    debugPrint('🚀 Initial route: ONBOARDING');
    return Routes.ONBOARDING;
  }
}

/// ----------------------------------------------------------
/// DEEP LINK INFO CONTAINER
/// ----------------------------------------------------------

/// Container for deep link information detected on cold start
class DeepLinkInfo {
  final String? publicGalleryToken;
  final String? joinEventToken;
  final bool hasJoinEventLink;

  DeepLinkInfo({
    this.publicGalleryToken,
    this.joinEventToken,
    this.hasJoinEventLink = false,
  });

  bool get hasDeepLink => publicGalleryToken != null || hasJoinEventLink;
}

