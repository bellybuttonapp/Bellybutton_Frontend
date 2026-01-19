// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ═══════════════════════════════════════════════════════════════════════════
// APP COLORS - Semantic Color System
// Usage: AppColors.primary, AppColors.textPrimary, AppColors.success
// Supports both light and dark mode automatically!
// ═══════════════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS (Static - Same in light/dark)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary brand color - Main blue
  static const Color primaryColor = Color(0xFF004C99);

  /// Secondary brand color - Dark blue
  static const Color secondaryColor = Color(0xFF212B4F);

  /// Tertiary/Accent color - Muted grey
  static const Color tertiaryColor = Color(0xFF818385);

  /// Accent red for highlights
  static const Color accentRed = Color(0xFFEB0707);

  /// Confirm button green
  static const Color confirmGreen = Color(0xFF256A5D);

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary text color - adapts to theme
  static Color get textPrimary => _isDark ? Colors.white : const Color(0xFF272425);

  /// Secondary text color - muted
  static Color get textSecondary => _isDark ? Colors.white70 : const Color(0xFF6F6F6F);

  /// Tertiary text color - even more muted
  static Color get textTertiary => _isDark ? Colors.white54 : const Color(0xFF9E9E9E);

  /// Disabled text color
  static Color get textDisabled => _isDark ? Colors.white38 : const Color(0xFFBDBDBD);

  /// Text on primary color backgrounds
  static const Color textOnPrimary = Colors.white;

  /// Text on dark backgrounds
  static const Color textOnDark = Colors.white;

  /// Text on light backgrounds
  static const Color textOnLight = Color(0xFF272425);

  // Legacy aliases (for backward compatibility)
  static const Color textColor = Color(0xFF000000);
  static const Color textColor2 = Color(0xFF6F6D6D);
  static const Color textColor3 = Colors.white;

  // ═══════════════════════════════════════════════════════════════════════════
  // SURFACE COLORS (Backgrounds)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Main background color
  static Color get background => _isDark ? const Color(0xFF121212) : Colors.white;

  /// Surface color for cards, dialogs
  static Color get surface => _isDark ? const Color(0xFF1E1E1E) : Colors.white;

  /// Elevated surface (cards with elevation)
  static Color get surfaceElevated => _isDark ? const Color(0xFF2D2D2D) : Colors.white;

  /// Surface variant for subtle contrast
  static Color get surfaceVariant => _isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5);

  /// Scaffold background
  static Color get scaffoldBackground => _isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);

  /// Card background
  static Color get cardBackground => _isDark ? const Color(0xFF1E1E1E) : Colors.white;

  /// Dialog background
  static Color get dialogBackground => _isDark ? const Color(0xFF2D2D2D) : Colors.white;

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Success color - green
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFFE8F5E9);
  static Color get successBackground => _isDark ? const Color(0xFF1B3D1F) : successLight;

  /// Error color - red
  static const Color error = Color(0xFFEF5350);
  static const Color errorLight = Color(0xFFFFEBEE);
  static Color get errorBackground => _isDark ? const Color(0xFF3D1B1B) : errorLight;

  /// Warning color - orange
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);
  static Color get warningBackground => _isDark ? const Color(0xFF3D2E1B) : warningLight;

  /// Info/Pending color - blue
  static const Color info = Color(0xFF1E88E5);
  static const Color infoLight = Color(0xFFE3F2FD);
  static Color get infoBackground => _isDark ? const Color(0xFF1B2A3D) : infoLight;

  /// Pending status
  static const Color pending = Color(0xFF7BAAB7);

  /// In progress status
  static const Color inProgress = Color(0xFF68838A);

  /// Completed status
  static const Color completed = Color(0xFF508E7F);

  // Legacy alias
  static const Color primaryColor1 = accentRed;
  static const Color other = Color(0xFF9C9B9B);

  // ═══════════════════════════════════════════════════════════════════════════
  // UI ELEMENT COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Divider color
  static Color get divider => _isDark ? Colors.white12 : const Color(0xFFE0E0E0);

  /// Border color
  static Color get border => _isDark ? Colors.white24 : const Color(0xFFE0E0E0);

  /// Border color for focused elements
  static Color get borderFocused => _isDark ? Colors.white54 : const Color(0xFF9E9E9E);

  /// Disabled elements
  static const Color disabled = Color(0xFFDADADB);
  static const Color disabledColor = disabled;

  /// Shimmer base color
  static Color get shimmerBase => _isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0);

  /// Shimmer highlight color
  static Color get shimmerHighlight => _isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5);

  /// Icon color
  static Color get iconPrimary => _isDark ? Colors.white : const Color(0xFF272425);

  /// Icon color secondary
  static Color get iconSecondary => _isDark ? Colors.white70 : const Color(0xFF6F6F6F);

  /// Icon on primary color
  static const Color iconOnPrimary = Colors.white;

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT FIELD COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Text field background
  static Color get inputBackground => _isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECECEC);

  /// Text field border
  static Color get inputBorder => _isDark ? Colors.white24 : const Color(0xFFE5E5E5);

  /// Text field focused border
  static Color get inputBorderFocused => _isDark ? Colors.white54 : Colors.grey;

  /// Text field hint color
  static Color get inputHint => _isDark ? Colors.white38 : const Color(0xFF9E9E9E);

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary button background
  static const Color buttonPrimary = primaryColor;

  /// Primary button text
  static const Color buttonPrimaryText = Colors.white;

  /// Secondary button background
  static Color get buttonSecondary => _isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0);

  /// Secondary button text
  static Color get buttonSecondaryText => _isDark ? Colors.white : const Color(0xFF272425);

  /// Tertiary/Ghost button
  static const Color buttonTertiary = Colors.transparent;

  /// Disabled button
  static const Color buttonDisabled = Color(0xFFDADADB);

  /// Disabled button text
  static const Color buttonDisabledText = Color(0xFF9E9E9E);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENT COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary gradient
  static const List<Color> gradientPrimary = [
    Color(0xFF004C99),
    Color(0xFF0066CC),
  ];

  /// Success gradient
  static const List<Color> gradientSuccess = [
    Color(0xFF43A047),
    Color(0xFF66BB6A),
  ];

  /// Tertiary button gradient
  static const List<Color> gradientTertiary = [
    Color(0xFFEDEDED),
    Color(0xFFF3F3F3),
  ];

  /// Referral box gradient
  static const List<Color> gradientReferral = [
    Color(0xFF3A616D),
    Color(0xFF3E777E),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Overlay color for modals
  static Color get overlay => Colors.black.withValues(alpha: 0.5);

  /// Shadow color
  static Color get shadow => _isDark ? Colors.black54 : Colors.black26;

  /// Rating bar color
  static const Color ratingBar = Color(0xFFEFF3F9);

  /// Add video background
  static const Color addVideo = Color(0xFFE7ECF4);

  /// Call button blue
  static const Color callBlue = Color(0xFF267CBE);

  /// Violet accent
  static const Color violet = Color(0xFF322A7F);

  /// Orange accent
  static const Color orange = Color(0xFFE26713);

  /// Yellow accent
  static const Color yellow = Color(0xFFFFB800);

  /// Green radium
  static const Color greenRadium = Color(0xFF228B22);

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if dark mode is active
  static bool get _isDark {
    try {
      return Get.isDarkMode;
    } catch (_) {
      return false;
    }
  }

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Get status color by name
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pending;
      case 'inprogress':
      case 'in_progress':
      case 'in progress':
        return inProgress;
      case 'completed':
      case 'complete':
        return completed;
      case 'success':
        return success;
      case 'error':
      case 'failed':
        return error;
      case 'warning':
        return warning;
      default:
        return other;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// APP THEME - Light and Dark Theme Configuration
// ═══════════════════════════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════
  static final lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primaryColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      tertiary: AppColors.tertiaryColor,
      surface: Colors.white,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFECECEC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF272425)),
      bodyMedium: TextStyle(color: Color(0xFF6F6F6F)),
      bodySmall: TextStyle(color: Color(0xFF9E9E9E)),
    ),
    disabledColor: AppColors.disabled,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════════════
  static final darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primaryColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      tertiary: AppColors.tertiaryColor,
      surface: const Color(0xFF1E1E1E),
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2D2D2D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white54),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.white12,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white54),
    ),
    disabledColor: AppColors.disabled,
  );
}
