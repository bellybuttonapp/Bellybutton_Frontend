// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:app_links/app_links.dart';
import '../../../database/models/EventModel.dart';
import '../../../routes/app_pages.dart';
import '../../constants/app_texts.dart';
import '../../services/app_badge_service.dart';
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

  /// Check for initial deep link on cold start
  static Future<DeepLinkInfo> checkInitialDeepLink() async {
    debugPrint('📱 [EARLY] Checking for deep link... isLoggedIn: ${Preference.isLoggedIn}');

    try {
      final appLinks = AppLinks();
      final initialDeepLink = await appLinks.getInitialLink();

      if (initialDeepLink == null) {
        return DeepLinkInfo();
      }

      debugPrint('📱 [EARLY] Deep link found: $initialDeepLink');

      // Check for public gallery link (no auth required)
      final publicToken = _extractPublicGalleryToken(initialDeepLink);
      if (publicToken != null) {
        debugPrint('📸 [EARLY] Public gallery link detected, token: $publicToken');
        ShowcaseService.hasPendingDeepLink = true;
        return DeepLinkInfo(publicGalleryToken: publicToken);
      }

      debugPrint('📱 [EARLY] No special deep link handling needed');
    } catch (e) {
      debugPrint('⚠️ [EARLY] Error checking initial deep link: $e');
    }

    return DeepLinkInfo();
  }

  /// Extract public gallery token from deep link
  static String? _extractPublicGalleryToken(Uri uri) {
    // Format 1: https://mobapidev.bellybutton.global/api/public/event/gallery/{token}
    if (uri.path.contains('public/event/gallery')) {
      final token = uri.pathSegments.last;
      return token.isNotEmpty ? token : null;
    }

    // Format 2: bellybutton://public/gallery/{token}
    if (uri.scheme == 'bellybutton' &&
        uri.host == 'public' &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments[0] == 'gallery' &&
        uri.pathSegments.length >= 2) {
      return uri.pathSegments[1];
    }

    return null;
  }

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
    // Custom error handler to suppress known navigation timing errors
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorString = details.exception.toString();

      // Suppress known deep link cold-start errors
      if (_isKnownNavigationError(errorString)) {
        debugPrint('⚠️ Suppressing known navigation timing error: ${details.exception.runtimeType}');
        return;
      }

      // Report all other errors to Crashlytics
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // In release mode, show friendly error screen
    if (!kDebugMode) {
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return CustomErrorWidget(
          errorDetails: details,
          message: AppTexts.ERROR_CRASH_MESSAGE,
        );
      };
    }

    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  /// Check if error is a known navigation timing error
  static bool _isKnownNavigationError(String errorString) {
    return errorString.contains('_elements.contains(element)') ||
        errorString.contains('!_debugLocked') ||
        errorString.contains('deactivated widget') ||
        errorString.contains('Looking up a deactivated') ||
        errorString.contains('setState() or markNeedsBuild()') ||
        errorString.contains('RenderBox was not laid out');
  }

  /// Initialize notification services
  static Future<void> initializeNotifications() async {
    // Local notifications with daily scheduling
    await LocalNotificationService.init();
    await LocalNotificationService.scheduleRandomTwoDaily();
  }

  /// Initialize app services (connectivity, badges, etc.)
  static Future<void> initializeAppServices() async {
    await AppInitializer.initialize();
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

  DeepLinkInfo({
    this.publicGalleryToken,
  });
}
