// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:bellybutton/app/Controllers/oauth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../routes/app_pages.dart';
import '../../forgot_password/views/forgot_password_view.dart';

class SignupController extends GetxController {
  final AuthService _authService = AuthService();

  // Loader
  var isLoading = false.obs;

  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Reactive error messages
  var nameError = RxnString();
  var emailError = RxnString();
  var passwordError = RxnString();

  // Password visibility toggle
  var isPasswordHidden = true.obs;

  // Remember me
  var rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// =====================
  /// VALIDATIONS
  /// =====================
  void validateName(String value) {
    if (value.isEmpty)
      nameError.value = 'Name cannot be empty';
    else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value))
      nameError.value = 'Name must contain only letters';
    else if (value.length < 3)
      nameError.value = 'Name must be at least 3 characters';
    else
      nameError.value = null;
  }

  void validateEmail(String value) {
    if (value.isEmpty)
      emailError.value = 'Email cannot be empty';
    else if (!GetUtils.isEmail(value))
      emailError.value = 'Enter a valid email';
    else
      emailError.value = null;
  }

  void validatePassword(String value) {
    if (value.isEmpty)
      passwordError.value = 'Password cannot be empty';
    else if (value.length < 8)
      passwordError.value = 'Minimum 8 characters required';
    else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value))
      passwordError.value = 'Include uppercase, lowercase, and a number';
    else
      passwordError.value = null;
  }

  /// =====================
  /// REMEMBER ME STORAGE
  /// =====================
  Future<void> saveUserData({String? name, String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe.value) {
      await prefs.setString("signup_name", name ?? nameController.text.trim());
      await prefs.setString(
        "signup_email",
        email ?? emailController.text.trim(),
      );
    } else {
      await prefs.remove("signup_name");
      await prefs.remove("signup_email");
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString("signup_name");
    final savedEmail = prefs.getString("signup_email");

    if (savedName != null && savedEmail != null) {
      nameController.text = savedName;
      emailController.text = savedEmail;
      rememberMe.value = true;
    }
  }

  /// =====================
  /// SIGNUP FUNCTION
  /// =====================
  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validate inputs
    validateName(name);
    validateEmail(email);
    validatePassword(password);

    if (nameError.value == null &&
        emailError.value == null &&
        passwordError.value == null) {
      isLoading.value = true;

      try {
        final userCredential = await _authService.registerWithEmail(
          name: name,
          email: email,
          password: password,
        );

        if (userCredential != null) {
          await saveUserData(); // ✅ Save only if rememberMe checked

          showCustomSnackBar(
            'Signed up successfully as ${userCredential.user!.displayName ?? name}',
            SnackbarState.success,
          );
          Get.offNamed(Routes.DASHBOARD);
        } else {
          showCustomSnackBar('Signup failed. Try again.', SnackbarState.error);
        }
      } catch (e) {
        showCustomSnackBar('Signup failed: $e', SnackbarState.error);
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// =====================
  /// GOOGLE SIGN-IN
  /// =====================
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        final email = userCredential.user?.email ?? "";
        final name = userCredential.user?.displayName ?? "";

        await saveUserData(name: name, email: email); // ✅ store from Google

        showCustomSnackBar(
          'Logged in as ${name.isNotEmpty ? name : email}',
          SnackbarState.success,
        );
        Get.offNamed(Routes.DASHBOARD);
      } else {
        showCustomSnackBar('Google sign-in canceled', SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar('Google sign-in failed: $e', SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// =====================
  /// NAVIGATION
  /// =====================
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
