// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:hive/hive.dart';

class Preference {
  static late Box box;

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════
  static void init(Box hiveBox) {
    box = hiveBox;
    userIdRx.value = box.get(USER_ID, defaultValue: 0) ?? 0;
    userNameRx.value = box.get(USER_NAME, defaultValue: '') ?? '';
    userEmailRx.value = box.get(USER_EMAIL, defaultValue: '') ?? '';
    profileImageRx.value = box.get(PROFILE_IMAGE);
    bioRx.value = box.get(BIO, defaultValue: '') ?? '';
    phoneRx.value = box.get(PHONE, defaultValue: '') ?? '';
    addressRx.value = box.get(ADDRESS, defaultValue: '') ?? '';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REACTIVE VARIABLES (GetX observables for UI binding)
  // ═══════════════════════════════════════════════════════════════════════════
  static RxInt userIdRx = 0.obs;
  static RxString userNameRx = ''.obs;
  static RxString userEmailRx = ''.obs;
  static RxnString profileImageRx = RxnString();
  static RxString bioRx = ''.obs;
  static RxString phoneRx = ''.obs;
  static RxString addressRx = ''.obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // STORAGE KEYS - Authentication (3)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String TOKEN = 'token'; // JWT access token
  static const String IS_LOGGED_IN = 'is_logged_in'; // Login status flag
  static const String FCM_TOKEN = 'fcm_token'; // Firebase push token

  // ═══════════════════════════════════════════════════════════════════════════
  // STORAGE KEYS - User Profile (7)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String USER_ID = 'user_id'; // Unique user identifier
  static const String USER_NAME = 'user_name'; // Display name
  static const String USER_EMAIL = 'email'; // Email address
  static const String PROFILE_IMAGE = 'profile_image'; // Avatar URL
  static const String BIO = 'bio'; // User bio/description
  static const String PHONE = 'phone'; // Phone number
  static const String ADDRESS = 'address'; // User address

  // ═══════════════════════════════════════════════════════════════════════════
  // STORAGE KEYS - Location & Device (4)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String LATITUDE = 'latitude'; // GPS latitude
  static const String LONGITUDE = 'longitude'; // GPS longitude
  static const String SELECTED_COUNTRY = 'selected_country'; // Country code
  static const String ANDROID_ID = 'android_id'; // Device identifier

  // ═══════════════════════════════════════════════════════════════════════════
  // STORAGE KEYS - App Settings (1)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String LANGUAGE_CODE = 'language_code'; // Locale (en, es, etc.)

  // ═══════════════════════════════════════════════════════════════════════════
  // STORAGE KEYS - Showcase Tour (5)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_DASHBOARD = 'showcase_dashboard_shown'; // Dashboard tour completed
  static const String SHOWCASE_CREATE_EVENT = 'showcase_create_event_shown'; // Create event tour completed
  static const String SHOWCASE_EVENT_GALLERY = 'showcase_event_gallery_shown'; // Event gallery tour completed
  static const String SHOWCASE_INVITE_USERS = 'showcase_invite_users_shown'; // Invite users tour completed
  static const String SHOWCASE_INVITED_GALLERY = 'showcase_invited_gallery_shown'; // Invited event gallery tour completed

  // ═══════════════════════════════════════════════════════════════════════════
  // STORAGE KEYS - Event Cache (3)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String EVENT_GALLERY_CACHE = "event_gallery_cache"; // Cached gallery data
  static const String EVENT_SYNC_DONE = "event_sync_done"; // Sync completion flag
  static const String EVENT_UPLOADED_HASHES = "uploaded_hashes"; // Prevent duplicate uploads

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS & SETTERS - Authentication
  // ═══════════════════════════════════════════════════════════════════════════
  static String get token => box.get(TOKEN, defaultValue: '') ?? '';
  static set token(String value) => box.put(TOKEN, value);

  static bool get isLoggedIn => box.get(IS_LOGGED_IN, defaultValue: false) ?? false;
  static set isLoggedIn(bool value) => box.put(IS_LOGGED_IN, value);

  static String get fcmToken => box.get(FCM_TOKEN, defaultValue: '');
  static set fcmToken(String value) => box.put(FCM_TOKEN, value);

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS & SETTERS - User Profile (reactive)
  // ═══════════════════════════════════════════════════════════════════════════
  static int get userId => userIdRx.value;
  static set userId(int value) {
    userIdRx.value = value;
    box.put(USER_ID, value);
  }

  static String get userName => userNameRx.value;
  static set userName(String value) {
    userNameRx.value = value;
    box.put(USER_NAME, value);
  }

  static String get email => userEmailRx.value;
  static set email(String value) {
    userEmailRx.value = value;
    box.put(USER_EMAIL, value);
  }

  static String? get profileImage => profileImageRx.value ?? box.get(PROFILE_IMAGE);
  static set profileImage(String? value) {
    profileImageRx.value = value;
    if (value != null) {
      box.put(PROFILE_IMAGE, value);
    } else {
      box.delete(PROFILE_IMAGE);
    }
  }

  static String get bio => bioRx.value;
  static set bio(String value) {
    bioRx.value = value;
    box.put(BIO, value);
  }

  static String get phone => phoneRx.value;
  static set phone(String value) {
    phoneRx.value = value;
    box.put(PHONE, value);
  }

  static String get address => addressRx.value;
  static set address(String value) {
    addressRx.value = value;
    box.put(ADDRESS, value);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS & SETTERS - Location & Device
  // ═══════════════════════════════════════════════════════════════════════════
  static double get latitude => (box.get(LATITUDE, defaultValue: 0.0) ?? 0.0).toDouble();
  static set latitude(double value) => box.put(LATITUDE, value);

  static double get longitude => (box.get(LONGITUDE, defaultValue: 0.0) ?? 0.0).toDouble();
  static set longitude(double value) => box.put(LONGITUDE, value);

  static String get selectedCountry => box.get(SELECTED_COUNTRY, defaultValue: '') ?? '';
  static set selectedCountry(String value) => box.put(SELECTED_COUNTRY, value);

  static String get androidID => box.get(ANDROID_ID, defaultValue: '') ?? '';
  static set androidID(String value) => box.put(ANDROID_ID, value);

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS & SETTERS - App Settings
  // ═══════════════════════════════════════════════════════════════════════════
  static String get languageCode => box.get(LANGUAGE_CODE, defaultValue: 'en') ?? 'en';
  static set languageCode(String value) => box.put(LANGUAGE_CODE, value);

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS & SETTERS - Showcase Tour
  // ═══════════════════════════════════════════════════════════════════════════
  static bool get showcaseDashboardShown => box.get(SHOWCASE_DASHBOARD, defaultValue: false) ?? false;
  static set showcaseDashboardShown(bool value) => box.put(SHOWCASE_DASHBOARD, value);

  static bool get showcaseCreateEventShown => box.get(SHOWCASE_CREATE_EVENT, defaultValue: false) ?? false;
  static set showcaseCreateEventShown(bool value) => box.put(SHOWCASE_CREATE_EVENT, value);

  static bool get showcaseEventGalleryShown => box.get(SHOWCASE_EVENT_GALLERY, defaultValue: false) ?? false;
  static set showcaseEventGalleryShown(bool value) => box.put(SHOWCASE_EVENT_GALLERY, value);

  static bool get showcaseInviteUsersShown => box.get(SHOWCASE_INVITE_USERS, defaultValue: false) ?? false;
  static set showcaseInviteUsersShown(bool value) => box.put(SHOWCASE_INVITE_USERS, value);

  static bool get showcaseInvitedGalleryShown => box.get(SHOWCASE_INVITED_GALLERY, defaultValue: false) ?? false;
  static set showcaseInvitedGalleryShown(bool value) => box.put(SHOWCASE_INVITED_GALLERY, value);

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  static void clearAll() {
    // Backup uploaded history before clearing
    var uploadedHashes = box.get(Preference.EVENT_UPLOADED_HASHES);

    box.clear();

    // Restore uploaded list so images never come again
    if (uploadedHashes != null) {
      box.put(Preference.EVENT_UPLOADED_HASHES, uploadedHashes);
    }

    // Reset reactive variables
    userIdRx.value = 0;
    userNameRx.value = '';
    userEmailRx.value = '';
    profileImageRx.value = null;
    bioRx.value = '';
    phoneRx.value = '';
    addressRx.value = '';
  }
}