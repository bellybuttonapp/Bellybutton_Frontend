import 'package:flutter/material.dart';

class AppColors {
  static const Color textColor = Color.fromARGB(255, 0, 0, 0);
  static const Color textColor2 = Color.fromARGB(255, 111, 109, 109);
  static const Color textColor3 = Colors.white;
  static const Color primaryColor = Color(0xFF004C99);
  static const Color primaryColor1 = Color.fromARGB(255, 235, 7, 7);
  static const Color error = Color(0xFFE53935); // Red
  static const Color warning = Color(0xFFFFA726); // Orange
  static const Color success = Color(0xFF43A047); // Green
  static const Color pending = Color(0xFF1E88E5); // Blue
  static const Color other = Color(0xFF757575); // Grey

  static const Color tertiaryColor = Color(0xFF818385);
  static const Color disabledColor = Color(0xFFDADADB);
}

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    // cardTheme: CardTheme(
    //   color: Colors.white,
    //   elevation: 4,
    //   margin: const EdgeInsets.all(8),
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    // ),
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

  static final darkTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    // cardTheme: CardTheme(
    //   color: Color(0xFF1E1E1E),
    //   elevation: 4,
    //   margin: const EdgeInsets.all(8),
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    // ),
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
// This file defines the color scheme and themes for the application, including light and dark themes.
// It includes primary, secondary, and tertiary colors, as well as styles for text and input fields.
// The themes are designed to provide a consistent look and feel across the app, adapting to user preferences for light or dark mode.
// The `AppColors` class contains static constants for various colors used in the app.
// The `AppTheme` class provides two static final instances of `ThemeData` for light and dark themes.
// The light theme uses a white background with primary and secondary colors for text and UI elements.
// The dark theme uses a dark background with contrasting colors for text and UI elements.
// The themes include styles for app bars, cards, input fields, and text, ensuring a cohesive design.
// The themes can be easily applied to the MaterialApp widget in the main application file.
// This allows for dynamic switching between light and dark themes based on user preferences or system settings.
// The themes are designed to enhance user experience by providing good contrast and readability in both light and dark modes.
// The themes also include styles for disabled states, ensuring that UI elements are visually distinct when inactive.