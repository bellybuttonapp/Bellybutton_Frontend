// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

// 🚀 CLEAN AND CONSISTENT ROUTE DEFINITIONS
abstract class Routes {
  Routes._();

  // 🌟 Main Screens
  static const HOME = _Paths.HOME;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const LOGIN = _Paths.LOGIN;
  static const SIGNUP = _Paths.SIGNUP;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;

  // 📅 Event Screens
  static const UPCOMMING_EVENT = _Paths.UPCOMMING_EVENT;
  static const PAST_EVENT = _Paths.PAST_EVENT;
  static const CREATE_EVENT = _Paths.DASHBOARD + _Paths.CREATE_EVENT;
  static const INVITEUSER = _Paths.INVITEUSER;
  static const EVENT_GALLERY = _Paths.EVENT_GALLERY;

  // 👤 Profile Screens
  static const PROFILE = _Paths.PROFILE;
  static const ACCOUNT_DETAILS = _Paths.ACCOUNT_DETAILS;
  static const RESET_PASSWORD = _Paths.RESET_PASSWORD;

  // 💎 Premium & Auth
  static const PREMIUM = _Paths.PREMIUM;
  static const SET_NEW_PASSWORD_VIEW = _Paths.SET_NEW_PASSWORD_VIEW;
}

// 🌐 PATHS
abstract class _Paths {
  _Paths._();

  static const HOME = '/home';
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const DASHBOARD = '/dashboard';
  static const NOTIFICATIONS = '/notifications';

  // Event
  static const UPCOMMING_EVENT = '/upcomming-event';
  static const PAST_EVENT = '/past-event';
  static const CREATE_EVENT = '/create-event';
  static const INVITEUSER = '/inviteuser';
  static const EVENT_GALLERY = '/event-gallery';

  // Profile
  static const PROFILE = '/profile';
  static const ACCOUNT_DETAILS = '/account-details';
  static const RESET_PASSWORD = '/reset-password';

  // Auth / Premium
  static const PREMIUM = '/premium';
  static const SET_NEW_PASSWORD_VIEW = '/set-new-password-view';
}
