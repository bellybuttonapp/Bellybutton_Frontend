import 'package:flutter/material.dart';

class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color textColor = Color.fromARGB(255, 0, 0, 0); // Primary text (black)
  static const Color textColor2 = Color.fromARGB(255, 111, 109, 109); // Secondary text (grey)
  static const Color textColor3 = Colors.white; // Light text (white)

  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color primaryColor = Color(0xFF004C99); // Main brand blue
  static const Color primaryColor1 = Color.fromARGB(255, 235, 7, 7); // Accent red
  static const Color tertiaryColor = Color(0xFF818385); // Muted grey

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS COLORS
  // ═══════════════════════════════════════════════════════════════════════════
static const Color error = Color(0xFFEF5350);// Error/failure red
  static const Color warning = Color(0xFFFFA726); // Warning orange
  static const Color success = Color(0xFF43A047); // Success green
  static const Color pending = Color(0xFF1E88E5); // Pending/info blue
  static const Color other = Color.fromARGB(255, 156, 155, 155); // Neutral grey

  // ═══════════════════════════════════════════════════════════════════════════
  // UI STATE COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color disabledColor = Color(0xFFDADADB); // Disabled elements
}

class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.tertiaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.textColor2),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.textColor),
      bodyMedium: TextStyle(color: AppColors.textColor2),
    ),
    disabledColor: AppColors.disabledColor,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════════════
  static final darkTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.tertiaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.textColor2),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.textColor),
      bodyMedium: TextStyle(color: AppColors.textColor2),
    ),
    disabledColor: AppColors.disabledColor,
  );
}
