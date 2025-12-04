// ignore_for_file: curly_braces_in_flow_control_structures, unrelated_type_equality_checks, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:bellybutton/app/Controllers/oauth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../api/PublicApiService.dart';
import '../../../../core/utils/helpers/validation_utils.dart';
import '../../../../core/utils/storage/preference.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../routes/app_pages.dart';
import '../../forgot_password/views/forgot_password_view.dart';

class SignupController extends GetxController {
  final AuthService _authService = AuthService();

  // Loader
  final isLoading = false.obs;

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Error fields
  final nameError = RxnString();
  final emailError = RxnString();
  final passwordError = RxnString();

  // UI
  final isPasswordHidden = true.obs;
  final rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  //----------------------------------------------------
  // VALIDATE FIELDS
  //----------------------------------------------------
  void validateName(String value) =>
      nameError.value = Validation.validateName(value);

  void validateEmail(String value) =>
      emailError.value = Validation.validateEmail(value);

  void validatePassword(String value) =>
      passwordError.value = Validation.validatePassword(value);

  //----------------------------------------------------
  // REMEMBER ME
  //----------------------------------------------------
  Future<void> saveUserData({String? name, String? email}) async {
    if (rememberMe.value) {
      Preference.userName = name ?? nameController.text.trim();
      Preference.email = email ?? emailController.text.trim();
    } else {
      Preference.userName = '';
      Preference.email = '';
    }
  }

  Future<void> loadUserData() async {
    if (Preference.userName.isNotEmpty && Preference.email.isNotEmpty) {
      nameController.text = Preference.userName;
      emailController.text = Preference.email;
      rememberMe.value = true;
    }
  }

  //----------------------------------------------------
  // UPDATE PREFS
  //----------------------------------------------------
  void _saveUserPreferences({
    required String name,
    required String email,
    String? photo,
  }) {
    Preference.isLoggedIn = true;
    Preference.email = email;
    Preference.userName = name;
    Preference.profileImage = photo;
  }

  //----------------------------------------------------
  // SIGNUP
  //----------------------------------------------------
  Future<void> signup({bool rememberMe = false}) async {
    this.rememberMe.value = rememberMe;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    nameError.value = Validation.validateName(name);
    emailError.value = Validation.validateEmail(email);
    passwordError.value = Validation.validatePassword(password);

    if (nameError.value != null ||
        emailError.value != null ||
        passwordError.value != null)
      return;

    isLoading.value = true;

    try {
      final emailCheck = await _authService.checkEmailAvailability(email);

      // ignore unauthorized email check
      if (emailCheck['headers']?['statusCode'] != 401) {
        if (!(emailCheck['data']?['available'] ?? true)) {
          showCustomSnackBar(
            AppTexts.EMAIL_ALREADY_EXISTS,
            SnackbarState.error,
          );
          return;
        }
      }

      final result = await _authService.registerWithAPI(
        name: name,
        email: email,
        password: password,
        profilePhoto: null,
      );

      if (result['message'] == "No internet connection.") {
        showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
        return;
      }

      final success = result['headers']?['status'] == 'success';
      final userId = result['data']?['id'];

      if (success && userId != null) {
        if (rememberMe) await saveUserData(name: name, email: email);

        _saveUserPreferences(name: name, email: email, photo: null);

        // ✅ Upload FCM token AFTER signup
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

        showCustomSnackBar(AppTexts.SIGNUP_SUCCESS, SnackbarState.success);

        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        showCustomSnackBar(AppTexts.SIGNUP_FAILED, SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  //----------------------------------------------------
  // GOOGLE SIGN-IN
  //----------------------------------------------------
  Future<void> signInWithGoogle() async {
    isLoading.value = true;

    try {
      final user = await _authService.signInWithGoogle();

      if (user == null) {
        showCustomSnackBar(
          AppTexts.GOOGLE_SIGNIN_CANCELED,
          SnackbarState.error,
        );
        return;
      }

      final email = user.user?.email ?? "";
      final name = user.user?.displayName ?? "";

      await saveUserData(name: name, email: email);
      _saveUserPreferences(name: name, email: email);

      showCustomSnackBar(AppTexts.GOOGLE_SIGNIN_SUCCESS, SnackbarState.success);

      Get.offAllNamed(Routes.DASHBOARD);
    } on SocketException {
      showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
    } catch (_) {
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  //----------------------------------------------------
  // NAVIGATION
  //----------------------------------------------------
  void navigateToLogin() => Get.toNamed(Routes.LOGIN);

  void forgetPassword() => Get.to(
    () => ForgotPasswordView(),
    transition: Transition.rightToLeft,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
