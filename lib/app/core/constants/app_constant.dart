// ignore_for_file: constant_identifier_names

class AppConstants {
  // ═══════════════════════════════════════════════════════════════════════════
  // BASE URLs
  // ═══════════════════════════════════════════════════════════════════════════
  static const String BASE_URL_ANDROID_EMULATOR = 'http://10.0.2.2:8080'; // Android emulator localhost
  static const String BASE_URL_IOS_SIMULATOR = 'http://127.0.0.1:8080'; // iOS simulator localhost
  static const String BASE_URL_PHYSICAL_DEVICE = 'http://192.168.86.9:8080'; // Physical device to local server
  static const String BASE_URL_PRODUCTION = 'https://mobapi.bellybutton.global/api'; // Live production server
  static const String BASE_URL_TESTING = 'https://mobapitest.bellybutton.global/api'; // QA testing server
  static const String BASE_URL_DEVELOPMENT = 'https://mobapidev.bellybutton.global/api'; // Dev server
  static const String BASE_URL_NGROK = 'http://192.168.1.35:8080/api'; // Ngrok tunnel for external testing

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIVE ENVIRONMENT (Change this to switch environments)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String BASE_URL = BASE_URL_DEVELOPMENT; // Currently active URL

  static String get environment { // Returns current environment name
    if (BASE_URL == BASE_URL_PRODUCTION) return 'Production';
    if (BASE_URL == BASE_URL_TESTING) return 'Testing';
    if (BASE_URL == BASE_URL_NGROK) return 'Ngrok';
    if (BASE_URL == BASE_URL_DEVELOPMENT) return 'Development';
    return 'Local';
  }

  static bool get isProduction => BASE_URL == BASE_URL_PRODUCTION; // Check if production
  static bool get isDevelopment => BASE_URL == BASE_URL_DEVELOPMENT; // Check if development

  // ═══════════════════════════════════════════════════════════════════════════
  // TIMEOUT & DURATION (in seconds unless specified)
  // ═══════════════════════════════════════════════════════════════════════════
  static const int CONNECTION_TIMEOUT = 30; // seconds
  static const int RECEIVE_TIMEOUT = 30; // seconds
  static const int SEND_TIMEOUT = 30; // seconds
  static const int SESSION_TIMEOUT = 30; // minutes
  static const int OTP_EXPIRY_DURATION = 120; // seconds
  static const int SPLASH_DURATION = 2000; // milliseconds
  static const int DEBOUNCE_DURATION = 500; // milliseconds

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGINATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const int DEFAULT_PAGE_SIZE = 10; // Items per page in lists
  static const int MAX_PAGE_SIZE = 50; // Maximum items allowed per request
  static const int INITIAL_PAGE = 1; // Starting page number

  // ═══════════════════════════════════════════════════════════════════════════
  // CACHE
  // ═══════════════════════════════════════════════════════════════════════════
  static const int CACHE_DURATION_HOURS = 24; // How long to keep cached data
  static const int MAX_CACHE_SIZE_MB = 100; // Max storage for cache

  // ═══════════════════════════════════════════════════════════════════════════
  // EXTERNAL URLs
  // ═══════════════════════════════════════════════════════════════════════════
  static const String APP_STORE_URL = 'https://play.google.com/store/apps/details?id=com.bellybutton.app'; // Google Play Store
  static const String APPLE_STORE_URL = 'https://apps.apple.com/app/bellybutton/id000000000'; // Apple App Store
  static const String TERMS_AND_CONDITIONS_URL = 'https://bellybutton.global/terms-and-conditions'; // T&C page
  static const String PRIVACY_POLICY_URL = 'https://bellybutton.global/privacy-policy'; // Privacy page
  static const String SUPPORT_URL = 'https://bellybutton.global/support'; // Help center
  static const String SUPPORT_EMAIL = 'support@bellybutton.global'; // Support contact

  // ═══════════════════════════════════════════════════════════════════════════
  // DEEP LINK (for app navigation via URLs)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String DEEP_LINK_SCHEME = 'bellybutton'; // Custom scheme: bellybutton://
  static const String DEEP_LINK_HOST = 'bellybutton.global'; // Domain for universal links
  static const String UNIVERSAL_LINK_PREFIX = 'https://bellybutton.global'; // HTTPS prefix for sharing

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCAL STORAGE KEYS (for Hive/SharedPreferences)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String STORAGE_KEY_AUTH_TOKEN = 'auth_token'; // JWT access token
  static const String STORAGE_KEY_REFRESH_TOKEN = 'refresh_token'; // Token for refresh
  static const String STORAGE_KEY_USER_DATA = 'user_data'; // Cached user profile
  static const String STORAGE_KEY_USER_ID = 'user_id'; // Current user ID
  static const String STORAGE_KEY_FIRST_LAUNCH = 'first_launch'; // First app open flag
  static const String STORAGE_KEY_THEME = 'theme_mode'; // Light/Dark preference
  static const String STORAGE_KEY_LANGUAGE = 'language'; // Selected language
  static const String STORAGE_KEY_FCM_TOKEN = 'fcm_token'; // Firebase push token
  static const String STORAGE_KEY_DEVICE_ID = 'device_id'; // Unique device identifier
  static const String STORAGE_KEY_ONBOARDING_COMPLETE = 'onboarding_complete'; // Onboarding done flag

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION LIMITS
  // ═══════════════════════════════════════════════════════════════════════════
  static const int MIN_PASSWORD_LENGTH = 8; // Minimum chars for password
  static const int MAX_PASSWORD_LENGTH = 32; // Maximum chars for password
  static const int MIN_USERNAME_LENGTH = 3; // Minimum chars for username
  static const int MAX_USERNAME_LENGTH = 30; // Maximum chars for username
  static const int OTP_LENGTH = 6; // OTP digit count
  static const int MAX_FILE_SIZE_MB = 10; // Max file upload size
  static const int MAX_IMAGE_SIZE_MB = 5; // Max image upload size

  // ═══════════════════════════════════════════════════════════════════════════
  // APP METADATA
  // ═══════════════════════════════════════════════════════════════════════════
  static const String APP_NAME = 'BellyButton'; // Display name
  static const String PACKAGE_NAME = 'com.bellybutton.app'; // Android package
  static const String BUNDLE_ID = 'com.bellybutton.app'; // iOS bundle identifier
  static const String APP_VERSION_TO_USER = BASE_URL == BASE_URL_PRODUCTION ? '2.0.0' : '2.0.0-dev'; // Shown in app
  static const int MIN_ANDROID_VERSION = 21; // Android 5.0 Lollipop
  static const String MIN_IOS_VERSION = '12.0'; // Minimum iOS version

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION CHANNELS (Android only)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String NOTIFICATION_CHANNEL_ID = 'bellybutton_default'; // Default channel ID
  static const String NOTIFICATION_CHANNEL_NAME = 'BellyButton Notifications'; // Default channel name
  static const String NOTIFICATION_CHANNEL_HIGH_ID = 'bellybutton_high'; // High priority channel ID
  static const String NOTIFICATION_CHANNEL_HIGH_NAME = 'Important Notifications'; // High priority name

  // ═══════════════════════════════════════════════════════════════════════════
  // UI CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const double DEFAULT_BORDER_RADIUS = 12.0; // Rounded corners
  static const double DEFAULT_PADDING = 16.0; // Inner spacing
  static const double DEFAULT_MARGIN = 16.0; // Outer spacing
  static const double DEFAULT_ICON_SIZE = 24.0; // Standard icon size
  static const int DEFAULT_ANIMATION_DURATION = 300; // Animation time in ms

  const AppConstants._();
}

enum Environment { development, testing, production, local }
