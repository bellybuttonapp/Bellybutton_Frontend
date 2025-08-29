// ignore_for_file: unrelated_type_equality_checks

import 'package:bellybutton/app/Controllers/oauth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../routes/app_pages.dart';
import '../../forgot_password/views/forgot_password_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  final storage = GetStorage(); // ✅ Local storage instance

  /// Loading states
  var isGoogleLoading = false.obs;
  var isLoading = false.obs;

  /// Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// Validation error messages
  final emailError = ''.obs;
  final passwordError = ''.obs;

  /// Misc
  final rememberMe = false.obs;
  final isPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRememberedUser();
  }

  /// =========================
  /// LOAD REMEMBERED EMAIL
  /// =========================
  void _loadRememberedUser() {
    final savedEmail = storage.read('email');
    final savedRemember = storage.read('rememberMe') ?? false;

    if (savedRemember && savedEmail != null) {
      emailController.text = savedEmail;
      rememberMe.value = true;
    }
  }

  /// =========================
  /// EMAIL & PASSWORD LOGIN
  /// =========================
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Reset errors
    emailError.value = '';
    passwordError.value = '';

    // Validate inputs
    final emailValidation = _validateEmail(email);
    final passwordValidation = _validatePassword(password);
    if (emailValidation != null) emailError.value = emailValidation;
    if (passwordValidation != null) passwordError.value = passwordValidation;

    if (emailError.value.isNotEmpty || passwordError.value.isNotEmpty) return;

    isLoading.value = true;

    try {
      final userCredential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        // ✅ Save only email if Remember Me is checked
        if (rememberMe.value) {
          storage.write('email', email);
          storage.write('rememberMe', true);
        } else {
          storage.remove('email');
          storage.write('rememberMe', false);
        }

        // ✅ Use centralized success message
        showCustomSnackBar(
          "${AppTexts.loginSuccess} (${userCredential.user?.displayName ?? userCredential.user?.email})",
          SnackbarState.success,
        );
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          emailError.value = AppTexts.loginNoUser;
          showCustomSnackBar(AppTexts.loginNoUser, SnackbarState.error);
          break;

        case 'wrong-password':
          passwordError.value = AppTexts.loginWrongPassword;
          showCustomSnackBar(AppTexts.loginWrongPassword, SnackbarState.error);
          break;

        case 'invalid-email':
          emailError.value = AppTexts.loginInvalidEmail;
          showCustomSnackBar(AppTexts.loginInvalidEmail, SnackbarState.error);
          break;

        case 'invalid-credential':
        case 'INVALID_LOGIN_CREDENTIALS':
          showCustomSnackBar(
            AppTexts.loginInvalidCredential,
            SnackbarState.error,
          );
          break;

        default:
          if (e.message?.contains('supplied auth credential is incorrect') ??
              false) {
            showCustomSnackBar(
              AppTexts.authCredentialError,
              SnackbarState.error,
            );
          } else {
            showCustomSnackBar(
              e.message ?? AppTexts.loginFailed,
              SnackbarState.error,
            );
          }
      }
    } catch (e) {
      showCustomSnackBar(AppTexts.loginFailed, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// =========================
  /// GOOGLE SIGN-IN
  /// =========================
  Future<void> onSigninWithGoogle() async {
    isGoogleLoading.value = true;

    try {
      // 🔹 Check internet
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        showCustomSnackBar(AppTexts.noInternet, SnackbarState.error);
        return;
      }

      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        showCustomSnackBar(AppTexts.googleSignInSuccess, SnackbarState.success);
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        showCustomSnackBar(AppTexts.googleSignInCanceled, SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar(AppTexts.googleSignInFailed, SnackbarState.error);
    } finally {
      isGoogleLoading.value = false;
    }
  }

  /// =========================
  /// NAVIGATION
  /// =========================
  void navigateToSignup() => Get.toNamed(Routes.SIGNUP);

  void forgetPassword() => Get.to(
    () => ForgotPasswordView(),
    transition: Transition.rightToLeft,
    duration: const Duration(milliseconds: 300),
  );

  /// =========================
  /// INPUT VALIDATION
  /// =========================
  void validateEmail(String value) =>
      emailError.value = _validateEmail(value) ?? '';

  void validatePassword(String value) =>
      passwordError.value = _validatePassword(value) ?? '';

  String? _validateEmail(String email, {bool userNotFound = false}) {
    if (email.isEmpty) return 'Please enter your email';
    if (!GetUtils.isEmail(email)) return 'Enter a valid email';
    if (userNotFound) return 'No user found for this email';
    return null;
  }

  String? _validatePassword(String password, {bool wrongPassword = false}) {
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (wrongPassword) return 'Incorrect password';
    return null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
