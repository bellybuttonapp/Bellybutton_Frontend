import 'dart:async';
import 'package:bellybutton/app/modules/Auth/forgot_password/views/otp_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Controllers/oauth.dart';

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

  // Resend OTP timer
  var resendSeconds = 30.obs;
  var isResendEnabled = false.obs;
  Timer? _timer;

  /// ---------------- SEND RESET LINK ---------------- ///
  Future<void> sendCode() async {
    validateEmail(emailController.text);
    if (emailError.value.isNotEmpty) return;

    isLoading.value = true;
    try {
      // Send password reset email via Firebase
      await _authService.resetPassword(email: emailController.text.trim());

      // Show success message
      Get.snackbar(
        "Success",
        "Reset link has been sent to your email! Please check your inbox.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade200,
        colorText: Colors.black,
      );

      // Navigate back to login screen so user can log in after resetting
      Get.offAllNamed('/login');

      // Optional: start resend countdown for UX
      startResendTimer();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send reset link: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade200,
        colorText: Colors.black,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- VERIFY OTP ---------------- ///
  void verifyOtp() async {
    if (otp.value.length != 6) {
      otpError.value = "Please enter a valid 6-digit OTP";
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Simulate verification
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

  /// ---------------- NAVIGATION ---------------- ///
  void navigateToOtp() {
    Get.to(() => OtpView());
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

    // General RFC 5322 compliant regex for email validation
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+"
      r"@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
      r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return "Enter a valid email address";
    }

    // Additional rules
    if (trimmedValue.contains("..")) {
      return "Email cannot contain consecutive dots";
    }

    if (trimmedValue.endsWith(".")) {
      return "Email cannot end with a dot";
    }

    if (trimmedValue.split('@').length != 2) {
      return "Email must contain a single '@' symbol";
    }

    final parts = trimmedValue.split('@');
    if (parts[0].isEmpty) {
      return "Email must have characters before '@'";
    }
    if (parts[1].isEmpty) {
      return "Email must have a domain after '@'";
    }
    if (!parts[1].contains('.')) {
      return "Domain must contain at least one dot (e.g. gmail.com)";
    }

    return null; // ✅ Valid
  }

  /// ---------------- CLEANUP ---------------- ///
  @override
  void onInit() {
    super.onInit();
    // Automatically focus OTP field when page opens
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
