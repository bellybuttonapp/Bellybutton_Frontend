// ignore_for_file: constant_identifier_names

/// Centralized app-level constants used across the application.
class AppConstants {
  // ------------------ 🌍 Base URLs ------------------ //

  // Localhost for Android Emulator
  static const String BASE_URL_ANDROID_EMULATOR = 'http://10.0.2.2:8080';
  // Localhost for iOS Simulator
  static const String BASE_URL_IOS_SIMULATOR = 'http://127.0.0.1:8080';
  // Physical device (replace with your local machine’s IP)
  static const String BASE_URL_PHYSICAL_DEVICE = 'http://192.168.86.9:8080';

  // Production Environment
  static const String BASE_URL_PRODUCTION =
      'https://apitest.isteer.co/mconnect/';
  // Testing Environment
  static const String BASE_URL_TESTING = 'https://apitest.isteer.co/mconnect/';
  // Development Environment
  static const String BASE_URL_DEVELOPMENT = 'http://54.90.159.46:8080/api';

  /// ✅ Choose active environment here
  static const String BASE_URL = BASE_URL_DEVELOPMENT;

  /// Optional: Get environment name dynamically
  static String get environment {
    if (BASE_URL == BASE_URL_PRODUCTION) return 'Production';
    if (BASE_URL == BASE_URL_TESTING) return 'Testing';
    if (BASE_URL == BASE_URL_DEVELOPMENT) return 'Development';
    return 'Local';
  }

  // ------------------ 📱 API URLs ------------------ //
  static const String MOBILE_API_URL = 'https://mobileapi.talentturbo.us';

  // ------------------ 🧾 App Metadata ------------------ //
  static const String APP_NAME = 'BellyButton';

  /// Version for user display based on environment
  static const String APP_VERSION_TO_USER =
      BASE_URL == BASE_URL_PRODUCTION ? '2.0.0T' : '2.0.0L';

  // ------------------ 🔗 External URLs ------------------ //
  static const String APP_STORE_URL =
      'https://play.google.com/store/apps/details?id=com.android.referral.talentturbo';

  static const String TERMS_AND_CONDITIONS_URL =
      'https://main.talentturbo.us/terms-of-service';

  // ------------------ 🛡️ Private Constructor ------------------ //
  const AppConstants._();
}
