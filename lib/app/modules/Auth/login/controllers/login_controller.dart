// ignore_for_file: unrelated_type_equality_checks, curly_braces_in_flow_control_structures, avoid_print

import 'package:bellybutton/app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../Controllers/oauth.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../routes/app_pages.dart';
import '../../forgot_password/views/forgot_password_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  final storage = GetStorage(); // Local storage instance

  // Loading states
  var isGoogleLoading = false.obs;
  var isLoading = false.obs;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Validation error messages
  final emailError = ''.obs;
  final passwordError = ''.obs;

  // Misc
  final rememberMe = false.obs;
  final isPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRememberedUser();
  }

  void _loadRememberedUser() {
    final savedEmail = storage.read('email');
    final savedRemember = storage.read('rememberMe') ?? false;

    if (savedRemember && savedEmail != null) {
      emailController.text = savedEmail;
      rememberMe.value = true;
    }
  }

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
    // 1️⃣ Check if email exists
    final emailCheck = await _authService.checkEmailAvailability(email);
    if (emailCheck['available'] == true) {
      showCustomSnackBar('Email not found. Please register first.', SnackbarState.error);
      return;
    }

    // 2️⃣ Proceed with login
    final result = await _authService.loginWithAPI(
      email: email,
      password: password,
    );

    // Handle no internet
    if (result['message'] == "No internet connection.") {
      showCustomSnackBar(result['message'], SnackbarState.error);
      return;
    }

    // 3️⃣ Handle success or failure
    if (result['result'] == true || result['status'] == 'success') {
      _handleRememberMe(email);
      Preference.isLoggedIn = true;
      Preference.email = email;
      Preference.userName = result['name'] ?? 'User';
      Preference.profileImage = result['profilePhoto'];

      showCustomSnackBar(result['notification'] ?? 'Login successful', SnackbarState.success);
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      // Handle invalid credentials or general errors
      final errorMessage = result['message'] ??
          result['error'] ??
          'Invalid email or password';
      showCustomSnackBar(errorMessage, SnackbarState.error);
    }
  } catch (e, stackTrace) {
    print('Login error: $e\n$stackTrace');
    showCustomSnackBar('Something went wrong. Please try again.', SnackbarState.error);
  } finally {
    isLoading.value = false;
  }
}


  /// ✅ Helper to handle Remember Me
  void _handleRememberMe(String email) {
    if (rememberMe.value) {
      storage.write('email', email);
      storage.write('rememberMe', true);
    } else {
      storage.remove('email');
      storage.write('rememberMe', false);
    }
  }

  /// =====================
  /// SigninWithGoogle FUNCTION
  /// =====================
  Future<void> onSigninWithGoogle() async {
    isGoogleLoading.value = true;

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        showCustomSnackBar(AppTexts.noInternet, SnackbarState.error);
        return;
      }

      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        Preference.isLoggedIn = true;
        Preference.email = userCredential.user?.email ?? '';

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

  void navigateToSignup() => Get.toNamed(Routes.SIGNUP);

  /// =====================
  /// forgetPassword FUNCTION
  /// =====================
  void forgetPassword() => Get.to(
    () => ForgotPasswordView(),
    transition: Transition.rightToLeft,
    duration: const Duration(milliseconds: 300),
  );

  void validateEmail(String value) =>
      emailError.value = _validateEmail(value) ?? '';

  void validatePassword(String value) =>
      passwordError.value = _validatePassword(value) ?? '';

  /// =====================
  /// EMAIL VALIDATION
  /// =====================
  String? _validateEmail(String email, {bool userNotFound = false}) {
    email = email.trim();

    if (email.isEmpty) return 'Email cannot be empty';

    // Improved email regex (supports subdomains and multiple TLDs)
    final emailPattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";

    if (!RegExp(emailPattern).hasMatch(email)) {
      return 'Enter a valid email address';
    }

    if (userNotFound) return 'No account found with this email';

    return null;
  }

  /// =====================
  /// PASSWORD VALIDATION
  /// =====================
  String? _validatePassword(String password, {bool wrongPassword = false}) {
    password = password.trim();

    if (password.isEmpty) return 'Password cannot be empty';

    if (password.length < 8) return 'Password must be at least 8 characters';

    // Strong password check: uppercase, lowercase, number, special char
    final strongPasswordPattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    if (!RegExp(strongPasswordPattern).hasMatch(password))
      return 'Include uppercase, lowercase, number & special character';

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
