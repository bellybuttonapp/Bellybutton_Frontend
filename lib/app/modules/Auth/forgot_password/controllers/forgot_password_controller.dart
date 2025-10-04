// ignore_for_file: unused_field

import 'dart:async';
import 'package:bellybutton/app/modules/Auth/forgot_password/views/otp_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Controllers/oauth.dart';
import '../../../../api/DioClient.dart';
import '../../../../api/end_points.dart';
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
      // Call API to send password reset email
      final response = await DioClient().postRequest(
        Endpoints.forgetPassword,
        data: {"email": emailController.text.trim()},
      );

      if (response.data['result'] == true) {
        showCustomSnackBar(
          response.data['message'] ??
              "Reset link has been sent to your email! Please check your inbox.",
          SnackbarState.success,
        );

        // 👉 Navigate to OtpView
        navigateToOtp();

        // Optional: start resend countdown
        startResendTimer();
      } else {
        showCustomSnackBar(
          response.data['message'] ?? "Failed to send reset link",
          SnackbarState.error,
        );
      }
    } on DioException catch (e) {
      showCustomSnackBar(
        e.response?.data['message'] ?? e.message,
        SnackbarState.error,
      );
    } catch (e) {
      showCustomSnackBar(
        "Failed to send reset link: ${e.toString()}",
        SnackbarState.error,
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
      showCustomSnackBar(
        "OTP Verified! You can reset your password.",
        SnackbarState.success,
      );
      // 👉 Navigate to reset password screen
    } else {
      otpError.value = "Invalid OTP. Please try again.";
      showCustomSnackBar("Invalid OTP. Please try again.", SnackbarState.error);
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
