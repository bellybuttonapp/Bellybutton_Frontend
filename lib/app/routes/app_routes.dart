// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

// 🚀 CLEAN AND CONSISTENT ROUTE DEFINITIONS
abstract class Routes {
  Routes._();

  // 🎬 Splash
  static const SPLASH = _Paths.SPLASH;

  // 🌟 Main Screens
  static const HOME = _Paths.HOME;
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

  // 💎 Premium
  static const PREMIUM = _Paths.PREMIUM;
  static const INVITED_USERS_LIST =
      _Paths.DASHBOARD + _Paths.INVITED_USERS_LIST;
  // Top-level routes for deep link access
  static const EVENT_INVITATIONS = _Paths.EVENT_INVITATIONS;
  static const INVITED_EVENT_GALLERY = _Paths.INVITED_EVENT_GALLERY;
  static const PHOTO_PRE = _Paths.PHOTO_PRE;
  static const INVITED_ADMINS_LIST =
      _Paths.DASHBOARD + _Paths.INVITED_ADMINS_LIST;
  static const TERMS_AND_CONDITIONS = _Paths.TERMS_AND_CONDITIONS;
  static const SHARED_EVENT_GALLERY = _Paths.SHARED_EVENT_GALLERY;

  // 📱 Phone OTP Login
  static const PHONE_LOGIN = _Paths.PHONE_LOGIN;
  static const LOGIN_OTP = _Paths.LOGIN_OTP;
  static const PROFILE_SETUP = _Paths.PROFILE_SETUP;

  // 🎯 Onboarding
  static const ONBOARDING = _Paths.ONBOARDING;
}

// 🌐 PATHS
abstract class _Paths {
  _Paths._();

  static const SPLASH = '/splash';
  static const HOME = '/home';
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

  // Premium
  static const PREMIUM = '/premium';
  static const INVITED_USERS_LIST = '/invited-users-list';
  static const EVENT_INVITATIONS = '/event-invitations';
  static const INVITED_EVENT_GALLERY = '/invited-event-gallery';
  static const PHOTO_PRE = '/photo-pre';
  static const INVITED_ADMINS_LIST = '/invited-admins-list';
  static const TERMS_AND_CONDITIONS = '/terms-and-conditions';
  static const SHARED_EVENT_GALLERY = '/shared-event-gallery';

  // Phone OTP Login
  static const PHONE_LOGIN = '/phone-login';
  static const LOGIN_OTP = '/login-otp';
  static const PROFILE_SETUP = '/profile-setup';

  // Onboarding
  static const ONBOARDING = '/onboarding';
}
