// ignore_for_file: unused_field, curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:bellybutton/app/modules/Auth/SetNewPasswordView/views/set_new_password_view_view.dart';
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
  var isResendLoading = false.obs;

  // Resend OTP timer
  var resendSeconds = 30.obs;
  var isResendEnabled = false.obs;
  Timer? _timer;

  bool _isDisposed = false; // Track disposal to prevent updates after close

  /// ---------------- SEND OTP ---------------- ///
  Future<void> sendOtp(String email) async {
    validateEmail(email);
    if (emailError.value.isNotEmpty) return;

    isLoading.value = true;

    try {
      final emailCheck = await _authService.checkEmailAvailability(email);
      if (emailCheck['available'] == true) {
        showCustomSnackBar(
          'Email not found. Please enter a registered email.',
          SnackbarState.error,
        );
        return;
      }

      final result = await _authService.forgotPassword(email: email);

      if (result['result'] == true) {
        if (!_isDisposed) {
          showCustomSnackBar(
            result['message']?.toString() ?? AppTexts.otpSent,
            SnackbarState.success,
          );

          if (Get.currentRoute != '/otp') {
            Get.to(
              () => OtpView(),
              transition: Transition.fade,
              duration: const Duration(milliseconds: 300),
              arguments: {
                "email": email,
                "otp": result['otp']?.toString() ?? "",
              },
            );
          }

          startResendTimer();
        }
      } else {
        if (!_isDisposed) {
          showCustomSnackBar(
            result['message']?.toString() ?? AppTexts.otpFailed,
            SnackbarState.error,
          );
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        showCustomSnackBar(
          "${AppTexts.otpFailed}: ${e.toString()}",
          SnackbarState.error,
        );
      }
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  /// ---------------- RESEND OTP ---------------- ///
  Future<void> resendOtp() async {
    final email =
        Get.arguments?['email']?.toString() ?? emailController.text.trim();

    startResendTimer();
    isResendLoading.value = true;

    try {
      final result = await _authService.forgotPassword(email: email);

      if (!_isDisposed) {
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
      }
    } catch (e) {
      if (!_isDisposed) {
        showCustomSnackBar(
          "${AppTexts.otpFailed}: ${e.toString()}",
          SnackbarState.error,
        );
      }
    } finally {
      if (!_isDisposed) isResendLoading.value = false;
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

      if (!_isDisposed) {
        if (response['success'] == true) {
          showCustomSnackBar(AppTexts.otpVerified, SnackbarState.success);
          Get.off(() => SetNewPasswordView(), arguments: {'email': email});
        } else {
          otpError.value = response['message'] ?? AppTexts.otpInvalid;
          showCustomSnackBar(
            response['message'] ?? AppTexts.otpInvalid,
            SnackbarState.error,
          );
        }
      }
    } catch (e) {
      if (!_isDisposed)
        showCustomSnackBar(AppTexts.Somethingwentwrong, SnackbarState.error);
    } finally {
      if (!_isDisposed) isLoading.value = false;
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

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return AppTexts.emailRequired;

    final email = value.trim();
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
    if (local.isEmpty || domain.isEmpty) return AppTexts.emailInvalid;

    final domainParts = domain.split('.');
    if (domainParts.length < 2 || domainParts.any((part) => part.isEmpty))
      return AppTexts.emailDomainInvalid;

    if (local.length > 64) return AppTexts.emailLocalTooLong;
    if (email.length > 254) return AppTexts.emailTooLong;

    return null;
  }

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 300), () {
      otpFocusNode.requestFocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        otpFocusNode.requestFocus();
      });
    });
  }

  @override
  void onClose() {
    _isDisposed = true;

    emailController.dispose();
    otpController.dispose();
    otpFocusNode.dispose();
    _timer?.cancel();

    emailError.value = '';
    otpError.value = '';
    isLoading.value = false;
    isResendLoading.value = false;
    resendSeconds.value = 30;
    isResendEnabled.value = false;

    super.onClose();
  }
}
