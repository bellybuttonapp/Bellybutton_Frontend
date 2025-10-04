// ignore_for_file: constant_identifier_names

class AppConstants {
  // Base URL depending on environment
  // Use one of these depending on your testing setup

  // Localhost for Android Emulator
  static const String BASE_URL_ANDROID_EMULATOR = 'http://10.0.2.2:8080';
  // Localhost for iOS Simulator
  static const String BASE_URL_IOS_SIMULATOR = 'http://127.0.0.1:8080';
  // Physical device (replace with your PC's local IP)
  static const String BASE_URL_PHYSICAL_DEVICE = 'http://192.168.86.9:8080';

  // BASE_URL_PRODUCTION
  static const String BASE_URL_PRODUCTION =
      'https://apitest.isteer.co/mconnect/';


  // BASE_URL_TESTING
  static const String BASE_URL_TESTING = 'https://apitest.isteer.co/mconnect/';

  // BASE_URL_DEVELOPMENT
  static const String BASE_URL_DEVELOPMENT =
      'https://apitest.isteer.co/mconnect/';


  // Choose the active one here
  static const String BASE_URL = BASE_URL_PHYSICAL_DEVICE;

  static const String MOBILE_API_URL = 'https://mobileapi.talentturbo.us';

  // App Metadata
  static const String APP_NAME = 'BellyButton';

  // App version depending on environment
  static const String APP_VERSION_TO_USER =
      BASE_URL == BASE_URL_PRODUCTION ? '2.0.0T' : '2.0.0L';

  // App URLs
  static const String APP_STORE_URL =
      'https://play.google.com/store/apps/details?id=com.android.referral.talentturbo';

  // Terms & Conditions
  static const String TERMS_AND_CONDITIONS_URL =
      'https://main.talentturbo.us/terms-of-service';

  // Private constructor to prevent instantiation
  AppConstants._();
}
