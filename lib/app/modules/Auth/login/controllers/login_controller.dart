import 'package:bellybutton/app/modules/Auth/signup/views/signup_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../forgot_password/views/forgot_password_view.dart';

class LoginController extends GetxController {
  var isGoogleLoading = false.obs;
  // final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var isLoading = false.obs;

  final emailError = ''.obs;
  final passwordError = ''.obs;
  final rememberMe = false.obs;
  final isPasswordHidden = true.obs;

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Default credentials
    const defaultEmail = "admin@gmail.com";
    const defaultPassword = "123456";

    // Reset errors
    emailError.value = '';
    passwordError.value = '';

    // Validate inputs
    final emailValidation = _validateEmail(email);
    final passwordValidation = _validatePassword(password);

    if (emailValidation != null) emailError.value = emailValidation;
    if (passwordValidation != null) passwordError.value = passwordValidation;

    if (emailError.isNotEmpty || passwordError.isNotEmpty) return;

    // ✅ Start Loader
    isLoading.value = true;

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (email == defaultEmail && password == defaultPassword) {
        Get.snackbar(
          'Success',
          'Logged in with default credentials',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offNamed('/dashboard'); // Navigate to dashboard
        return;
      }

      if (email == 'already@registered.com') {
        emailError.value = 'This email is already registered';
        return;
      }

      if (password != 'correctPassword') {
        passwordError.value = 'Incorrect password';
        return;
      }

      Get.snackbar(
        'Success',
        'Logged in as $email',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offNamed('/dashboard');
    } finally {
      isLoading.value = false;
    }
  }

  void validateEmail(String value) {
    emailError.value = _validateEmail(value) ?? '';
  }

  void validatePassword(String value) {
    passwordError.value = _validatePassword(value) ?? '';
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Please enter your email';
    if (!GetUtils.isEmail(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> onSigninWithGoogle() async {
    if (isGoogleLoading.value) return; // prevent double tap
    isGoogleLoading.value = true;

    try {
      // Your Google Sign-in logic here
      await Future.delayed(Duration(seconds: 2)); // simulate async task
      // Get.snackbar('Success', 'Google Sign-in successful');
    } catch (e) {
      Get.snackbar('Error', 'Google Sign-in failed');
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void navigateToSignup() {
    Get.toNamed(
      Routes.SIGNUP,
    ); // ✅ triggers proper binding disposal and recreation
  }

  void forget_Paswd() {
    Get.to(
      () => ForgotPasswordView(),
      transition: Transition.rightToLeft, // Slide from right to left
      duration: const Duration(milliseconds: 300), // Optional speed control
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    // _formKey.currentState?.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
