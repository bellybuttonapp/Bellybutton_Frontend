// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'app/core/services/deep_link_service.dart';
import 'app/core/services/firebase_notification_service.dart';
import 'app/core/utils/initializer/app_lifecycle_handler.dart';
import 'app/core/utils/initializer/main_initializer.dart';
import 'app/core/utils/storage/preference.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

/// Background handler - must be top level
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("🌙 Background message received → ${message.messageId}");
}

/// Store deep link URI detected on cold start
String? _coldStartDeepLink;

/// Main entry point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Hive first
  await MainInitializer.initializeHive();

  // Initialize Firebase
  await MainInitializer.initializeFirebase();

  // Check for deep link using platform channel BEFORE any widget builds
  // This avoids the app_links timing issue completely
  _coldStartDeepLink = await _getInitialDeepLinkNative();
  if (_coldStartDeepLink != null) {
    debugPrint('📱 Cold start deep link detected: $_coldStartDeepLink');
  }

  // Configure error handling
  MainInitializer.configureErrorHandling();

  // Configure UI first (orientation, status bar)
  await MainInitializer.configureUI();

  // If deep link detected, defer service initialization to avoid widget tree conflict
  if (_coldStartDeepLink == null) {
    // Normal startup - initialize all services before runApp
    await FirebaseNotificationService.init();
    await MainInitializer.initializeNotifications();
    await MainInitializer.initializeAppServices();
  } else {
    // Deep link cold start - defer service initialization to after runApp
    debugPrint('📱 Deep link detected - deferring service initialization');
  }

  // Register lifecycle handler
  final lifecycleHandler = AppLifecycleHandler(
    onResumed: () => debugPrint('🟢 App resumed'),
    onPaused: () => debugPrint('🟡 App paused'),
  );
  lifecycleHandler.register();

  debugPrint('📱 Starting app...');

  // Run the app
  runApp(const BellyButtonApp());

  // Initialize services AFTER app is running and widget tree is stable
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // If deep link cold start, initialize deferred services now
    if (_coldStartDeepLink != null) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        debugPrint('📱 Initializing deferred services...');
        await FirebaseNotificationService.init();
        await MainInitializer.initializeNotifications();
        await MainInitializer.initializeAppServices();
        FirebaseNotificationService.initLocalNotifications();

        // Request permission after longer delay
        Future.delayed(const Duration(milliseconds: 2000), () {
          FirebaseNotificationService.requestPermissionDeferred();
        });
      });
    } else {
      FirebaseNotificationService.initLocalNotifications();
      FirebaseNotificationService.requestPermissionDeferred();
    }

    // Initialize deep link service for runtime links
    Future.delayed(const Duration(milliseconds: 2000), () {
      DeepLinkService.init();
    });
  });
}

/// Get initial deep link using native platform channel
/// This avoids the app_links timing issue that causes widget tree corruption
Future<String?> _getInitialDeepLinkNative() async {
  try {
    const platform = MethodChannel('com.bellybutton.dev/deeplink');
    final String? link = await platform.invokeMethod('getInitialLink');
    return link;
  } catch (e) {
    debugPrint('⚠️ Native deep link check failed: $e');
    // Fallback: check launch intent data
    return null;
  }
}

/// Main App Widget - uses StatefulWidget for deep link cold start handling
class BellyButtonApp extends StatefulWidget {
  const BellyButtonApp({super.key});

  @override
  State<BellyButtonApp> createState() => _BellyButtonAppState();
}

class _BellyButtonAppState extends State<BellyButtonApp> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();

    // For deep link cold start, add extra delay before building GetMaterialApp
    if (_coldStartDeepLink != null) {
      debugPrint('📱 Deep link cold start - delaying GetMaterialApp build');
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() => _isReady = true);
        }
      });
    } else {
      _isReady = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show simple splash during delay
    if (!_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Container(color: const Color(0xFF070B17)),
      );
    }

    final route = _determineInitialRoute();
    debugPrint('📱 BellyButtonApp.build() - initialRoute: $route');

    return GetMaterialApp(
      title: "BellyButton",
      debugShowCheckedModeBanner: false,
      initialRoute: route,
      getPages: AppPages.routes,
      themeMode: ThemeMode.light,
      darkTheme: ThemeData.dark(),
      builder: InAppNotifications.init(),
    );
  }

  String _determineInitialRoute() {
    // If cold start deep link exists, skip splash and go directly to target
    if (_coldStartDeepLink != null && _coldStartDeepLink!.isNotEmpty) {
      debugPrint('📱 Deep link cold start - skipping splash');

      // Store deep link info for later processing
      _storeDeepLinkForProcessing(_coldStartDeepLink!);

      // Navigate based on auth state
      if (Preference.isLoggedIn) {
        debugPrint('📱 Initial route: DASHBOARD (logged in)');
        return Routes.DASHBOARD;
      } else if (Preference.onboardingComplete) {
        debugPrint('📱 Initial route: PHONE_LOGIN (onboarding done)');
        return Routes.PHONE_LOGIN;
      } else {
        debugPrint('📱 Initial route: ONBOARDING (first time)');
        return Routes.ONBOARDING;
      }
    }

    // Normal startup - go to splash
    debugPrint('📱 Initial route: SPLASH (no deep link)');
    return Routes.SPLASH;
  }

  void _storeDeepLinkForProcessing(String link) {
    try {
      final uri = Uri.parse(link);
      String? joinToken;

      // Extract join token from various formats
      if (uri.path.contains('join/event')) {
        joinToken = uri.pathSegments.last;
      } else if (uri.scheme == 'bellybutton' && uri.host == 'event') {
        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'join') {
          joinToken = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        }
      }

      if (joinToken != null) {
        debugPrint('📱 Stored join token: $joinToken');
        DeepLinkService.storePendingJoinEventToken(joinToken);
      }
    } catch (e) {
      debugPrint('⚠️ Error parsing deep link: $e');
    }
  }
}
