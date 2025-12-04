// ignore_for_file: constant_identifier_names

/// 🌐 App-wide constants used throughout the application.
class AppConstants {
  // ------------------------------------------------------
  // 🌍 Base URLs (Environment Specific)
  // ------------------------------------------------------

  /// Localhost for Android Emulator
  static const String BASE_URL_ANDROID_EMULATOR = 'http://10.0.2.2:8080';

  /// Localhost for iOS Simulator
  static const String BASE_URL_IOS_SIMULATOR = 'http://127.0.0.1:8080';

  /// Local network (Physical Device to Localhost)
  static const String BASE_URL_PHYSICAL_DEVICE = 'http://192.168.86.9:8080';

  /// Production Environment
  static const String BASE_URL_PRODUCTION =
      'https://apitest.isteer.co/mconnect/';

  /// Testing Environment
  static const String BASE_URL_TESTING = 'https://apitest.isteer.co/mconnect/';

  /// Development Backend (Server)
  static const String BASE_URL_DEVELOPMENT = 'http://54.90.159.46:8080/api';

  /// Ngrok Tunnel (Temporary Public URL)
  static const String BASE_URL_NGROK = 'http://192.168.1.35:8080/api';

  // ------------------------------------------------------
  // 🔧 ACTIVE ENVIRONMENT (SET THIS)
  // ------------------------------------------------------

  /// 👉 Choose which base URL to use here
  static const String BASE_URL = BASE_URL_DEVELOPMENT;
  // Example:
  // static const String BASE_URL = BASE_URL_NGROK;
  // static const String BASE_URL = BASE_URL_PRODUCTION;

  /// Returns the environment name automatically
  static String get environment {
    if (BASE_URL == BASE_URL_PRODUCTION) return 'Production';
    if (BASE_URL == BASE_URL_TESTING) return 'Testing';
    if (BASE_URL == BASE_URL_NGROK) return 'Ngrok';
    if (BASE_URL == BASE_URL_DEVELOPMENT) return 'Development';
    return 'Local';
  }

  // ------------------------------------------------------
  // 📱 External & Additional URLs
  // ------------------------------------------------------

  /// Mobile API URL (external integration)
  static const String MOBILE_API_URL = 'https://mobileapi.talentturbo.us';

  /// App Store URL (Google Play)
  static const String APP_STORE_URL =
      'https://play.google.com/store/apps/details?id=com.android.referral.talentturbo';

  /// Terms & Conditions URL
  static const String TERMS_AND_CONDITIONS_URL =
      'https://main.talentturbo.us/terms-of-service';

  // ------------------------------------------------------
  // 🧾 App Metadata
  // ------------------------------------------------------

  /// Application Name
  static const String APP_NAME = 'BellyButton';

  /// Version shown inside the app based on environment
  static const String APP_VERSION_TO_USER =
      BASE_URL == BASE_URL_PRODUCTION ? '2.0.0T' : '2.0.0L';

  // ------------------------------------------------------
  // 🛡 Private Constructor
  // ------------------------------------------------------

  const AppConstants._();
}
