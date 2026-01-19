import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../global_widgets/CustomPopup/CustomPopup.dart';
import '../constants/app_colors.dart';
import '../constants/app_texts.dart';
import '../utils/index.dart';

/// Service for managing showcase/tutorial tours throughout the app.
/// Tracks which tours have been shown and provides helper methods for showcase widgets.
class ShowcaseService {
  ShowcaseService._();

  /// Flag to temporarily disable showcase when deep link navigation is pending
  static bool hasPendingDeepLink = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // USER PREFERENCE FOR SHOWCASE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if user has been asked about showcase
  static bool get hasBeenAskedAboutTour => Preference.showcaseAsked;

  /// Check if user wants to see the tour
  static bool get userWantsTour => Preference.showcaseEnabled;

  /// Mark that user has been asked about showcase
  static void markAskedAboutTour() {
    Preference.showcaseAsked = true;
  }

  /// Set user's preference for showcase
  static void setShowcasePreference(bool enabled) {
    Preference.showcaseEnabled = enabled;
    Preference.showcaseAsked = true;

    // If user doesn't want tour, mark all as shown
    if (!enabled) {
      skipAllTours();
    }
  }

  /// Skip all tours (user chose not to see them)
  static void skipAllTours() {
    Preference.showcaseDashboardShown = true;
    Preference.showcaseCreateEventShown = true;
    Preference.showcaseEventGalleryShown = true;
    Preference.showcaseInviteUsersShown = true;
    Preference.showcaseInvitedGalleryShown = true;
  }

  /// Show popup asking user if they want to see the app tour
  static Future<void> showTourPrompt(BuildContext context) async {
    if (hasBeenAskedAboutTour) return;

    final isProcessing = false.obs;
    bool userConfirmed = false;

    await Get.dialog(
      CustomPopup(
        title: AppTexts.SHOWCASE_TOUR_PROMPT_TITLE,
        message: AppTexts.SHOWCASE_TOUR_PROMPT_MESSAGE,
        confirmText: AppTexts.SHOWCASE_TOUR_PROMPT_CONFIRM,
        cancelText: AppTexts.SHOWCASE_TOUR_PROMPT_SKIP,
        isProcessing: isProcessing,
        barrierDismissible: false,
        cancelButtonColor: AppColors.tertiaryColor,
        confirmButtonColor: AppColors.primaryColor,
        onConfirm: () {
          userConfirmed = true;
          setShowcasePreference(true);
          Get.back();
        },
      ),
      barrierDismissible: false,
    );

    // If user tapped Skip (dialog closed without confirm)
    if (!userConfirmed) {
      setShowcasePreference(false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE STATUS CHECKS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if dashboard showcase should be shown
  /// Returns false if there's a pending deep link navigation or user opted out
  static bool get shouldShowDashboardTour =>
      userWantsTour && !Preference.showcaseDashboardShown && !hasPendingDeepLink;

  /// Check if create event showcase should be shown
  static bool get shouldShowCreateEventTour => userWantsTour && !Preference.showcaseCreateEventShown;

  /// Check if event gallery showcase should be shown
  static bool get shouldShowEventGalleryTour => userWantsTour && !Preference.showcaseEventGalleryShown;

  /// Check if invite users showcase should be shown
  static bool get shouldShowInviteUsersTour => userWantsTour && !Preference.showcaseInviteUsersShown;

  /// Check if invited event gallery showcase should be shown
  static bool get shouldShowInvitedGalleryTour => userWantsTour && !Preference.showcaseInvitedGalleryShown;

  // ═══════════════════════════════════════════════════════════════════════════
  // MARK TOURS AS COMPLETED
  // ═══════════════════════════════════════════════════════════════════════════

  /// Mark dashboard tour as completed
  static void completeDashboardTour() {
    Preference.showcaseDashboardShown = true;
  }

  /// Mark create event tour as completed
  static void completeCreateEventTour() {
    Preference.showcaseCreateEventShown = true;
  }

  /// Mark event gallery tour as completed
  static void completeEventGalleryTour() {
    Preference.showcaseEventGalleryShown = true;
  }

  /// Mark invite users tour as completed
  static void completeInviteUsersTour() {
    Preference.showcaseInviteUsersShown = true;
  }

  /// Mark invited event gallery tour as completed
  static void completeInvitedGalleryTour() {
    Preference.showcaseInvitedGalleryShown = true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESET TOURS (useful for testing or "show tutorial again" feature)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Reset all showcase tours
  static void resetAllTours() {
    Preference.showcaseDashboardShown = false;
    Preference.showcaseCreateEventShown = false;
    Preference.showcaseEventGalleryShown = false;
    Preference.showcaseInviteUsersShown = false;
    Preference.showcaseInvitedGalleryShown = false;
  }

  /// Reset specific tour
  static void resetDashboardTour() => Preference.showcaseDashboardShown = false;
  static void resetCreateEventTour() => Preference.showcaseCreateEventShown = false;
  static void resetEventGalleryTour() => Preference.showcaseEventGalleryShown = false;
  static void resetInviteUsersTour() => Preference.showcaseInviteUsersShown = false;
  static void resetInvitedGalleryTour() => Preference.showcaseInvitedGalleryShown = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE STYLING HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Default tooltip background color
  static Color get tooltipBackgroundColor => AppColors.primaryColor;

  /// Default text color for showcase
  static Color get textColor => AppColors.textColor3;

  /// Default title style for showcase tooltips (using app's DM_Sans font)
  static TextStyle get titleStyle => AppText.headingLg.copyWith(
        color: AppColors.textColor3,
        fontSize: 18,
      );

  /// Default description style for showcase tooltips (using app's DM_Sans font)
  static TextStyle get descriptionStyle => AppText.bodyMd.copyWith(
        color: AppColors.textColor3,
        fontSize: 14,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // START SHOWCASE HELPER
  // ═══════════════════════════════════════════════════════════════════════════

  /// Start showcase with given keys after a short delay
  static void startShowcase(
    BuildContext context,
    List<GlobalKey> keys, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    Future.delayed(delay, () {
      if (context.mounted) {
        ShowCaseWidget.of(context).startShowCase(keys);
      }
    });
  }
}