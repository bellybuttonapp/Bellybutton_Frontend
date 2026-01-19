// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// COLOR PALETTE - Raw color values for reference
// For usage in code, prefer AppColors from app_colors.dart
// ═══════════════════════════════════════════════════════════════════════════

class ColorPalette {
  ColorPalette._();

  // Brand Colors
  static const Color primary = Color(0xFF004C99);
  static const Color secondary = Color(0xFF212B4F);
  static const Color tertiary = Color(0xFF578990);
  static const Color accent = Color(0xFF256A5D);

  // Status Colors
  static const Color pending = Color(0xFF7BAAB7);
  static const Color inProgress = Color(0xFF68838A);
  static const Color completed = Color(0xFF508E7F);

  // Semantic Colors
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF1E88E5);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Text Colors
  static const Color textPrimary = Color(0xFF272425);
  static const Color textSecondary = Color(0xFF6F6F6F);
  static const Color textTertiary = Color(0xFF9E9E9E);

  // UI Element Colors
  static const Color inputBackground = Color(0xFFECECEC);
  static const Color inputBorder = Color(0xFFE5E5E5);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFDADADB);
}
