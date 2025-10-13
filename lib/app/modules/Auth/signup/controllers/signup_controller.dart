// ignore_for_file: curly_braces_in_flow_control_structures, unrelated_type_equality_checks, avoid_print

import 'dart:io';
import 'package:bellybutton/app/Controllers/oauth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/preference.dart';
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
  String? _validateName(String value) {
    if (value.isEmpty) return 'Name cannot be empty';
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value))
      return 'Name must contain only letters';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email cannot be empty';
    if (!GetUtils.isEmail(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password cannot be empty';
    if (value.length < 8) return 'Minimum 8 characters required';
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value))
      return 'Include uppercase, lowercase, and a number';
    return null;
  }

  void validateName(String value) => nameError.value = _validateName(value);
  void validateEmail(String value) => emailError.value = _validateEmail(value);
  void validatePassword(String value) =>
      passwordError.value = _validatePassword(value);

  /// =====================
  /// REMEMBER ME STORAGE
  /// =====================
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
    final savedName = Preference.userName;
    final savedEmail = Preference.email;

    if (savedName.isNotEmpty && savedEmail.isNotEmpty) {
      nameController.text = savedName;
      emailController.text = savedEmail;
      rememberMe.value = true;
    }
  }

  /// =====================
  /// UPDATE PREFERENCES
  /// =====================
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

  /// =====================
  /// SIGNUP FUNCTION
  /// =====================
  Future<void> signup({bool rememberMe = false}) async {
    this.rememberMe.value = rememberMe;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Reset errors
    nameError.value = null;
    emailError.value = null;
    passwordError.value = null;

    // Validate inputs
    final nameValidation = _validateName(name);
    final emailValidation = _validateEmail(email);
    final passwordValidation = _validatePassword(password);

    if (nameValidation != null) nameError.value = nameValidation;
    if (emailValidation != null) emailError.value = emailValidation;
    if (passwordValidation != null) passwordError.value = passwordValidation;

    if (nameError.value != null ||
        emailError.value != null ||
        passwordError.value != null)
      return;

    isLoading.value = true;

    try {
      // ✅ Step: Check email availability before signup
      final emailCheck = await _authService.checkEmailAvailability(email);
      if (emailCheck['available'] == false) {
        showCustomSnackBar(
          emailCheck['message'] ??
              'Email already exists. Please use another one.',
          SnackbarState.error,
        );
        isLoading.value = false;
        return;
      }

      // Continue with signup
      final result = await _authService.registerWithAPI(
        name: name.isNotEmpty ? name : "User",
        email: email,
        password: password,
        profilePhoto: null,
      );

      // Handle no internet explicitly
      if (result['message'] == "No internet connection.") {
        showCustomSnackBar(result['message'], SnackbarState.error);
        return;
      }

      // Successful signup
      if (result['status'] == 'success' || result['id'] != null) {
        if (rememberMe) await saveUserData(name: name, email: email);

        final userName = (result['name'] as String?)?.trim() ?? name;
        _saveUserPreferences(name: userName, email: email);

        showCustomSnackBar(
          'Signed up successfully as $userName',
          SnackbarState.success,
        );
        Get.offAllNamed(Routes.DASHBOARD);
      } else if (result['result'] == false && result['message'] != null) {
        showCustomSnackBar(result['message']!, SnackbarState.error);
      }
    } catch (e, stackTrace) {
      print('Signup error: $e\n$stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  /// =====================
  /// GOOGLE SIGN-IN
  /// =====================
  Future<void> signInWithGoogle() async {
    isLoading.value = true;

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential == null) {
        showCustomSnackBar('Google sign-in canceled', SnackbarState.error);
        return;
      }

      final email = userCredential.user?.email ?? "";
      final name = userCredential.user?.displayName ?? "";

      await saveUserData(name: name, email: email);
      _saveUserPreferences(name: name, email: email);

      showCustomSnackBar(
        'Logged in as ${name.isNotEmpty ? name : email}',
        SnackbarState.success,
      );

      Get.offAllNamed(Routes.DASHBOARD);
    } on SocketException {
      showCustomSnackBar('No internet connection.', SnackbarState.error);
    } catch (e, stackTrace) {
      print('Google sign-in error: $e\n$stackTrace');
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
