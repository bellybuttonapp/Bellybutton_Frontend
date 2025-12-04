// ignore_for_file: unrelated_type_equality_checks, curly_braces_in_flow_control_structures, avoid_print, unnecessary_type_check

import 'package:bellybutton/app/core/utils/storage/preference.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../Controllers/oauth.dart';
import '../../../../api/PublicApiService.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/utils/helpers/validation_utils.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../routes/app_pages.dart';
import '../../forgot_password/views/forgot_password_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  final storage = GetStorage();

  final isGoogleLoading = false.obs;
  final isLoading = false.obs;

  // controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // error fields
  final emailError = RxnString();
  final passwordError = RxnString();

  final rememberMe = false.obs;
  final isPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRememberedUser();
  }

  //----------------------------------------------------
  // LOAD SAVED EMAIL
  //----------------------------------------------------
  void _loadRememberedUser() {
    final savedEmail = storage.read('email');
    final savedRemember = storage.read('rememberMe') ?? false;

    if (savedRemember && savedEmail != null) {
      emailController.text = savedEmail;
      rememberMe.value = true;
    }
  }

  //----------------------------------------------------
  // VALIDATE FIELDS
  //----------------------------------------------------
  void validateEmail(String value) =>
      emailError.value = Validation.validateEmail(value);

  void validatePassword(String value) =>
      passwordError.value = Validation.validatePassword(value);

  //----------------------------------------------------
  // LOGIN FUNCTION
  //----------------------------------------------------
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    emailError.value = Validation.validateEmail(email);
    passwordError.value = Validation.validatePassword(password);

    if (emailError.value != null || passwordError.value != null) return;

    isLoading.value = true;

    try {
      final result = await _authService.loginWithAPI(
        email: email,
        password: password,
      );

      final headers = result['headers'] ?? {};
      final isSuccess =
          headers['status'] == 'success' || headers['statusCode'] == 200;

      if (isSuccess) {
        _handleRememberMe(email);

        final data = result['data'];

        // set values
        final rawToken = data['accessToken']?.trim() ?? '';
        Preference.token = rawToken;
        Preference.userId = data['userId'];
        Preference.email = data['email'];
        Preference.userName = (data['message'] ?? '').split(':').last.trim();
        Preference.profileImage = data['profilePhoto'] ?? '';
        Preference.isLoggedIn = true;

        print("🔵 LOGGED IN USER ID → ${Preference.userId}");
        print("🔵 TOKEN STORED → $rawToken");

        // ✅ Upload FCM token AFTER login
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          Preference.fcmToken = fcmToken;
          await PublicApiService().updateFcmToken(fcmToken);
        }

        // ✅ Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          if (Preference.token.isNotEmpty) {
            Preference.fcmToken = newToken;
            await PublicApiService().updateFcmToken(newToken);
          }
        });

        showCustomSnackBar(AppTexts.LOGIN_SUCCESS, SnackbarState.success);

        Future.delayed(const Duration(milliseconds: 200), () {
          Get.offAllNamed(Routes.DASHBOARD);
        });

        return;
      }

      showCustomSnackBar(
        headers['message'] ?? AppTexts.LOGIN_INVALID_CREDENTIAL,
        SnackbarState.error,
      );
    } catch (_) {
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  //----------------------------------------------------
  // REMEMBER ME
  //----------------------------------------------------
  void _handleRememberMe(String email) {
    if (rememberMe.value) {
      storage.write('email', email);
      storage.write('rememberMe', true);
    } else {
      storage.remove('email');
      storage.write('rememberMe', false);
    }
  }

  //----------------------------------------------------
  // GOOGLE LOGIN
  //----------------------------------------------------
  Future<void> onSigninWithGoogle() async {
    isGoogleLoading.value = true;

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
        return;
      }

      final googleUser = await _authService.signInWithGoogle();

      if (googleUser != null) {
        Preference.isLoggedIn = true;
        Preference.email = googleUser.user?.email ?? '';

        showCustomSnackBar(
          AppTexts.GOOGLE_SIGNIN_SUCCESS,
          SnackbarState.success,
        );

        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        showCustomSnackBar(
          AppTexts.GOOGLE_SIGNIN_CANCELED,
          SnackbarState.error,
        );
      }
    } catch (_) {
      showCustomSnackBar(AppTexts.GOOGLE_SIGNIN_FAILED, SnackbarState.error);
    } finally {
      isGoogleLoading.value = false;
    }
  }

  //----------------------------------------------------
  // NAVIGATION
  //----------------------------------------------------
  void navigateToSignup() => Get.toNamed(Routes.SIGNUP);

  void forgetPassword() => Get.to(
    () => ForgotPasswordView(),
    transition: Transition.rightToLeft,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
