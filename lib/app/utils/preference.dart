// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:hive/hive.dart';

class Preference {
  static late Box box;

  /// Call this once Hive is initialized
  static void init(Box hiveBox) {
    box = hiveBox;
    userNameRx.value = box.get(USER_NAME, defaultValue: '') ?? '';
    userEmailRx.value = box.get(USER_EMAIL, defaultValue: '') ?? '';
    profileImageRx.value = box.get(PROFILE_IMAGE);
  }

  // Reactive variables
  static RxString userNameRx = ''.obs;
  static RxString userEmailRx = ''.obs;
  static RxnString profileImageRx = RxnString();

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
  static const String PROFILE_IMAGE = 'profile_image';

  // Token
  static String get token => box.get(TOKEN, defaultValue: '') ?? '';
  static set token(String value) => box.put(TOKEN, value);

  // User name
  static String get userName => userNameRx.value;
  static set userName(String value) {
    userNameRx.value = value;
    box.put(USER_NAME, value);
  }

  // User email
  static String get email => userEmailRx.value;
  static set email(String value) {
    userEmailRx.value = value;
    box.put(USER_EMAIL, value);
  }

  // Login status
  static bool get isLoggedIn => box.get(IS_LOGGED_IN, defaultValue: false) ?? false;
  static set isLoggedIn(bool value) => box.put(IS_LOGGED_IN, value);

  // Location
  static double get latitude => (box.get(LATITUDE, defaultValue: 0.0) ?? 0.0).toDouble();
  static set latitude(double value) => box.put(LATITUDE, value);

  static double get longitude => (box.get(LONGITUDE, defaultValue: 0.0) ?? 0.0).toDouble();
  static set longitude(double value) => box.put(LONGITUDE, value);

  // Selected Country
  static String get selectedCountry => box.get(SELECTED_COUNTRY, defaultValue: '') ?? '';
  static set selectedCountry(String value) => box.put(SELECTED_COUNTRY, value);

  // Android ID
  static String get androidID => box.get(ANDROID_ID, defaultValue: '') ?? '';
  static set androidID(String value) => box.put(ANDROID_ID, value);

  // Language Code
  static String get languageCode => box.get(LANGUAGE_CODE, defaultValue: 'en') ?? 'en';
  static set languageCode(String value) => box.put(LANGUAGE_CODE, value);

  // Profile image
  static String? get profileImage => profileImageRx.value ?? box.get(PROFILE_IMAGE);
  static set profileImage(String? value) {
    profileImageRx.value = value;
    if (value != null) {
      box.put(PROFILE_IMAGE, value);
    } else {
      box.delete(PROFILE_IMAGE);
    }
  }

  // Clear all preferences
  static void clearAll() {
    box.clear();
    userNameRx.value = '';
    userEmailRx.value = '';
    profileImageRx.value = null;
  }
}
