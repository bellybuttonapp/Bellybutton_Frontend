import 'package:flutter/material.dart';

class AppColors {
  static ThemeData getTheme(bool isLightTheme) {
    return isLightTheme ? ThemeData.light() : ThemeData.dark();
  }

  static ColorScheme getColorScheme(bool isLightTheme) {
    return getTheme(isLightTheme).colorScheme;
  }

  static Color get primaryColor => getColorScheme(true).primary;
  static Color get onPrimaryColor => getColorScheme(true).onPrimary;
  static Color get primaryContainerColor =>
      getColorScheme(true).primaryContainer;
  static Color get onPrimaryContainerColor =>
      getColorScheme(true).onPrimaryContainer;
  static Color get secondaryColor => getColorScheme(true).secondary;
  static Color get onSecondaryColor => getColorScheme(true).onSecondary;
  static Color get secondaryContainerColor =>
      getColorScheme(true).secondaryContainer;
  static Color get onSecondaryContainerColor =>
      getColorScheme(true).onSecondaryContainer;
  static Color get tertiaryColor => getColorScheme(true).tertiary;
  static Color get onTertiaryColor => getColorScheme(true).onTertiary;
  static Color get tertiaryContainerColor =>
      getColorScheme(true).tertiaryContainer;
  static Color get onTertiaryContainerColor =>
      getColorScheme(true).onTertiaryContainer;
  static Color get errorColor => getColorScheme(true).error;
  static Color get onErrorColor => getColorScheme(true).onError;
  static Color get errorContainerColor => getColorScheme(true).errorContainer;
  static Color get onErrorContainerColor =>
      getColorScheme(true).onErrorContainer;
  static Color get backgroundColor => getColorScheme(true).background;
  static Color get onBackgroundColor => getColorScheme(true).onBackground;
  static Color get surfaceColor => getColorScheme(true).surface;
  static Color get onSurfaceColor => getColorScheme(true).onSurface;
  static Color get surfaceVariantColor => getColorScheme(true).surfaceVariant;
  static Color get onSurfaceVariantColor =>
      getColorScheme(true).onSurfaceVariant;
  static Color get outlineColor => getColorScheme(true).outline;
  static Color get onInverseSurfaceColor =>
      getColorScheme(true).onInverseSurface;
  static Color get inverseSurfaceColor => getColorScheme(true).inverseSurface;
  static Color get inversePrimaryColor => getColorScheme(true).inversePrimary;
  static Color get shadowColor => getColorScheme(true).shadow;
  static Color get surfaceTintColor => getColorScheme(true).surfaceTint;
  static Color get outlineVariantColor => getColorScheme(true).outlineVariant;
  static Color get scrimColor => getColorScheme(true).scrim;
}
