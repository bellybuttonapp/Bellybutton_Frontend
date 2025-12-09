// ignore_for_file: deprecated_member_use, unused_field, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Controllers/oauth.dart';
import '../../../../core/utils/helpers/validation_utils.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../login/views/login_view.dart';

class SignupOtpController extends GetxController {
  // Controllers & State
  final otpController = TextEditingController();
  var otpError = ''.obs;
  var isLoading = false.obs;
  var resendLoading = false.obs;

  // Timer for resend
  var canResend = true.obs;
  var resendSeconds = 30.obs;
  Timer? _timer;

  // Email from Signup screen
  String email = "";

  @override
  void onInit() {
    super.onInit();

    /// 🔥 Receive Email from Signup Navigation
    email = Get.arguments ?? "";
    print("📩 OTP Screen Email → $email");
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    final error = Validation.validateOtp(otp);
    if (error != null) {
      otpError.value = error;
      return;
    }

    otpError.value = "";
    isLoading.value = true;

    try {
      final response = await AuthService().verifySignupOtp(
        email: email,
        otp: otp,
      );

      final status = response['status'] ?? false;
      final message = response['message'] ?? "Something went wrong";

      if (status) {
        showCustomSnackBar(message, SnackbarState.success);
        FocusManager.instance.primaryFocus?.unfocus();

        // Delay a little to let SnackBar appear, then navigate
        await Future.delayed(const Duration(milliseconds: 300));

        // ✅ Use Get.offAll to go to Login and remove OTP screen from stack
        Get.offAll(
          () => LoginView(),
          transition: Transition.leftToRight,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        otpError.value = message;
        showCustomSnackBar(message, SnackbarState.error);
      }
    } catch (e, st) {
      otpError.value = "Unexpected error occurred.";
      showCustomSnackBar(otpError.value, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================
  // Resend OTP with timer
  // ==========================
  Future<void> resendOtp() async {
    if (!canResend.value) return;

    /// Clear Pinput fields
    otpController.clear();

    resendLoading.value = true;
    canResend.value = false;
    startResendTimer();

    try {
      final response = await AuthService().resendOtp(email: email);

      final headers = response['headers'];
      final message = headers['message'] ?? "Something went wrong";
      final status = headers['status'] ?? "failed";
      final code = headers['statusCode'] ?? 500;

      if (code == 200 && status == "success") {
        showCustomSnackBar(message, SnackbarState.success);
        // Close keyboard safely and navigate directly
        FocusManager.instance.primaryFocus?.unfocus();
        Get.to(
          () => LoginView(),
          transition: Transition.leftToRight,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        otpError.value = message;
        showCustomSnackBar(message, SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar("Failed to resend OTP.", SnackbarState.error);
    } finally {
      resendLoading.value = false;
    }
    update();
  }

  void startResendTimer() {
    resendSeconds.value = 30;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  // ==========================
  // Dispose
  // ==========================
  @override
  void onClose() {
    otpController.dispose();
    _timer?.cancel();
    super.onClose();
  }
}
