// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/material.dart';

import 'dimensions.dart';

// ═══════════════════════════════════════════════════════════════════════════
// APP TEXT - Responsive Text Styles
// Usage: AppText.headingLg, AppText.bodyMd, AppText.labelSm
// All styles automatically scale based on screen size!
// ═══════════════════════════════════════════════════════════════════════════

/// Responsive text styles for consistent typography
/// Follows a semantic naming convention: [category][size][weight]
class AppText {
  AppText._();

  static const String _fontFamily = 'DM_Sans';

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADINGS - For titles, section headers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Hero heading - 32px (responsive), Extra Bold
  static TextStyle get headingHero => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: Dimensions.fontSizeHero,
  );

  /// Extra large heading - 24px (responsive), Bold
  static TextStyle get headingXl => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: Dimensions.fontSizeOverLarge,
  );

  /// Large heading - 18px (responsive), Bold
  static TextStyle get headingLg => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: Dimensions.fontSizeExtraLarge,
  );

  /// Medium heading - 16px (responsive), Bold
  static TextStyle get headingMd => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: Dimensions.fontSizeLarge,
  );

  /// Small heading - 14px (responsive), Bold
  static TextStyle get headingSm => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: Dimensions.fontSizeDefault,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // TITLES - For card titles, list item titles (SemiBold)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Large title - 18px (responsive), SemiBold
  static TextStyle get titleLg => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: Dimensions.fontSizeExtraLarge,
  );

  /// Medium title - 16px (responsive), SemiBold
  static TextStyle get titleMd => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: Dimensions.fontSizeLarge,
  );

  /// Small title - 14px (responsive), SemiBold
  static TextStyle get titleSm => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: Dimensions.fontSizeDefault,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BODY - For paragraphs, descriptions (Regular/Normal)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Large body text - 16px (responsive), Regular
  static TextStyle get bodyLg => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: Dimensions.fontSizeLarge,
  );

  /// Medium body text - 14px (responsive), Regular
  static TextStyle get bodyMd => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: Dimensions.fontSizeDefault,
  );

  /// Small body text - 12px (responsive), Regular
  static TextStyle get bodySm => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: Dimensions.fontSizeSmall,
  );

  /// Extra small body text - 10px (responsive), Regular
  static TextStyle get bodyXs => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: Dimensions.fontSizeExtraSmall,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // LABELS - For form labels, badges, chips (Medium weight)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Large label - 16px (responsive), Medium
  static TextStyle get labelLg => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: Dimensions.fontSizeLarge,
  );

  /// Medium label - 14px (responsive), Medium
  static TextStyle get labelMd => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: Dimensions.fontSizeDefault,
  );

  /// Small label - 12px (responsive), Medium
  static TextStyle get labelSm => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: Dimensions.fontSizeSmall,
  );

  /// Extra small label - 10px (responsive), Medium
  static TextStyle get labelXs => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: Dimensions.fontSizeExtraSmall,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON TEXT - For buttons
  // ═══════════════════════════════════════════════════════════════════════════

  /// Large button text - 16px (responsive), SemiBold
  static TextStyle get buttonLg => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: Dimensions.fontSizeLarge,
  );

  /// Medium button text - 14px (responsive), SemiBold
  static TextStyle get buttonMd => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: Dimensions.fontSizeDefault,
  );

  /// Small button text - 12px (responsive), SemiBold
  static TextStyle get buttonSm => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: Dimensions.fontSizeSmall,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CAPTIONS - For hints, helper text, timestamps
  // ═══════════════════════════════════════════════════════════════════════════

  /// Caption text - 12px (responsive), Regular
  static TextStyle get caption => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: Dimensions.fontSizeSmall,
  );

  /// Overline text - 10px (responsive), Medium, uppercase ready
  static TextStyle get overline => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: Dimensions.fontSizeExtraSmall,
    letterSpacing: 0.5,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Link text - 14px (responsive), Medium with underline
  static TextStyle get link => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: Dimensions.fontSizeDefault,
    decoration: TextDecoration.underline,
  );

  /// Error text - 12px (responsive), Medium
  static TextStyle get error => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: Dimensions.fontSizeSmall,
    color: Colors.red,
  );

  /// Success text - 12px (responsive), Medium
  static TextStyle get success => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: Dimensions.fontSizeSmall,
    color: Colors.green,
  );
}
