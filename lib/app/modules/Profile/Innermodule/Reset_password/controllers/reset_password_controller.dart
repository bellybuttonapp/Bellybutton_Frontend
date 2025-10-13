import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Controllers/oauth.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';

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

  /// ---------------- RESET PASSWORD - SEND RESET LINK ---------------- ///
  Future<void> sendResetLink() async {
    final email = emailController.text.trim();

    // 1️⃣ Validate email before sending
    validateEmail(email);
    if (emailError.value.isNotEmpty) return;

    isLoading.value = true;

    try {
      // 2️⃣ Check if email exists in backend
      final emailCheck = await _authService.checkEmailAvailability(email);
      if (emailCheck['available'] == true) {
        // Email not registered → show error
        showCustomSnackBar(AppTexts.Email_not_found, SnackbarState.error);
        return;
      }

      // 3️⃣ Email exists → send reset link via API
      final result = await _authService.sendResetPasswordEmail(email: email);

      if (result['success'] == true) {
        // ✅ Reset link sent successfully
        showCustomSnackBar(
          result['message'] ?? AppTexts.passwordResetSuccess,
          SnackbarState.success,
        );
      } else {
        // ❌ Failed to send reset link
        showCustomSnackBar(
          result['message'] ?? AppTexts.passwordResetFailed,
          SnackbarState.error,
        );
      }
    } catch (e) {
      // Handle unexpected errors
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
