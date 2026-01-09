import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../modules/Auth/phone_login/bindings/phone_login_binding.dart';
import '../modules/Auth/phone_login/views/phone_login_view.dart';
import '../modules/Auth/login_otp/bindings/login_otp_binding.dart';
import '../modules/Auth/login_otp/views/login_otp_view.dart';
import '../modules/Auth/profile_setup/bindings/profile_setup_binding.dart';
import '../modules/Auth/profile_setup/views/profile_setup_view.dart';
import '../modules/Dashboard/Innermodule/EventInvitations/bindings/event_invitations_binding.dart';
import '../modules/Dashboard/Innermodule/EventInvitations/views/event_invitations_view.dart';
import '../modules/Dashboard/Innermodule/Event_gallery/bindings/event_gallery_binding.dart';
import '../modules/Dashboard/Innermodule/Event_gallery/views/event_gallery_view.dart';
import '../modules/Dashboard/Innermodule/InvitedAdminsList/bindings/invited_admins_list_binding.dart';
import '../modules/Dashboard/Innermodule/InvitedAdminsList/views/invited_admins_list_view.dart';
import '../modules/Dashboard/Innermodule/InvitedEventGallery/bindings/invited_event_gallery_binding.dart';
import '../modules/Dashboard/Innermodule/InvitedEventGallery/views/invited_event_gallery_view.dart';
import '../modules/Dashboard/Innermodule/InvitedUsersList/bindings/invited_users_list_binding.dart';
import '../modules/Dashboard/Innermodule/InvitedUsersList/views/invited_users_list_view.dart';
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
import '../modules/PhotoPre/bindings/photo_pre_binding.dart';
import '../modules/PhotoPre/views/photo_pre_view.dart';
import '../modules/Premium/bindings/premium_binding.dart';
import '../modules/Premium/views/premium_view.dart';
import '../modules/Profile/Innermodule/Account_Details/bindings/account_details_binding.dart';
import '../modules/Profile/Innermodule/Account_Details/views/account_details_view.dart';
import '../modules/Profile/bindings/profile_binding.dart';
import '../modules/Profile/views/profile_view.dart';
import '../modules/SharedEventGallery/bindings/shared_event_gallery_binding.dart';
import '../modules/SharedEventGallery/views/shared_event_gallery_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/terms_and_conditions/bindings/terms_and_conditions_binding.dart';
import '../modules/terms_and_conditions/views/terms_and_conditions_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';


// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Default initial route (actual route determined by MainInitializer.getInitialRoute)
  static const INITIAL = Routes.PHONE_LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      curve: Curves.linear,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
      curve: Curves.easeOutCirc,
      transitionDuration: Duration(milliseconds: 400),
      children: [
        GetPage(
          name: _Paths.UPCOMMING_EVENT,
          page: () => UpcommingEventView(),
          binding: UpcommingEventBinding(),
          transition: Transition.downToUp,
          curve: Curves.easeOutQuint,
          transitionDuration: Duration(milliseconds: 350),
        ),
        GetPage(
          name: _Paths.PAST_EVENT,
          page: () => PastEventView(),
          binding: PastEventBinding(),
          transition: Transition.leftToRight,
          curve: Curves.easeOutQuad,
          transitionDuration: Duration(milliseconds: 350),
        ),
        GetPage(
          name: _Paths.CREATE_EVENT,
          page: () => CreateEventView(),
          binding: CreateEventBinding(),
          transition: Transition.zoom,
          curve: Curves.easeOutBack,
          transitionDuration: Duration(milliseconds: 400),
        ),
        GetPage(
          name: _Paths.EVENT_GALLERY,
          page: () => EventGalleryView(),
          binding: EventGalleryBinding(),
          transition: Transition.fadeIn,
          curve: Curves.easeOutSine,
          transitionDuration: Duration(milliseconds: 350),
        ),
        GetPage(
          name: _Paths.INVITED_USERS_LIST,
          page: () => const InvitedUsersListView(),
          binding: InvitedUsersListBinding(),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeOutCubic,
          transitionDuration: Duration(milliseconds: 350),
        ),
        GetPage(
          name: _Paths.INVITED_ADMINS_LIST,
          page: () => const InvitedAdminsListView(),
          binding: InvitedAdminsListBinding(),
          transition: Transition.rightToLeft,
          curve: Curves.easeOutQuad,
          transitionDuration: Duration(milliseconds: 350),
        ),
      ],
    ),
    // Top-level routes for deep link access
    GetPage(
      name: _Paths.EVENT_INVITATIONS,
      page: () => EventInvitationsView(),
      binding: EventInvitationsBinding(),
      transition: Transition.downToUp,
      curve: Curves.easeOutQuart,
      transitionDuration: Duration(milliseconds: 350),
    ),
    GetPage(
      name: _Paths.INVITED_EVENT_GALLERY,
      page: () => InvitedEventGalleryView(),
      binding: InvitedEventGalleryBinding(),
      transition: Transition.cupertino,
      curve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 350),
    ),
    GetPage(
      name: _Paths.INVITEUSER,
      page: () => InviteuserView(),
      binding: InviteuserBinding(),
      transition: Transition.zoom,
      curve: Curves.easeOutBack,
      transitionDuration: Duration(milliseconds: 400),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.upToDown,
      curve: Curves.easeOutQuint,
      transitionDuration: Duration(milliseconds: 350),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.fadeIn,
      curve: Curves.easeInOutSine,
      transitionDuration: Duration(milliseconds: 400),
      children: [
        GetPage(
          name: _Paths.ACCOUNT_DETAILS,
          page: () => AccountDetailsView(),
          binding: AccountDetailsBinding(),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeOutCubic,
          transitionDuration: Duration(milliseconds: 350),
        ),
      ],
    ),
    GetPage(
      name: _Paths.PREMIUM,
      page: () => PremiumView(),
      binding: PremiumBinding(),
      transition: Transition.zoom,
      curve: Curves.elasticOut,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.PHOTO_PRE,
      page: () => PhotoPreView(),
      binding: PhotoPreBinding(),
      transition: Transition.cupertino,
      curve: Curves.easeOutSine,
      transitionDuration: Duration(milliseconds: 350),
    ),
    GetPage(
      name: _Paths.TERMS_AND_CONDITIONS,
      page: () => const TermsAndConditionsView(),
      binding: TermsAndConditionsBinding(),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOutCubic,
      transitionDuration: Duration(milliseconds: 350),
    ),
    GetPage(
      name: _Paths.SHARED_EVENT_GALLERY,
      page: () => const SharedEventGalleryView(),
      binding: SharedEventGalleryBinding(),
    ),
    // Phone OTP Login Routes
    GetPage(
      name: _Paths.PHONE_LOGIN,
      page: () => const PhoneLoginView(),
      binding: PhoneLoginBinding(),
      transition: Transition.fadeIn,
      preventDuplicates: true,
      curve: Curves.easeOutCubic,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: _Paths.LOGIN_OTP,
      page: () => const LoginOtpView(),
      binding: LoginOtpBinding(),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOutCubic,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: _Paths.PROFILE_SETUP,
      page: () => const ProfileSetupView(),
      binding: ProfileSetupBinding(),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOutCubic,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    // Onboarding
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
      curve: Curves.easeOutCubic,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];
}
