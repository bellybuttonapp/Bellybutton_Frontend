class AppConstants {
  // Singleton pattern
  static final AppConstants _instance = AppConstants._internal();

  factory AppConstants() => _instance;

  AppConstants._internal();

  // App Metadata
  final String appName = 'BellyButton';
  final String appVersion = '1.0.0+1';

  // Base URLs
  String baseURL = "https://mobileapi.talentturbo.us";

  //App URLs
  final String appUrl =
      "https://play.google.com/store/apps/details?id=com.android.referral.talentturbo";

  //App Terms And Conditions URLs
  String termsAndConditionUrl = 'https://main.talentturbo.us/terms-of-service';
}
