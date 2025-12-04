import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Controllers/oauth.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/utils/helpers/validation_utils.dart';
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
    emailError.value = Validation.validateEmail(value) ?? ''; // ⭐ replaced here
  }

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
        showCustomSnackBar(AppTexts.EMAIL_NOT_FOUND, SnackbarState.error);
        return;
      }

      // 3️⃣ Send OTP to the available email
      final result = await _authService.forgotPassword(email: email);

      if (result['result'] == true) {
        showCustomSnackBar(
          result['message']?.toString() ?? AppTexts.OTP_SENT,
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
      } else {
        showCustomSnackBar(
          result['message']?.toString() ?? AppTexts.OTP_FAILED,
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
