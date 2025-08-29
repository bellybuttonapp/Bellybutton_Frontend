// ignore_for_file: constant_identifier_names

class AppConstants {
  // Base URLs
  static const String BASE_URL = 'https://apitest.isteer.co/mconnect/';
  static const String MOBILE_API_URL = 'https://mobileapi.talentturbo.us';

  // App Metadata
  static const String APP_NAME = 'BellyButton';

  // App version depending on environment
  static const String APP_VERSION_TO_USER =
      BASE_URL == 'https://apitest.isteer.co/mconnect/' ? '2.0.0T' : '2.0.0L';

  // App URLs
  static const String APP_STORE_URL =
      'https://play.google.com/store/apps/details?id=com.android.referral.talentturbo';

  // Terms & Conditions
  static const String TERMS_AND_CONDITIONS_URL =
      'https://main.talentturbo.us/terms-of-service';

  // Private constructor to prevent instantiation
  AppConstants._();
}
