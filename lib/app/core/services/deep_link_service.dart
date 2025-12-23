// ignore_for_file: avoid_print, deprecated_member_use

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/PublicApiService.dart';
import '../../database/models/InvitedEventModel.dart';
import '../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../routes/app_pages.dart';
import '../constants/app_texts.dart';
import '../utils/storage/preference.dart';

class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();

  /// Stores pending deep link to process after login
  static Uri? _pendingDeepLink;

  /// Track if we're currently processing a deep link
  static bool _isProcessing = false;

  /// MUST be called in main() after runApp() or in initial binding
  static Future<void> init() async {
    try {
      // 🔥 Handle link when app opened from terminated state
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        print("📱 Initial link detected: $initialLink");
        // Wait for app to be fully ready before processing
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (Get.context != null) {
              _handleLink(initialLink);
            } else {
              print("⚠️ Context not ready, storing link as pending");
              _pendingDeepLink = initialLink;
            }
          });
        });
      }

      // 🔥 Handle links when app is running (foreground/background)
      _appLinks.uriLinkStream.listen(
        (uri) {
          print("📱 Deep link received while running: $uri");
          _handleLink(uri);
        },
        onError: (err) => print("❌ DeepLink Stream Error: $err"),
      );

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

      // Wait for dashboard to be fully loaded
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

      // Navigate to login if not already there
      if (Get.currentRoute != Routes.LOGIN && Get.currentRoute != Routes.ONBOARDING) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(Routes.LOGIN);
        });
      }

      _showWarning(AppTexts.DEEPLINK_LOGIN_REQUIRED);
      return false;
    }
    return true;
  }

  /// Navigate to InvitedEventGalleryView with proper arguments
  static Future<void> _navigateToInvitedEventGallery(
    InvitedEventModel event,
    String permission,
  ) async {
    print("🚀 Navigating to InvitedEventGallery → Event: ${event.title}");

    try {
      // Ensure we're on dashboard first
      if (Get.currentRoute != Routes.DASHBOARD) {
        print("📍 Not on dashboard, navigating there first...");
        await Get.offAllNamed(Routes.DASHBOARD);

        // Wait for dashboard to initialize and render
        await Future.delayed(const Duration(milliseconds: 600));
      }

      // Verify we're on the dashboard before proceeding
      if (Get.currentRoute == Routes.DASHBOARD) {
        print("✅ Dashboard ready, navigating to event gallery");
        await Get.toNamed(
          Routes.INVITED_EVENT_GALLERY,
          arguments: event,
        );
      } else {
        print("❌ Failed to navigate to dashboard");
        _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN);
      }
    } catch (e) {
      print("❌ Navigation error: $e");
      _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN);
    } finally {
      _isProcessing = false;
    }
  }

  /// Navigate to SharedEventGalleryView with event and permission
  static Future<void> _navigateToSharedEventGallery(
    InvitedEventModel event,
    String permission,
  ) async {
    print("🚀 Navigating to SharedEventGallery → Event: ${event.title}, Permission: $permission");

    try {
      // Ensure we're on dashboard first
      if (Get.currentRoute != Routes.DASHBOARD) {
        print("📍 Not on dashboard, navigating there first...");
        await Get.offAllNamed(Routes.DASHBOARD);

        // Wait for dashboard to initialize and render
        await Future.delayed(const Duration(milliseconds: 600));
      }

      // Verify we're on the dashboard before proceeding
      if (Get.currentRoute == Routes.DASHBOARD) {
        print("✅ Dashboard ready, navigating to shared event gallery");
        await Get.toNamed(
          Routes.SHARED_EVENT_GALLERY,
          arguments: {
            "event": event,
            "permission": permission,
          },
        );
      } else {
        print("❌ Failed to navigate to dashboard");
        _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN);
      }
    } catch (e) {
      print("❌ Navigation error: $e");
      _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN_SHARED);
    } finally {
      _isProcessing = false;
    }
  }

  /// Main Link Routing Logic
  static void _handleLink(Uri uri) {
    // Prevent concurrent processing
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

    // Handle custom scheme links (fallback from HTML redirect page)
    // Format: bellybutton://event/join/{eventId}
    if (uri.scheme == 'bellybutton') {
      _handleCustomSchemeLink(uri);
      return;
    }

    // Handle join event links (from SMS/Email invitations)
    // Format: https://mobapidev.bellybutton.global/api/eventresource/join/event/{eventId}
    if (uri.path.contains("join/event")) {
      _handleJoinEventLink(uri);
      return;
    }

    // Handle share event links
    // Format: https://mobapidev.bellybutton.global/api/eventresource/share/event/open/{shareToken}
    // Format: http://54.90.159.46:8080/api/eventresource/share/event/open/{shareToken}
    if (uri.path.contains("share/event/open")) {
      _handleShareLink(uri);
      return;
    }

    // Handle invite links
    // Format: https://bellybutton.app/invite/{eventId}
    if (uri.path.contains("invite")) {
      _handleInviteLink(uri);
      return;
    }

    print("ℹ️ Unhandled link format: $uri");
    _isProcessing = false;
  }

  /// Handle custom URL scheme links
  /// Format: bellybutton://event/join/{eventId}
  static void _handleCustomSchemeLink(Uri uri) {
    print("📱 Processing Custom Scheme Link...");

    // Check if user is logged in
    if (!_ensureLoggedIn(uri)) {
      _isProcessing = false;
      return;
    }

    final segments = uri.pathSegments;
    print("📌 Custom scheme segments: $segments");

    // Handle bellybutton://event/join/{eventId}
    if (segments.length >= 2 && segments[0] == 'join') {
      final eventId = segments[1];
      if (int.tryParse(eventId) != null) {
        _fetchAndNavigateToEvent(eventId);
        return;
      }
    }

    // Handle bellybutton://event/{eventId} (legacy format)
    if (segments.isNotEmpty) {
      final eventId = segments.last;
      if (int.tryParse(eventId) != null) {
        _fetchAndNavigateToEvent(eventId);
        return;
      }
    }

    print("⚠️ Could not parse custom scheme link");
    _showError(AppTexts.DEEPLINK_INVALID_LINK);
    _isProcessing = false;
  }

  /// Fetch event by ID and navigate to gallery
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

        // Navigate to InvitedEventGalleryView
        await _navigateToInvitedEventGallery(invitedEvent, "view-sync");
      } else {
        _showError(response["message"] ?? AppTexts.DEEPLINK_EVENT_NOT_FOUND);
        _isProcessing = false;
      }
    } catch (e) {
      _dismissLoading();
      print("❌ Error fetching event: $e");
      _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN);
      _isProcessing = false;
    }
  }

  /// Handle join event links (from SMS/Email invitations)
  static Future<void> _handleJoinEventLink(Uri uri) async {
    print("📨 Processing Join Event Link...");

    // Check if user is logged in
    if (!_ensureLoggedIn(uri)) {
      _isProcessing = false;
      return;
    }

    // Extract event ID from path
    // Path: /api/eventresource/join/event/256
    String? eventId;

    final segments = uri.pathSegments;
    // Find "event" segment and get the next one as eventId
    for (int i = 0; i < segments.length - 1; i++) {
      if (segments[i] == "event") {
        eventId = segments[i + 1];
        break;
      }
    }

    if (eventId == null || int.tryParse(eventId) == null) {
      print("⚠️ Event ID not found in join link");
      _showError(AppTexts.DEEPLINK_INVALID_LINK);
      _isProcessing = false;
      return;
    }

    print("🔑 Event ID: $eventId");

    try {
      _showLoading();

      // Fetch event details
      final response = await PublicApiService().viewEventById(int.parse(eventId));

      _dismissLoading();

      if (response["success"] == true || response["data"] != null) {
        final eventData = response["data"] ?? response;

        print("✅ Event found: ${eventData["title"]}");

        // Convert to InvitedEventModel and navigate
        final invitedEvent = InvitedEventModel.fromJson(eventData);

        // Navigate to InvitedEventGalleryView
        await _navigateToInvitedEventGallery(invitedEvent, "view-sync");
      } else {
        _showError(response["message"] ?? AppTexts.DEEPLINK_EVENT_NOT_FOUND);
        _isProcessing = false;
      }
    } catch (e) {
      _dismissLoading();
      print("❌ Error opening join link: $e");
      _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN);
      _isProcessing = false;
    }
  }

  /// Handle shared event links (from share API)
  static Future<void> _handleShareLink(Uri uri) async {
    print("📤 Processing Share Link...");

    // Check if user is logged in
    if (!_ensureLoggedIn(uri)) {
      _isProcessing = false;
      return;
    }

    // Extract share token from path
    // Path: /api/eventresource/share/event/open/abc123xyz
    String? shareToken;

    if (uri.pathSegments.isNotEmpty) {
      shareToken = uri.pathSegments.last;
    }

    if (shareToken == null || shareToken.isEmpty) {
      print("⚠️ Share token not found in link");
      _showError(AppTexts.DEEPLINK_INVALID_SHARE_LINK);
      _isProcessing = false;
      return;
    }

    print("🔑 Share Token: $shareToken");

    try {
      _showLoading();

      // Call API to get event data from share token
      final response = await PublicApiService().openSharedEventByToken(shareToken);

      _dismissLoading();

      if (response["success"] == true && response["event"] != null) {
        final eventData = response["event"];
        final permission = response["permission"] ?? "view-only";

        print("✅ Event found: ${eventData["title"]}");
        print("📌 Permission: $permission");

        // Convert to InvitedEventModel and navigate
        final invitedEvent = InvitedEventModel.fromJson(eventData);

        // Navigate to SharedEventGalleryView (with permission-based UI)
        await _navigateToSharedEventGallery(invitedEvent, permission);
      } else {
        _showError(response["message"] ?? AppTexts.DEEPLINK_EVENT_NOT_FOUND);
        _isProcessing = false;
      }
    } catch (e) {
      _dismissLoading();
      print("❌ Error opening share link: $e");
      _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN_SHARED);
      _isProcessing = false;
    }
  }

  /// Handle invite links
  static Future<void> _handleInviteLink(Uri uri) async {
    print("📨 Processing Invite Link...");

    // Check if user is logged in
    if (!_ensureLoggedIn(uri)) {
      _isProcessing = false;
      return;
    }

    // Extract eventId and permission
    // Format: https://bellybutton.app/invite/123?permission=view-only
    String? eventId;
    String permission = uri.queryParameters["permission"] ?? "view-only";

    // Get event ID from path
    if (uri.pathSegments.length >= 2) {
      eventId = uri.pathSegments.last;
    }

    if (eventId == null || int.tryParse(eventId) == null) {
      print("⚠️ Invalid event ID in invite link");
      _showError(AppTexts.DEEPLINK_INVALID_INVITE_LINK);
      _isProcessing = false;
      return;
    }

    print("📌 Event ID: $eventId, Permission: $permission");

    try {
      _showLoading();

      // Fetch event details
      final response = await PublicApiService().viewEventById(int.parse(eventId));

      _dismissLoading();

      if (response["success"] == true || response["data"] != null) {
        final eventData = response["data"] ?? response;
        final invitedEvent = InvitedEventModel.fromJson(eventData);

        // Navigate to InvitedEventGalleryView
        await _navigateToInvitedEventGallery(invitedEvent, permission);
      } else {
        _showError(AppTexts.DEEPLINK_EVENT_NOT_FOUND);
        _isProcessing = false;
      }
    } catch (e) {
      _dismissLoading();
      print("❌ Error: $e");
      _showError(AppTexts.DEEPLINK_FAILED_TO_OPEN);
      _isProcessing = false;
    }
  }

  /// Show loading dialog
  static void _showLoading() {
    if (Get.isDialogOpen == true) {
      print("⚠️ Dialog already open, skipping loading dialog");
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          barrierDismissible: false,
        );
      }
    });
  }

  /// Dismiss loading dialog
  static void _dismissLoading() {
    if (Get.isDialogOpen == true) {
      try {
        Get.back();
      } catch (e) {
        print("⚠️ Error dismissing loading dialog: $e");
      }
    }
  }

  /// Show error snackbar
  static void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCustomSnackBar(message, SnackbarState.error);
    });
  }

  /// Show warning snackbar
  static void _showWarning(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCustomSnackBar(message, SnackbarState.warning);
    });
  }
}