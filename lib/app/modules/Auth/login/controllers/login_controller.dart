import 'package:bellybutton/app/modules/Auth/signup/views/signup_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';

class LoginController extends GetxController {
  // final formKey = GlobalKey<FormState>();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final emailError = ''.obs;
  final passwordError = ''.obs;
  final rememberMe = false.obs;
  final isPasswordHidden = true.obs;

  void login() {
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

    if (emailError.isNotEmpty || passwordError.isNotEmpty) return;

    // Simulated auth logic
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

  void onSigninWithGoogle() {
    Get.snackbar(
      'Info',
      'Google Sign-In clicked',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToSignup() {
    Get.toNamed(
      Routes.SIGNUP,
    ); // ✅ triggers proper binding disposal and recreation
  }

  @override
  void onClose() {
    emailController.dispose();
    // _formKey.currentState?.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
