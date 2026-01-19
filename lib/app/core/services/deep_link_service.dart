// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../api/PublicApiService.dart';
import '../../database/models/InvitedEventModel.dart';
import '../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../routes/app_pages.dart';
import '../constants/app_texts.dart';
import '../utils/storage/preference.dart';

/// Deep Link Service - handles deep links using native platform channel
/// No longer uses app_links package to avoid cold start crash
class DeepLinkService {
  static const _channel = MethodChannel('com.bellybutton.dev/deeplink');

  /// Stores pending deep link to process after login
  static Uri? _pendingDeepLink;

  /// Stores pending join event token for processing after login
  static String? _pendingJoinEventToken;

  /// Track if we're currently processing a deep link
  static bool _isProcessing = false;

  /// Track if initial deep link has already been processed
  static bool _initialLinkProcessed = false;

  /// Track the initial deep link URI to detect re-delivery
  static String? _initialDeepLinkString;

  /// Store pending join event token (called from main.dart for not-logged-in users)
  static void storePendingJoinEventToken(String? token) {
    _pendingJoinEventToken = token;
    print("📨 Stored pending join event token: $token");
  }

  /// Check if there's a pending join event token
  static bool get hasPendingJoinEventToken => _pendingJoinEventToken != null;

  /// Process pending join event token after login
  static Future<void> processPendingJoinEventToken() async {
    if (_pendingJoinEventToken != null) {
      print("📨 Processing pending join event token after login");
      _pendingJoinEventToken = null;
      await Get.offAllNamed(Routes.DASHBOARD);
    }
  }

  /// Mark join event link as handled on cold start
  static void markJoinEventLinkHandled() {
    _initialLinkProcessed = true;
    print("📨 Join event link marked as handled on cold start");
  }

  /// Set the initial deep link string (called from main.dart)
  static void setInitialDeepLink(String? link) {
    _initialDeepLinkString = link;
  }

  /// Initialize the service - listens for runtime deep links via platform channel
  static Future<void> init() async {
    try {
      print("📱 DeepLinkService.init() - Setting up runtime link listener");

      _initialLinkProcessed = true;

      // Listen for runtime deep links from native side
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onDeepLink') {
          final String? link = call.arguments as String?;
          if (link != null) {
            print("📱 Deep link received while running: $link");

            // Skip if this is the initial link being re-delivered
            if (_initialDeepLinkString != null && link == _initialDeepLinkString) {
              print("⏭️ Skipping initial link re-delivery");
              return;
            }

            _handleLink(Uri.parse(link));
          }
        }
      });

      print("✅ DeepLinkService initialized");
    } catch (e) {
      print("❌ DeepLink init failed: $e");
    }
  }

  /// Check and process any pending deep link after user logs in
  static Future<void> processPendingDeepLink() async {
    if (_pendingDeepLink != null && !_isProcessing) {
      final link = _pendingDeepLink;
      _pendingDeepLink = null;

      print("🔄 Processing pending deep link after login: $link");

      await Future.delayed(const Duration(milliseconds: 800));

      if (Get.currentRoute == Routes.DASHBOARD) {
        _handleLink(link!);
      } else {
        print("⚠️ Dashboard not ready, re-storing pending link");
        _pendingDeepLink = link;
      }
    }
  }

  /// Check if user is logged in, if not redirect to login
  static bool _ensureLoggedIn(Uri uri) {
    if (!Preference.isLoggedIn) {
      print("⚠️ User not logged in, storing pending deep link");
      _pendingDeepLink = uri;

      if (Get.currentRoute != Routes.PHONE_LOGIN && Get.currentRoute != Routes.LOGIN_OTP) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(Routes.PHONE_LOGIN);
        });
      }

      _showWarning(AppTexts.DEEPLINK_LOGIN_REQUIRED);
      return false;
    }
    return true;
  }

  /// Main Link Routing Logic
  static void _handleLink(Uri uri) {
    if (_isProcessing) {
      print("⚠️ Already processing a deep link, ignoring: $uri");
      return;
    }

    _isProcessing = true;

    print("🚀 DeepLink Triggered → $uri");
    print("📌 Path: ${uri.path}");
    print("📌 Segments: ${uri.pathSegments}");
    print("📌 Host: ${uri.host}");
    print("📌 Scheme: ${uri.scheme}");

    // Handle custom scheme links
    if (uri.scheme == 'bellybutton') {
      _handleCustomSchemeLink(uri);
      return;
    }

    // Handle join event links
    if (uri.path.contains("join/event")) {
      _handleJoinEventLink(uri);
      return;
    }

    // Handle public gallery links
    if (uri.path.contains("public/event/gallery")) {
      _handlePublicGalleryLink(uri);
      return;
    }

    // Handle share event links
    if (uri.path.contains("share/event/open")) {
      _handleShareLink(uri);
      return;
    }

    // Handle invite links
    if (uri.path.contains("invite")) {
      _handleInviteLink(uri);
      return;
    }

    print("ℹ️ Unhandled link format: $uri");
    _isProcessing = false;
  }

  /// Handle custom URL scheme links
  static void _handleCustomSchemeLink(Uri uri) {
    print("📱 Processing Custom Scheme Link...");

    final segments = uri.pathSegments;
    final host = uri.host;

    // Handle bellybutton://event/join/{token}
    if (host == 'event' && segments.isNotEmpty && segments[0] == 'join') {
      print("📨 Join event link detected via custom scheme");
      _isProcessing = false;
      return;
    }

    // Handle bellybutton://public/gallery/{token}
    if (host == 'public' && segments.length >= 2 && segments[0] == 'gallery') {
      final token = segments[1];
      print("🔑 Public Gallery Token: $token");
      Get.toNamed(Routes.SHARED_EVENT_GALLERY, arguments: token);
      _isProcessing = false;
      return;
    }

    if (!_ensureLoggedIn(uri)) {
      _isProcessing = false;
      return;
    }

    // Handle bellybutton://join/{eventId}
    if (segments.length >= 2 && segments[0] == 'join') {
      final eventId = segments[1];
      if (int.tryParse(eventId) != null) {
        _fetchAndNavigateToEvent(eventId);
        return;
      }
    }

    print("⚠️ Could not parse custom scheme link");
    _showError(AppTexts.DEEPLINK_INVALID_LINK);
    _isProcessing = false;
  }

  /// Fetch event by ID and navigate
  static Future<void> _fetchAndNavigateToEvent(String eventId) async {
    print("🔑 Fetching Event ID: $eventId");

    try {
      _showLoading();
      final response = await PublicApiService().viewEventById(int.parse(eventId));
      _dismissLoading();

      if (response["success"] == true || response["data"] != null) {
        final eventData = response["data"] ?? response;
        print("✅ Event found: ${eventData["title"]}");

        final invitedEvent = InvitedEventModel.fromJson(eventData);
        await _navigateToInvitedEventGallery(invitedEvent, "view-sync");
      } else {
        _showError(response["message"] ?? AppTexts.DEEPLINK_SHOOT_NOT_FOUND);
        _isProcessing = false;
      }
    } catch (e) {
      _dismissLoading();
      print("❌ Error fetching event: $e");
      _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN);
      _isProcessing = false;
    }
  }

  /// Navigate to InvitedEventGalleryView
  static Future<void> _navigateToInvitedEventGallery(
    InvitedEventModel event,
    String permission,
  ) async {
    print("🚀 Navigating to InvitedEventGallery → Event: ${event.title}");

    try {
      if (Get.currentRoute != Routes.DASHBOARD) {
        await Get.offAllNamed(Routes.DASHBOARD);
        await Future.delayed(const Duration(milliseconds: 600));
      }

      if (Get.currentRoute == Routes.DASHBOARD) {
        await Get.toNamed(Routes.INVITED_EVENT_GALLERY, arguments: event);
      } else {
        _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN);
      }
    } catch (e) {
      print("❌ Navigation error: $e");
      _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN);
    } finally {
      _isProcessing = false;
    }
  }

  /// Handle join event links
  static Future<void> _handleJoinEventLink(Uri uri) async {
    print("📨 Processing Join Event Link...");

    if (!_ensureLoggedIn(uri)) {
      _isProcessing = false;
      return;
    }

    try {
      await Get.offAllNamed(Routes.DASHBOARD);
      print("✅ Navigated to Dashboard");
    } catch (e) {
      print("❌ Error: $e");
      _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN);
    } finally {
      _isProcessing = false;
    }
  }

  /// Handle share event links
  static Future<void> _handleShareLink(Uri uri) async {
    print("📤 Processing Share Link...");

    if (!_ensureLoggedIn(uri)) {
      _isProcessing = false;
      return;
    }

    String? shareToken = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;

    if (shareToken == null || shareToken.isEmpty) {
      _showError(AppTexts.DEEPLINK_INVALID_SHARE_LINK);
      _isProcessing = false;
      return;
    }

    try {
      _showLoading();
      final response = await PublicApiService().openSharedEventByToken(shareToken);
      _dismissLoading();

      if (response["success"] == true && response["event"] != null) {
        final eventData = response["event"];
        final permission = response["permission"] ?? "view-only";
        final invitedEvent = InvitedEventModel.fromJson(eventData);

        if (Get.currentRoute != Routes.DASHBOARD) {
          await Get.offAllNamed(Routes.DASHBOARD);
          await Future.delayed(const Duration(milliseconds: 600));
        }

        await Get.toNamed(Routes.SHARED_EVENT_GALLERY, arguments: {
          "event": invitedEvent,
          "permission": permission,
        });
      } else {
        _showError(response["message"] ?? AppTexts.DEEPLINK_SHOOT_NOT_FOUND);
      }
    } catch (e) {
      _dismissLoading();
      _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN_SHARED);
    } finally {
      _isProcessing = false;
    }
  }

  /// Handle invite links
  static Future<void> _handleInviteLink(Uri uri) async {
    print("📨 Processing Invite Link...");

    if (!_ensureLoggedIn(uri)) {
      _isProcessing = false;
      return;
    }

    String? eventId = uri.pathSegments.length >= 2 ? uri.pathSegments.last : null;
    String permission = uri.queryParameters["permission"] ?? "view-only";

    if (eventId == null || int.tryParse(eventId) == null) {
      _showError(AppTexts.DEEPLINK_INVALID_INVITE_LINK);
      _isProcessing = false;
      return;
    }

    try {
      _showLoading();
      final response = await PublicApiService().viewEventById(int.parse(eventId));
      _dismissLoading();

      if (response["success"] == true || response["data"] != null) {
        final eventData = response["data"] ?? response;
        final invitedEvent = InvitedEventModel.fromJson(eventData);
        await _navigateToInvitedEventGallery(invitedEvent, permission);
      } else {
        _showError(AppTexts.DEEPLINK_SHOOT_NOT_FOUND);
        _isProcessing = false;
      }
    } catch (e) {
      _dismissLoading();
      _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN);
      _isProcessing = false;
    }
  }

  /// Handle public gallery links
  static Future<void> _handlePublicGalleryLink(Uri uri) async {
    print("📸 Processing Public Gallery Link...");

    String? token = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;

    if (token == null || token.isEmpty) {
      _showError(AppTexts.DEEPLINK_INVALID_LINK);
      _isProcessing = false;
      return;
    }

    try {
      await Get.toNamed(Routes.SHARED_EVENT_GALLERY, arguments: token);
    } catch (e) {
      _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN);
    } finally {
      _isProcessing = false;
    }
  }

  static void _showLoading() {
    if (Get.isDialogOpen == true) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: const Center(child: CircularProgressIndicator()),
          ),
          barrierDismissible: false,
        );
      }
    });
  }

  static void _dismissLoading() {
    if (Get.isDialogOpen == true) {
      try { Get.back(); } catch (_) {}
    }
  }

  static void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCustomSnackBar(message, SnackbarState.error);
    });
  }

  static void _showWarning(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCustomSnackBar(message, SnackbarState.warning);
    });
  }
}
