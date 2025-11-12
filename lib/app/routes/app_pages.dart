import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../modules/Auth/SetNewPasswordView/bindings/set_new_password_view_binding.dart';
import '../modules/Auth/SetNewPasswordView/views/set_new_password_view_view.dart';
import '../modules/Auth/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/Auth/forgot_password/views/forgot_password_view.dart';
import '../modules/Auth/login/bindings/login_binding.dart';
import '../modules/Auth/login/views/login_view.dart';
import '../modules/Auth/signup/bindings/signup_binding.dart';
import '../modules/Auth/signup/views/signup_view.dart';
import '../modules/Dashboard/Innermodule/Event_gallery/bindings/event_gallery_binding.dart';
import '../modules/Dashboard/Innermodule/Event_gallery/views/event_gallery_view.dart';
import '../modules/Dashboard/Innermodule/Past_Event/bindings/past_event_binding.dart';
import '../modules/Dashboard/Innermodule/Past_Event/views/past_event_view.dart';
import '../modules/Dashboard/Innermodule/Upcomming_Event/bindings/upcomming_event_binding.dart';
import '../modules/Dashboard/Innermodule/Upcomming_Event/views/upcomming_event_view.dart';
import '../modules/Dashboard/Innermodule/create_event/bindings/create_event_binding.dart';
import '../modules/Dashboard/Innermodule/create_event/views/create_event_view.dart';
import '../modules/Dashboard/Innermodule/inviteuser/bindings/inviteuser_binding.dart';
import '../modules/Dashboard/Innermodule/inviteuser/views/inviteuser_view.dart';
import '../modules/Dashboard/bindings/dashboard_binding.dart';
import '../modules/Dashboard/views/dashboard_view.dart';
import '../modules/Notifications/bindings/notifications_binding.dart';
import '../modules/Notifications/views/notifications_view.dart';
import '../modules/Premium/bindings/premium_binding.dart';
import '../modules/Premium/views/premium_view.dart';
import '../modules/Profile/Innermodule/Account_Details/bindings/account_details_binding.dart';
import '../modules/Profile/Innermodule/Account_Details/views/account_details_view.dart';
import '../modules/Profile/Innermodule/Reset_password/bindings/reset_password_binding.dart';
import '../modules/Profile/Innermodule/Reset_password/views/reset_password_view.dart';
import '../modules/Profile/bindings/profile_binding.dart';
import '../modules/Profile/views/profile_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.ONBOARDING;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      curve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 400),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.downToUp,
      curve: Curves.fastOutSlowIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
      transition: Transition.fade,
      preventDuplicates: true,
      curve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 400),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => SignupView(),
      binding: SignupBinding(),
      transition: Transition.downToUp,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 400),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
      transition: Transition.zoom,
      curve: Curves.easeInOutBack,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      transition: Transition.fade,
      curve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 400),
      children: [
        GetPage(
          name: _Paths.UPCOMMING_EVENT,
          page: () => UpcommingEventView(),
          binding: UpcommingEventBinding(),
          transition: Transition.fade,
          curve: Curves.easeInOut,
          transitionDuration: Duration(milliseconds: 400),
        ),
        GetPage(
          name: _Paths.PAST_EVENT,
          page: () => PastEventView(),
          binding: PastEventBinding(),
          transition: Transition.fade,
          curve: Curves.easeInOut,
          transitionDuration: Duration(milliseconds: 400),
        ),
        GetPage(
          name: _Paths.CREATE_EVENT,
          page: () => CreateEventView(),
          binding: CreateEventBinding(),
          transition: Transition.fade,
          curve: Curves.easeInOut,
          transitionDuration: Duration(milliseconds: 400),
        ),
        GetPage(
          name: _Paths.EVENT_GALLERY,
          page: () => EventGalleryView(),
          binding: EventGalleryBinding(),
          transition: Transition.fade,
          curve: Curves.easeInOut,
          transitionDuration: Duration(milliseconds: 400),
        ),
      ],
    ),
    GetPage(
      name: _Paths.INVITEUSER,
      page: () => InviteuserView(),
      binding: InviteuserBinding(),
      transition: Transition.fade,
      curve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 400),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.fade,
      curve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 400),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.fade,
      curve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 400),
      children: [
        GetPage(
          name: _Paths.ACCOUNT_DETAILS,
          page: () => AccountDetailsView(),
          binding: AccountDetailsBinding(),
          transition: Transition.fade,
          curve: Curves.easeInOut,
          transitionDuration: Duration(milliseconds: 400),
        ),
        GetPage(
          name: _Paths.RESET_PASSWORD,
          page: () => ResetPasswordView(),
          binding: ResetPasswordBinding(),
          transition: Transition.fade,
          curve: Curves.easeInOut,
          transitionDuration: Duration(milliseconds: 400),
        ),
      ],
    ),
    GetPage(
      name: _Paths.PREMIUM,
      page: () => PremiumView(),
      binding: PremiumBinding(),
      transition: Transition.fade,
      curve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 400),
    ),
    GetPage(
      name: _Paths.SET_NEW_PASSWORD_VIEW,
      page: () => SetNewPasswordView(),
      binding: SetNewPasswordViewBinding(),
      transition: Transition.fade,
      curve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 400),
    ),
  ];
}
// End of file
// lib/app/routes/app_pages.dart