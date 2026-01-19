// ignore_for_file: constant_identifier_names

class AppConstants {
  // ═══════════════════════════════════════════════════════════════════════════
  // BASE URLs
  // ═══════════════════════════════════════════════════════════════════════════
  static const String BASE_URL_ANDROID_EMULATOR = 'http://10.0.2.2:8080';
  static const String BASE_URL_IOS_SIMULATOR = 'http://127.0.0.1:8080';
  static const String BASE_URL_PHYSICAL_DEVICE = 'http://192.168.86.9:8080';
  static const String BASE_URL_PRODUCTION = 'https://mobapi.bellybutton.global/api';
  static const String BASE_URL_TESTING = 'https://mobapitest.bellybutton.global/api';
  static const String BASE_URL_DEVELOPMENT = 'https://mobapidev.bellybutton.global/api';
  static const String BASE_URL_NGROK = 'https://foraminiferal-unprismatically-britta.ngrok-free.dev/api';

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIVE ENVIRONMENT (Change this to switch environments)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String BASE_URL = BASE_URL_DEVELOPMENT;

  static String get environment {
    if (BASE_URL == BASE_URL_PRODUCTION) return 'Production';
    if (BASE_URL == BASE_URL_TESTING) return 'Testing';
    if (BASE_URL == BASE_URL_NGROK) return 'Ngrok';
    if (BASE_URL == BASE_URL_DEVELOPMENT) return 'Development';
    return 'Local';
  }

  static bool get isProduction => BASE_URL == BASE_URL_PRODUCTION;
  static bool get isDevelopment => BASE_URL == BASE_URL_DEVELOPMENT;

  // ═══════════════════════════════════════════════════════════════════════════
  // TIMEOUT (in seconds)
  // ═══════════════════════════════════════════════════════════════════════════
  static const int CONNECTION_TIMEOUT = 30;
  static const int RECEIVE_TIMEOUT = 30;
  static const int SEND_TIMEOUT = 30;

  // ═══════════════════════════════════════════════════════════════════════════
  // CACHE
  // ═══════════════════════════════════════════════════════════════════════════
  static const int CACHE_DURATION_HOURS = 24;

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC GALLERY URL (for sharing event gallery as web page)
  // ═══════════════════════════════════════════════════════════════════════════
  static String get publicGalleryBaseUrl {
    final baseWithoutApi = BASE_URL.replaceAll('/api', '');
    return '$baseWithoutApi/api/public/event/gallery';
  }

  const AppConstants._();
}
