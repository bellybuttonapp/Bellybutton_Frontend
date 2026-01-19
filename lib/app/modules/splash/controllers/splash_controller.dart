import 'package:flutter/material.dart';
import '../../../core/utils/initializer/main_initializer.dart';

/// SplashController - holds static deep link information.
/// The actual navigation is handled by SplashView (StatefulWidget).
class SplashController {
  /// Static deep link info set from main.dart before runApp
  static DeepLinkInfo? _deepLinkInfo;

  /// Set deep link info globally (called from main.dart before runApp)
  static void setGlobalDeepLinkInfo(DeepLinkInfo info) {
    _deepLinkInfo = info;
    debugPrint('📱 SplashController: Deep link info set - hasJoinEventLink: ${info.hasJoinEventLink}, joinEventToken: ${info.joinEventToken}');
  }

  /// Get the pending join event token
  static String? get pendingJoinEventToken => _deepLinkInfo?.joinEventToken;

  /// Check if there's a pending join event link
  static bool get hasPendingJoinEventLink => _deepLinkInfo?.hasJoinEventLink ?? false;

  /// Get the public gallery token
  static String? get publicGalleryToken => _deepLinkInfo?.publicGalleryToken;

  /// Check if there's a pending public gallery link
  static bool get hasPublicGalleryLink => _deepLinkInfo?.publicGalleryToken != null;

  /// Clear the deep link info after it's been processed
  static void clearDeepLinkInfo() {
    _deepLinkInfo = null;
    debugPrint('📱 SplashController: Deep link info cleared');
  }
}
