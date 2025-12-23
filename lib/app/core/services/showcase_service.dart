import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../constants/app_colors.dart';
import '../utils/index.dart';

/// Service for managing showcase/tutorial tours throughout the app.
/// Tracks which tours have been shown and provides helper methods for showcase widgets.
class ShowcaseService {
  ShowcaseService._();

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE STATUS CHECKS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if dashboard showcase should be shown
  static bool get shouldShowDashboardTour => !Preference.showcaseDashboardShown;

  /// Check if create event showcase should be shown
  static bool get shouldShowCreateEventTour => !Preference.showcaseCreateEventShown;

  /// Check if event gallery showcase should be shown
  static bool get shouldShowEventGalleryTour => !Preference.showcaseEventGalleryShown;

  /// Check if invite users showcase should be shown
  static bool get shouldShowInviteUsersTour => !Preference.showcaseInviteUsersShown;

  /// Check if invited event gallery showcase should be shown
  static bool get shouldShowInvitedGalleryTour => !Preference.showcaseInvitedGalleryShown;

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
  static TextStyle get titleStyle => customBoldText.copyWith(
        color: AppColors.textColor3,
        fontSize: 18,
      );

  /// Default description style for showcase tooltips (using app's DM_Sans font)
  static TextStyle get descriptionStyle => customTextNormal.copyWith(
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