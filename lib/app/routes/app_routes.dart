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
  static const INVITED_USERS_LIST =
      _Paths.DASHBOARD + _Paths.INVITED_USERS_LIST;
  static const EVENT_INVITATIONS = _Paths.DASHBOARD + _Paths.EVENT_INVITATIONS;
  static const INVITED_EVENT_GALLERY =
      _Paths.DASHBOARD + _Paths.INVITED_EVENT_GALLERY;
  static const PHOTO_PRE = _Paths.PHOTO_PRE;
  static const INVITED_ADMINS_LIST =
      _Paths.DASHBOARD + _Paths.INVITED_ADMINS_LIST;
  static const SIGNUP_OTP = _Paths.SIGNUP_OTP;
  static const TERMS_AND_CONDITIONS = _Paths.TERMS_AND_CONDITIONS;
  static const SHARED_EVENT_GALLERY = _Paths.SHARED_EVENT_GALLERY;
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
  static const INVITED_USERS_LIST = '/invited-users-list';
  static const EVENT_INVITATIONS = '/event-invitations';
  static const INVITED_EVENT_GALLERY = '/invited-event-gallery';
  static const PHOTO_PRE = '/photo-pre';
  static const INVITED_ADMINS_LIST = '/invited-admins-list';
  static const SIGNUP_OTP = '/signup-otp';
  static const TERMS_AND_CONDITIONS = '/terms-and-conditions';
  static const SHARED_EVENT_GALLERY = '/shared-event-gallery';
}
