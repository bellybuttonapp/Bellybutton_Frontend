// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Centralized app dimensions for consistent spacing, sizing, and responsive design
class Dimensions {
  Dimensions._();

  // ═══════════════════════════════════════════════════════════════════════════
  // RESPONSIVE SCALE FACTOR
  // Base design width: 375 (iPhone SE/8 size)
  // Scales up on larger screens, down on smaller screens
  // ═══════════════════════════════════════════════════════════════════════════
  static const double _baseWidth = 375.0;
  static const double _minScale = 0.85; // Minimum scale for very small screens
  static const double _maxScale = 1.25; // Maximum scale for tablets

  /// Returns a scale factor based on screen width
  /// - Small phones (< 360): scales down to 0.85x
  /// - Normal phones (375): 1.0x (base)
  /// - Large phones (414+): scales up to ~1.1x
  /// - Tablets (600+): scales up to 1.25x max
  static double get _scaleFactor {
    final width = Get.context?.width ?? _baseWidth;
    final scale = width / _baseWidth;
    return scale.clamp(_minScale, _maxScale);
  }

  /// Apply responsive scaling to a value
  static double _scale(double value) => value * _scaleFactor;

  // ═══════════════════════════════════════════════════════════════════════════
  // RESPONSIVE FONT SIZES (Based on screen width)
  // ═══════════════════════════════════════════════════════════════════════════
  static double get fontSizeExtraSmall => Get.context!.width >= 1300
      ? 14
      : Get.context!.width <= 360
          ? 8
          : 10;

  static double get fontSizeSmall => Get.context!.width >= 1300
      ? 16
      : Get.context!.width <= 360
          ? 10
          : 12;

  static double get fontSizeDefault => Get.context!.width >= 1300
      ? 18
      : Get.context!.width <= 360
          ? 12
          : 14;

  static double get fontSizeLarge => Get.context!.width >= 1300
      ? 20
      : Get.context!.width <= 360
          ? 14
          : 16;

  static double get fontSizeExtraLarge => Get.context!.width >= 1300 ? 22 : 18;
  static double get fontSizeOverLarge => Get.context!.width >= 1300 ? 28 : 24;
  static double get fontSizeHero => Get.context!.width >= 1300 ? 36 : 32;

  // ═══════════════════════════════════════════════════════════════════════════
  // SPACING - Responsive (Based on 4px grid system, scales with screen)
  // ═══════════════════════════════════════════════════════════════════════════
  static double get spacing2 => _scale(2);
  static double get spacing4 => _scale(4);
  static double get spacing6 => _scale(6);
  static double get spacing8 => _scale(8);
  static double get spacing10 => _scale(10);
  static double get spacing12 => _scale(12);
  static double get spacing14 => _scale(14);
  static double get spacing16 => _scale(16);
  static double get spacing20 => _scale(20);
  static double get spacing24 => _scale(24);
  static double get spacing28 => _scale(28);
  static double get spacing32 => _scale(32);
  static double get spacing40 => _scale(40);
  static double get spacing48 => _scale(48);
  static double get spacing56 => _scale(56);
  static double get spacing64 => _scale(64);
  static double get spacing80 => _scale(80);

  // Common spacing aliases (responsive)
  static double get xs => spacing4;
  static double get sm => spacing8;
  static double get md => spacing16;
  static double get lg => spacing24;
  static double get xl => spacing32;
  static double get xxl => spacing48;

  // ═══════════════════════════════════════════════════════════════════════════
  // PADDING SIZES (Legacy support - fixed values)
  // ═══════════════════════════════════════════════════════════════════════════
  static const double PADDING_SIZE_EXTRA_SMALL = 5.0;
  static const double PADDING_SIZE_SMALL = 10.0;
  static const double PADDING_SIZE_DEFAULT = 15.0;
  static const double PADDING_SIZE_LARGE = 20.0;
  static const double PADDING_SIZE_EXTRA_LARGE = 25.0;
  static const double PADDING_SIZE_OVER_LARGE = 30.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGE PADDING (EdgeInsets) - Responsive
  // ═══════════════════════════════════════════════════════════════════════════
  static double get pagePaddingHorizontal => spacing16;
  static double get pagePaddingVertical => spacing16;

  static EdgeInsets get pagePadding => EdgeInsets.all(spacing16);
  static EdgeInsets get pagePaddingLg => EdgeInsets.all(spacing24);
  static EdgeInsets get pagePaddingSm => EdgeInsets.all(spacing12);

  static EdgeInsets get pagePaddingHorizontalOnly =>
      EdgeInsets.symmetric(horizontal: spacing16);
  static EdgeInsets get pagePaddingVerticalOnly =>
      EdgeInsets.symmetric(vertical: spacing16);

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD PADDING (EdgeInsets) - Responsive
  // ═══════════════════════════════════════════════════════════════════════════
  static double get cardPadding => spacing16;
  static EdgeInsets get cardPaddingAll => EdgeInsets.all(spacing16);
  static EdgeInsets get cardPaddingLg => EdgeInsets.all(spacing24);
  static EdgeInsets get cardPaddingSm => EdgeInsets.all(spacing12);
  static EdgeInsets get cardPaddingCompact => EdgeInsets.all(spacing8);

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS VALUES (Fixed - no need for responsive)
  // ═══════════════════════════════════════════════════════════════════════════
  static const double RADIUS_SMALL = 5.0;
  static const double RADIUS_DEFAULT = 10.0;
  static const double RADIUS_LARGE = 15.0;
  static const double RADIUS_EXTRA_LARGE = 20.0;
  static const double ButtonRadius = 30.0;

  // New radius constants
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;
  static const double radiusFull = 999;

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS (BorderRadius objects)
  // ═══════════════════════════════════════════════════════════════════════════
  static const BorderRadius borderRadiusXs =
      BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm =
      BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd =
      BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg =
      BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl =
      BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusXxl =
      BorderRadius.all(Radius.circular(radiusXxl));
  static const BorderRadius borderRadiusFull =
      BorderRadius.all(Radius.circular(radiusFull));

  // Top-only radius
  static const BorderRadius borderRadiusTopMd = BorderRadius.only(
    topLeft: Radius.circular(radiusMd),
    topRight: Radius.circular(radiusMd),
  );
  static const BorderRadius borderRadiusTopLg = BorderRadius.only(
    topLeft: Radius.circular(radiusLg),
    topRight: Radius.circular(radiusLg),
  );
  static const BorderRadius borderRadiusTopXl = BorderRadius.only(
    topLeft: Radius.circular(radiusXl),
    topRight: Radius.circular(radiusXl),
  );

  // Bottom-only radius
  static const BorderRadius borderRadiusBottomMd = BorderRadius.only(
    bottomLeft: Radius.circular(radiusMd),
    bottomRight: Radius.circular(radiusMd),
  );
  static const BorderRadius borderRadiusBottomLg = BorderRadius.only(
    bottomLeft: Radius.circular(radiusLg),
    bottomRight: Radius.circular(radiusLg),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ICON SIZES (Fixed)
  // ═══════════════════════════════════════════════════════════════════════════
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 28;
  static const double iconXl = 32;
  static const double iconXxl = 48;
  static const double iconHero = 80;

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON HEIGHTS (Fixed)
  // ═══════════════════════════════════════════════════════════════════════════
  static const double buttonHeightSm = 40;
  static const double buttonHeightMd = 48;
  static const double buttonHeightLg = 56;

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT HEIGHTS (Fixed)
  // ═══════════════════════════════════════════════════════════════════════════
  static const double inputHeight = 52;
  static const double inputHeightSm = 44;
  static const double inputHeightLg = 56;

  // ═══════════════════════════════════════════════════════════════════════════
  // AVATAR SIZES (Fixed)
  // ═══════════════════════════════════════════════════════════════════════════
  static const double avatarXs = 24;
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 56;
  static const double avatarXl = 80;
  static const double avatarXxl = 100;
  static const double avatarHero = 120;

  // ═══════════════════════════════════════════════════════════════════════════
  // DIVIDER (Fixed)
  // ═══════════════════════════════════════════════════════════════════════════
  static const double dividerThickness = 1;
  static const double dividerThicknessBold = 2;

  // ═══════════════════════════════════════════════════════════════════════════
  // ELEVATION (Fixed)
  // ═══════════════════════════════════════════════════════════════════════════
  static const double elevationNone = 0;
  static const double elevationSm = 2;
  static const double elevationMd = 4;
  static const double elevationLg = 8;
  static const double elevationXl = 16;

  // ═══════════════════════════════════════════════════════════════════════════
  // APP BAR & NAVIGATION (Fixed)
  // ═══════════════════════════════════════════════════════════════════════════
  static const double appBarHeight = 56;
  static const double appBarHeightLg = 64;
  static const double bottomNavHeight = 56;
  static const double bottomNavHeightWithLabel = 80;

  // ═══════════════════════════════════════════════════════════════════════════
  // RESPONSIVE BREAKPOINTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // ═══════════════════════════════════════════════════════════════════════════
  // MAX CONTENT WIDTH
  // ═══════════════════════════════════════════════════════════════════════════
  static const double WEB_MAX_WIDTH = 1170;
  static const double maxContentWidth = 600;
  static const double maxContentWidthWide = 900;

  // ═══════════════════════════════════════════════════════════════════════════
  // MISC
  // ═══════════════════════════════════════════════════════════════════════════
  static const int MESSAGE_INPUT_LENGTH = 250;

  static double get popupHeight => Get.context!.height >= 932
      ? Get.context!.height / 1.8
      : Get.context!.height / 1.5;

  static double get totalScreenWidth => Get.context!.width;
  static double get totalScreenHeight => Get.context!.height;

  // ═══════════════════════════════════════════════════════════════════════════
  // RESPONSIVE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  static bool get isMobile => Get.context!.width < mobileBreakpoint;
  static bool get isTablet =>
      Get.context!.width >= mobileBreakpoint &&
      Get.context!.width < desktopBreakpoint;
  static bool get isDesktop => Get.context!.width >= desktopBreakpoint;
}

/// Responsive SizedBox helpers for consistent spacing
/// Usage: AppGap.h16 for horizontal gap of 16, AppGap.v8 for vertical gap of 8
/// These automatically scale based on screen size!
class AppGap {
  AppGap._();

  // ═══════════════════════════════════════════════════════════════════════════
  // HORIZONTAL GAPS (width) - Responsive
  // ═══════════════════════════════════════════════════════════════════════════
  static SizedBox get h2 => SizedBox(width: Dimensions.spacing2);
  static SizedBox get h4 => SizedBox(width: Dimensions.spacing4);
  static SizedBox get h6 => SizedBox(width: Dimensions.spacing6);
  static SizedBox get h8 => SizedBox(width: Dimensions.spacing8);
  static SizedBox get h10 => SizedBox(width: Dimensions.spacing10);
  static SizedBox get h12 => SizedBox(width: Dimensions.spacing12);
  static SizedBox get h14 => SizedBox(width: Dimensions.spacing14);
  static SizedBox get h16 => SizedBox(width: Dimensions.spacing16);
  static SizedBox get h20 => SizedBox(width: Dimensions.spacing20);
  static SizedBox get h24 => SizedBox(width: Dimensions.spacing24);
  static SizedBox get h28 => SizedBox(width: Dimensions.spacing28);
  static SizedBox get h32 => SizedBox(width: Dimensions.spacing32);
  static SizedBox get h40 => SizedBox(width: Dimensions.spacing40);
  static SizedBox get h48 => SizedBox(width: Dimensions.spacing48);

  // ═══════════════════════════════════════════════════════════════════════════
  // VERTICAL GAPS (height) - Responsive
  // ═══════════════════════════════════════════════════════════════════════════
  static SizedBox get v2 => SizedBox(height: Dimensions.spacing2);
  static SizedBox get v4 => SizedBox(height: Dimensions.spacing4);
  static SizedBox get v6 => SizedBox(height: Dimensions.spacing6);
  static SizedBox get v8 => SizedBox(height: Dimensions.spacing8);
  static SizedBox get v10 => SizedBox(height: Dimensions.spacing10);
  static SizedBox get v12 => SizedBox(height: Dimensions.spacing12);
  static SizedBox get v14 => SizedBox(height: Dimensions.spacing14);
  static SizedBox get v16 => SizedBox(height: Dimensions.spacing16);
  static SizedBox get v20 => SizedBox(height: Dimensions.spacing20);
  static SizedBox get v24 => SizedBox(height: Dimensions.spacing24);
  static SizedBox get v28 => SizedBox(height: Dimensions.spacing28);
  static SizedBox get v32 => SizedBox(height: Dimensions.spacing32);
  static SizedBox get v40 => SizedBox(height: Dimensions.spacing40);
  static SizedBox get v48 => SizedBox(height: Dimensions.spacing48);
  static SizedBox get v56 => SizedBox(height: Dimensions.spacing56);
  static SizedBox get v64 => SizedBox(height: Dimensions.spacing64);
  static SizedBox get v80 => SizedBox(height: Dimensions.spacing80);

  // ═══════════════════════════════════════════════════════════════════════════
  // EMPTY / ZERO GAP (const - no need for responsive)
  // ═══════════════════════════════════════════════════════════════════════════
  static const SizedBox zero = SizedBox.shrink();
  static const SizedBox expand = SizedBox.expand();
}

/// Responsive EdgeInsets presets for quick access
/// Usage: AppInsets.all16, AppInsets.horizontalMd, AppInsets.verticalSm
/// These automatically scale based on screen size!
class AppInsets {
  AppInsets._();

  // ═══════════════════════════════════════════════════════════════════════════
  // ALL SIDES - Responsive
  // ═══════════════════════════════════════════════════════════════════════════
  static EdgeInsets get all4 => EdgeInsets.all(Dimensions.spacing4);
  static EdgeInsets get all8 => EdgeInsets.all(Dimensions.spacing8);
  static EdgeInsets get all12 => EdgeInsets.all(Dimensions.spacing12);
  static EdgeInsets get all16 => EdgeInsets.all(Dimensions.spacing16);
  static EdgeInsets get all20 => EdgeInsets.all(Dimensions.spacing20);
  static EdgeInsets get all24 => EdgeInsets.all(Dimensions.spacing24);
  static EdgeInsets get all32 => EdgeInsets.all(Dimensions.spacing32);

  // ═══════════════════════════════════════════════════════════════════════════
  // HORIZONTAL ONLY - Responsive
  // ═══════════════════════════════════════════════════════════════════════════
  static EdgeInsets get horizontalXs =>
      EdgeInsets.symmetric(horizontal: Dimensions.xs);
  static EdgeInsets get horizontalSm =>
      EdgeInsets.symmetric(horizontal: Dimensions.sm);
  static EdgeInsets get horizontalMd =>
      EdgeInsets.symmetric(horizontal: Dimensions.md);
  static EdgeInsets get horizontalLg =>
      EdgeInsets.symmetric(horizontal: Dimensions.lg);
  static EdgeInsets get horizontalXl =>
      EdgeInsets.symmetric(horizontal: Dimensions.xl);

  // ═══════════════════════════════════════════════════════════════════════════
  // VERTICAL ONLY - Responsive
  // ═══════════════════════════════════════════════════════════════════════════
  static EdgeInsets get verticalXs =>
      EdgeInsets.symmetric(vertical: Dimensions.xs);
  static EdgeInsets get verticalSm =>
      EdgeInsets.symmetric(vertical: Dimensions.sm);
  static EdgeInsets get verticalMd =>
      EdgeInsets.symmetric(vertical: Dimensions.md);
  static EdgeInsets get verticalLg =>
      EdgeInsets.symmetric(vertical: Dimensions.lg);
  static EdgeInsets get verticalXl =>
      EdgeInsets.symmetric(vertical: Dimensions.xl);

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMON COMBINATIONS - Responsive
  // ═══════════════════════════════════════════════════════════════════════════
  static EdgeInsets get listItem => EdgeInsets.symmetric(
        horizontal: Dimensions.spacing16,
        vertical: Dimensions.spacing12,
      );

  static EdgeInsets get card => EdgeInsets.all(Dimensions.spacing16);

  static EdgeInsets get button => EdgeInsets.symmetric(
        horizontal: Dimensions.spacing24,
        vertical: Dimensions.spacing12,
      );

  static EdgeInsets get input => EdgeInsets.symmetric(
        horizontal: Dimensions.spacing16,
        vertical: Dimensions.spacing14,
      );

  static EdgeInsets get chip => EdgeInsets.symmetric(
        horizontal: Dimensions.spacing12,
        vertical: Dimensions.spacing6,
      );

  static EdgeInsets get bottomSheet => EdgeInsets.only(
        left: Dimensions.spacing16,
        right: Dimensions.spacing16,
        top: Dimensions.spacing20,
        bottom: Dimensions.spacing24,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // ZERO (const - no need for responsive)
  // ═══════════════════════════════════════════════════════════════════════════
  static const EdgeInsets zero = EdgeInsets.zero;
}
