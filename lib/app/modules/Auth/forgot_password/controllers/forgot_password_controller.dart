// ignore_for_file: unused_field, curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:bellybutton/app/modules/Auth/forgot_password/views/otp_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Controllers/oauth.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = AuthService();

  // Controllers
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final otpFocusNode = FocusNode();

  // Reactive state
  var emailError = ''.obs;
  var otpError = ''.obs;
  var otp = ''.obs;
  var isLoading = false.obs;
  var isResendLoading = false.obs; // New loader for Resend

  // Resend OTP timer
  var resendSeconds = 30.obs;
  var isResendEnabled = false.obs;
  Timer? _timer;

  /// ---------------- Forget Password - SEND OTP ---------------- ///
  Future<void> sendOtp(String email) async {
    // Validate email before sending
    validateEmail(email);
    if (emailError.value.isNotEmpty) return;

    isLoading.value = true; // Only for first-time send

    try {
      // Check email existence before sending OTP
      final emailCheck = await _authService.checkEmailAvailability(email);
      if (emailCheck['available'] == true) {
        // Email not found → cannot send OTP
        showCustomSnackBar(
          'Email not found. Please enter a registered email.',
          SnackbarState.error,
        );
        return;
      }

      // Email exists → send OTP
      final result = await _authService.forgotPassword(email: email);

      if (result['result'] == true) {
        showCustomSnackBar(
          result['message']?.toString() ?? AppTexts.otpSent,
          SnackbarState.success,
        );

        // Navigate only if first time OTP sent
        if (Get.currentRoute != '/otp') {
          Get.to(
            () => OtpView(),
            transition: Transition.fade,
            duration: const Duration(milliseconds: 300),
            arguments: {"email": email, "otp": result['otp']?.toString() ?? ""},
          );
        }

        // Start countdown automatically after OTP sent
        startResendTimer();
      } else {
        showCustomSnackBar(
          result['message']?.toString() ?? AppTexts.otpFailed,
          SnackbarState.error,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        "${AppTexts.otpFailed}: ${e.toString()}",
        SnackbarState.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- Forget Password - RESEND OTP ---------------- ///

  Future<void> resendOtp() async {
    final email =
        Get.arguments?['email']?.toString() ?? emailController.text.trim();

    startResendTimer(); // Start countdown immediately

    isResendLoading.value = true; // Optional loader for Resend button

    try {
      final result = await _authService.forgotPassword(email: email);

      if (result['result'] == true) {
        showCustomSnackBar(
          result['message']?.toString() ?? AppTexts.otpSent,
          SnackbarState.success,
        );
      } else {
        showCustomSnackBar(
          result['message']?.toString() ?? AppTexts.otpFailed,
          SnackbarState.error,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        "${AppTexts.otpFailed}: ${e.toString()}",
        SnackbarState.error,
      );
    } finally {
      isResendLoading.value = false;
    }
  }

  /// ---------------- VERIFY OTP ---------------- ///
  void verifyOtp() async {
    final enteredOtp = otpController.text.trim();
    final email =
        Get.arguments?['email']?.toString() ?? emailController.text.trim();

    if (enteredOtp.length != 4) {
      otpError.value = "Please enter a valid 4-digit OTP";
      return;
    }

    isLoading.value = true;

    try {
      final response = await _authService.verifyOtpApi(
        email: email,
        otp: enteredOtp,
      );

      if (response['success'] == true) {
        showCustomSnackBar(AppTexts.otpVerified, SnackbarState.success);
        // Navigate to Reset Password screen
      } else {
        otpError.value =
            response['message'] ?? "Invalid OTP. Please try again.";
        showCustomSnackBar(
          response['message'] ?? AppTexts.otpInvalid,
          SnackbarState.error,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        "Something went wrong. Please retry.",
        SnackbarState.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- TIMER HANDLER ---------------- ///
  void startResendTimer() {
    resendSeconds.value = 30;
    isResendEnabled.value = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value == 0) {
        isResendEnabled.value = true;
        _timer?.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  /// ---------------- VALIDATION ---------------- ///
  void validateEmail(String value) {
    emailError.value = _validateEmail(value) ?? '';
  }

  /// ------------------------
  /// Production-ready Email Validator
  /// ------------------------
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return AppTexts.emailRequired;

    final email = value.trim();

    // ✅ Regex: Covers most valid email patterns
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+"
      r"@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
      r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );

    if (!emailRegex.hasMatch(email)) return AppTexts.emailInvalid;

    if (email.contains("..")) return AppTexts.emailConsecutiveDots;

    if (email.endsWith(".")) return AppTexts.emailEndsWithDot;

    final parts = email.split('@');
    if (parts.length != 2) return AppTexts.emailInvalid;

    final local = parts[0];
    final domain = parts[1];

    if (local.isEmpty) return AppTexts.emailInvalid;
    if (domain.isEmpty) return AppTexts.emailInvalid;

    // Domain must have at least one dot and valid labels
    final domainParts = domain.split('.');
    if (domainParts.length < 2 || domainParts.any((part) => part.isEmpty)) {
      return AppTexts.emailDomainInvalid;
    }

    // Optional: limit length (local + domain <= 254, local <= 64)
    if (local.length > 64) return AppTexts.emailLocalTooLong;
    if (email.length > 254) return AppTexts.emailTooLong;

    return null; // ✅ Valid email
  }

  @override
  void onInit() {
    super.onInit();
    // Autofocus OTP field after navigation
    Future.delayed(const Duration(milliseconds: 300), () {
      otpFocusNode.requestFocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        otpFocusNode.requestFocus();
      });
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    otpFocusNode.dispose();
    _timer?.cancel();
    super.onClose();
  }
}
