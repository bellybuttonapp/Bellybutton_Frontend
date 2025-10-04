// ignore_for_file: curly_braces_in_flow_control_structures, unrelated_type_equality_checks, avoid_print

import 'package:bellybutton/app/Controllers/oauth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_texts.dart';
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

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      showCustomSnackBar(AppTexts.noInternet, SnackbarState.error);
      return;
    }

    isLoading.value = true;

    try {
      final result = await _authService.registerWithAPI(
        name: name,
        email: email,
        password: password,
      );

      if (result['status'] == 'success' || result['id'] != null) {
        if (rememberMe) await saveUserData(name: name, email: email);

        final message = result['message'] ?? '';
        final userName =
            (result['name'] as String?)?.trim() ??
            (message.contains('user:')
                ? message.split('user:').last.trim()
                : name);

        _saveUserPreferences(name: userName, email: email);

        showCustomSnackBar(
          'Signed up successfully as $userName',
          SnackbarState.success,
        );

        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        showCustomSnackBar(
          result['message'] ?? 'Signup failed',
          SnackbarState.error,
        );
      }
    } catch (e) {
      showCustomSnackBar('Signup failed', SnackbarState.error);
      print("Signup error: $e");
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
      if (userCredential != null) {
        final email = userCredential.user?.email ?? "";
        final name = userCredential.user?.displayName ?? "";

        await saveUserData(name: name, email: email);
        _saveUserPreferences(name: name, email: email);

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
