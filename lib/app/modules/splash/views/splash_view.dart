import 'package:bellybutton/app/core/constants/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../../../core/services/deep_link_service.dart';
import '../../../core/utils/storage/preference.dart';
import '../../../routes/app_pages.dart';
import '../controllers/splash_controller.dart';
import '../../SharedEventGallery/controllers/shared_event_gallery_controller.dart';

/// Splash screen that handles app initialization and deep link navigation.
/// Uses StatefulWidget to avoid GetX lifecycle issues during cold start.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    debugPrint('📱 SplashView: initState');

    // Schedule navigation after the first frame is rendered
    SchedulerBinding.instance.addPostFrameCallback((_) {
      debugPrint('📱 SplashView: First frame rendered, scheduling navigation');
      _scheduleNavigation();
    });
  }

  void _scheduleNavigation() {
    // Wait for splash animation (5 seconds)
    Future.delayed(const Duration(seconds: 5), () {
      if (!_hasNavigated && mounted) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    if (_hasNavigated) {
      debugPrint('⚠️ SplashView: Already navigated, skipping');
      return;
    }
    _hasNavigated = true;

    String nextRoute;
    dynamic arguments;

    // Get deep link info from SplashController static storage
    final hasPublicGalleryLink = SplashController.hasPublicGalleryLink;
    final publicGalleryToken = SplashController.publicGalleryToken;
    final hasJoinEventLink = SplashController.hasPendingJoinEventLink;
    final joinEventToken = SplashController.pendingJoinEventToken;

    debugPrint('📱 SplashView: Determining next route');
    debugPrint('📱 SplashView: hasPublicGalleryLink=$hasPublicGalleryLink, publicGalleryToken=$publicGalleryToken');
    debugPrint('📱 SplashView: hasJoinEventLink=$hasJoinEventLink, joinEventToken=$joinEventToken');
    debugPrint('📱 SplashView: isLoggedIn=${Preference.isLoggedIn}, onboardingComplete=${Preference.onboardingComplete}');

    // Handle public gallery deep link (no auth required)
    if (hasPublicGalleryLink && publicGalleryToken != null) {
      debugPrint('📸 Public gallery link detected on cold start');
      SharedEventGalleryController.pendingToken = publicGalleryToken;
      nextRoute = Routes.SHARED_EVENT_GALLERY;
      arguments = publicGalleryToken;
    }
    // Handle join event deep link
    else if (hasJoinEventLink) {
      debugPrint('📨 Join event link detected on cold start');

      if (Preference.isLoggedIn) {
        debugPrint('✅ User logged in, navigating to DASHBOARD');
        nextRoute = Routes.DASHBOARD;
      } else {
        debugPrint('⚠️ User not logged in, redirecting to PHONE_LOGIN');
        DeepLinkService.storePendingJoinEventToken(joinEventToken);
        nextRoute = Routes.PHONE_LOGIN;
      }
    }
    // Normal flow
    else if (Preference.isLoggedIn) {
      debugPrint('🚀 Navigating to DASHBOARD');
      nextRoute = Routes.DASHBOARD;
    } else if (Preference.onboardingComplete) {
      debugPrint('🚀 Navigating to PHONE_LOGIN');
      nextRoute = Routes.PHONE_LOGIN;
    } else {
      debugPrint('🚀 Navigating to ONBOARDING');
      nextRoute = Routes.ONBOARDING;
    }

    debugPrint('🚀 Executing navigation to: $nextRoute');

    // Clear the deep link info after determining route
    SplashController.clearDeepLinkInfo();

    // Use SchedulerBinding to ensure we navigate after the current frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _performNavigation(nextRoute, arguments);
    });
  }

  void _performNavigation(String route, dynamic arguments) {
    if (!mounted) {
      debugPrint('⚠️ SplashView: Widget not mounted, skipping navigation');
      return;
    }

    try {
      debugPrint('🚀 SplashView: Performing navigation to $route');
      if (arguments != null) {
        Get.offAllNamed(route, arguments: arguments);
      } else {
        Get.offAllNamed(route);
      }
    } catch (e) {
      debugPrint('❌ SplashView: Navigation error: $e');
      // Retry after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          try {
            debugPrint('🔄 SplashView: Retrying navigation to $route');
            if (arguments != null) {
              Get.offAllNamed(route, arguments: arguments);
            } else {
              Get.offAllNamed(route);
            }
          } catch (e2) {
            debugPrint('❌ SplashView: Retry failed: $e2');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B17),
      body: Center(
        child: Image.asset(
          AppAnimations.SPLASH_GIF,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
