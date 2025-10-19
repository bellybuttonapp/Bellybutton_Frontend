import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Controllers/oauth.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../Auth/forgot_password/views/otp_view.dart';

class ResetPasswordController extends GetxController {
  final AuthService _authService = AuthService();

  // Controller
  final emailController = TextEditingController();

  // Reactive states
  var emailError = ''.obs;
  var isLoading = false.obs;

  /// ---------------- VALIDATION ---------------- ///
  void validateEmail(String? value) {
    final error = validateEmailProduction(
      value,
    ); // Use production-ready validator
    emailError.value = error ?? ''; // Empty string if valid
  }

  /// ---------------- PRODUCTION-READY EMAIL VALIDATOR ---------------- ///
  String? validateEmailProduction(String? value) {
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

    if (local.isEmpty) return AppTexts.emailInvalid;
    if (domain.isEmpty) return AppTexts.emailInvalid;

    final domainParts = domain.split('.');
    if (domainParts.length < 2 || domainParts.any((part) => part.isEmpty)) {
      return AppTexts.emailDomainInvalid;
    }

    if (local.length > 64) return AppTexts.emailLocalTooLong;
    if (email.length > 254) return AppTexts.emailTooLong;

    return null; // ✅ Valid email
  }

  // /// ---------------- TIMER HANDLER ---------------- ///
  // void startResendTimer() {
  //   resendSeconds.value = 30;
  //   isResendEnabled.value = false;

  //   _timer?.cancel();
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (resendSeconds.value == 0) {
  //       isResendEnabled.value = true;
  //       _timer?.cancel();
  //     } else {
  //       resendSeconds.value--;
  //     }
  //   });
  // }

  // ==========================
  // AUTH - SEND RESET OTP
  // ==========================
  Future<void> sendResetLink() async {
    final email = emailController.text.trim();

    // 1️⃣ Validate email
    validateEmail(email);
    if (emailError.value.isNotEmpty) return;

    isLoading.value = true;

    try {
      // 2️⃣ Check if email exists
      final emailCheck = await _authService.checkEmailAvailability(email);
      if (emailCheck['available'] == true) {
        showCustomSnackBar(AppTexts.Email_not_found, SnackbarState.error);
        return;
      }

      // 3️⃣ Send OTP to the available email
      final result = await _authService.forgotPassword(email: email);

      if (result['result'] == true) {
        showCustomSnackBar(
          result['message']?.toString() ?? AppTexts.otpSent,
          SnackbarState.success,
        );
        // 4️⃣ Navigate to OTP Verification Screen
        if (Get.currentRoute != '/otp') {
          Get.to(
            () => OtpView(),
            transition: Transition.fade,
            duration: const Duration(milliseconds: 300),
            arguments: {"email": email, "otp": result['otp']?.toString() ?? ""},
          );
        }

        // // 5️⃣ Start resend timer
        // startResendTimer();
      } else {
        showCustomSnackBar(
          result['message']?.toString() ?? AppTexts.otpFailed,
          SnackbarState.error,
        );
      }
    } catch (e) {
      showCustomSnackBar("Error: ${e.toString()}", SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
