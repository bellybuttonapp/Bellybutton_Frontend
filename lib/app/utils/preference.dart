// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preference {
  static final SharedPreferences preferences = Get.find();

  // Keys
  static const String TOKEN = 'token';
  static const String USER_NAME = 'user_name';
  static const String USER_EMAIL = 'email';
  static const String IS_LOGGED_IN = 'is_logged_in';
  static const String LATITUDE = 'latitude';
  static const String LONGITUDE = 'longitude';
  static const String SELECTED_COUNTRY = 'selected_country';
  static const String ANDROID_ID = 'android_id';
  static const String LANGUAGE_CODE = 'language_code';

  // Token
  static String get token => preferences.getString(TOKEN) ?? '';
  static set token(String value) => preferences.setString(TOKEN, value);

  // User name
  static String get userName => preferences.getString(USER_NAME) ?? '';
  static set userName(String value) => preferences.setString(USER_NAME, value);

  // User email
  static String get email => preferences.getString(USER_EMAIL) ?? '';
  static set email(String value) => preferences.setString(USER_EMAIL, value);

  // Login status
  static bool get isLoggedIn => preferences.getBool(IS_LOGGED_IN) ?? false;
  static set isLoggedIn(bool value) => preferences.setBool(IS_LOGGED_IN, value);

  // Location
  static double get latitude => preferences.getDouble(LATITUDE) ?? 0.0;
  static set latitude(double value) => preferences.setDouble(LATITUDE, value);

  static double get longitude => preferences.getDouble(LONGITUDE) ?? 0.0;
  static set longitude(double value) => preferences.setDouble(LONGITUDE, value);

  // Selected Country
  static String get selectedCountry =>
      preferences.getString(SELECTED_COUNTRY) ?? '';
  static set selectedCountry(String value) =>
      preferences.setString(SELECTED_COUNTRY, value);

  // Android ID
  static String get androidID => preferences.getString(ANDROID_ID) ?? '';
  static set androidID(String value) =>
      preferences.setString(ANDROID_ID, value);

  // Language Code
  static String get languageCode =>
      preferences.getString(LANGUAGE_CODE) ?? 'en';
  static set languageCode(String value) =>
      preferences.setString(LANGUAGE_CODE, value);

  // Clear all preferences
  static void clearAll() {
    preferences.clear();
  }
}
