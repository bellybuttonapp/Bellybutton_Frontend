part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const LOGIN = _Paths.LOGIN;
  static const SIGNUP = _Paths.SIGNUP;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;
  static const UPCOMMING_EVENT =
      _Paths.DASHBOARD + _Paths.INNERMODULE + _Paths.UPCOMMING_EVENT;
  static const PAST_EVENT =
      _Paths.DASHBOARD + _Paths.INNERMODULE + _Paths.PAST_EVENT;
  static const PROFILE = _Paths.PROFILE;
  static const ACCOUNT_DETAILS =
      _Paths.PROFILE + _Paths.INNERMODULE + _Paths.ACCOUNT_DETAILS;
  static const CREATE_EVENT =
      _Paths.DASHBOARD + _Paths.INNERMODULE + _Paths.CREATE_EVENT;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const DASHBOARD = '/dashboard';
  static const INNERMODULE = '/innermodule';
  static const NOTIFICATIONS = '/notifications';
  static const UPCOMMING_EVENT = '/upcomming-event';
  static const PAST_EVENT = '/past-event';
  static const PROFILE = '/profile';
  static const ACCOUNT_DETAILS = '/account-details';
  static const CREATE_EVENT = '/create-event';
}
