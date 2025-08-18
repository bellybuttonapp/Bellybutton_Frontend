import 'dart:async';
import 'package:bellybutton/app/modules/Auth/forgot_password/views/otp_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ---------------- CONTROLLER ---------------- ///
class ForgotPasswordController extends GetxController {
  /// Email input controller
  final emailController = TextEditingController();

  /// OTP input controller
  final otpController = TextEditingController();

  /// Focus for OTP
  final otpFocusNode = FocusNode();

  /// Observables
  final emailError = ''.obs;
  final otpError = ''.obs;
  final otp = ''.obs;
  final isLoading = false.obs;

  /// Resend OTP timer
  var resendSeconds = 30.obs;
  var isResendEnabled = false.obs;
  Timer? _timer;

  /// ---------------- SEND RESET LINK ---------------- ///
  void sendCode() async {
    validateEmail(emailController.text);

    if (emailError.value.isNotEmpty) return;

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    // Start countdown for resend
    startResendTimer();

    Get.snackbar("Success", "Reset link has been sent to your email!");
  }

  /// ---------------- VERIFY OTP ---------------- ///
  void verifyOtp() async {
    if (otp.value.length != 6) {
      otpError.value = "Please enter a valid 6-digit OTP";
      return;
    }

    isLoading.value = true;

    // Simulate API verification
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    if (otp.value == "123456") {
      Get.snackbar("Success", "OTP Verified! You can reset your password.");
      // Navigate to reset password screen
    } else {
      otpError.value = "Invalid OTP. Please try again.";
    }
  }

  /// ---------------- TIMER HANDLER ---------------- ///
  void startResendTimer() {
    isResendEnabled.value = false;
    resendSeconds.value = 30;

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

  void Navigate_to_otp() {
    // Navigate to OTP view
    Get.to(OtpView());
  }

  /// ---------------- VALIDATION ---------------- ///
  void validateEmail(String value) {
    emailError.value = _validateEmail(value) ?? '';
  }

  String? _validateEmail(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return "Please enter a valid email address";
    }

    if (trimmedValue.contains("..")) {
      return "Email cannot contain consecutive dots";
    }
    if (trimmedValue.endsWith(".")) {
      return "Email cannot end with a dot";
    }

    return null; // ✅ valid email
  }

  /// ---------------- CLEANUP ---------------- ///
  @override
  void onInit() {
    super.onInit();
    startResendTimer(); // start countdown immediately

    // Automatically focus OTP field when page opens
    Future.delayed(Duration(milliseconds: 300), () {
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
