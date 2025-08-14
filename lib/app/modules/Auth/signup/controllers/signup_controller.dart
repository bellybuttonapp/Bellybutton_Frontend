import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../forgot_password/views/forgot_password_view.dart';
import '../../login/views/login_view.dart';

class SignupController extends GetxController {
  var isGoogleLoading = false.obs;
  //Loader
  var isLoading = false.obs; // add this in your controller

  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Reactive error messages
  var nameError = RxnString();
  var emailError = RxnString();
  var passwordError = RxnString();

  // Toggle for password visibility
  var isPasswordHidden = true.obs;

  // Remember me
  var rememberMe = false.obs;

  // --- Name validation ---
  void validatename(String value) {
    if (value.isEmpty) {
      nameError.value = 'Name cannot be empty';
    } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      nameError.value = 'Name must contain only letters';
    } else if (value.length < 3) {
      nameError.value = 'Name must be at least 3 characters';
    } else {
      nameError.value = null;
    }
  }

  // --- Email validation ---
  void validateEmail(String value) {
    if (value.isEmpty) {
      emailError.value = 'Email cannot be empty';
    } else if (!GetUtils.isEmail(value)) {
      emailError.value = 'Enter a valid email';
    } else {
      emailError.value = null;
    }
  }

  // --- Password validation ---
  void validatePassword(String value) {
    if (value.isEmpty) {
      passwordError.value = 'Password cannot be empty';
    } else if (value.length < 8) {
      passwordError.value = 'Minimum 8 characters required';
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      passwordError.value = 'Include uppercase, lowercase, and a number';
    } else {
      passwordError.value = null;
    }
  }

  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    validatename(name);
    validateEmail(email);
    validatePassword(password);

    if (nameError.value == null &&
        emailError.value == null &&
        passwordError.value == null) {
      isLoading.value = true; // start loader

      try {
        // Simulate signup process (e.g., API call)
        await Future.delayed(const Duration(seconds: 2));

        Get.snackbar('Success', 'Signed up successfully');
      } catch (e) {
        Get.snackbar('Error', 'Signup failed');
      } finally {
        isLoading.value = false; // stop loader
      }
    } else {
      Get.snackbar('Error', 'Please fix the highlighted errors');
    }
  }

  // Dummy social signin
  void Signin_Button() {
    Get.snackbar('Info', 'Social Sign-in Clicked');
  }

  void navigateToLogin() {
    Get.toNamed(
      Routes.LOGIN,
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
