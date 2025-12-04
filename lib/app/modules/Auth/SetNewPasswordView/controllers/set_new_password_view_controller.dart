// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Controllers/oauth.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../routes/app_pages.dart';
import '../../../../core/utils/storage/preference.dart';

class SetNewPasswordViewController extends GetxController {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final newPasswordError = ''.obs;
  final confirmPasswordError = ''.obs;
  final isLoading = false.obs;

  // final isNewPasswordHidden = true.obs;
  // final isConfirmPasswordHidden = true.obs;
  // ✅ Single variable to control both fields
  final isPasswordHidden = true.obs;

  final AuthService _authService = AuthService();

  /// =====================
  /// CONFIRM NEW PASSWORD FUNCTION
  /// =====================
  Future<void> confirmNewPassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Reset errors
    newPasswordError.value = '';
    confirmPasswordError.value = '';

    // Validate inputs
    final newPasswordValidation = _validatePassword(newPassword);
    final confirmPasswordValidation = _validateConfirmPassword(
      newPassword,
      confirmPassword,
    );

    if (newPasswordValidation != null)
      newPasswordError.value = newPasswordValidation;
    if (confirmPasswordValidation != null)
      confirmPasswordError.value = confirmPasswordValidation;

    if (newPasswordError.value.isNotEmpty ||
        confirmPasswordError.value.isNotEmpty)
      return;

    isLoading.value = true;
    final email = Get.arguments?['email']?.toString() ?? '';

    try {
      final response = await _authService.resetPassword(
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final message = response['message'] ?? AppTexts.SET_NEW_PASSWORD;
      final success =
          response['success'] == true ||
          message.toLowerCase().contains('success');

      if (success) {
        newPasswordController.clear();
        confirmPasswordController.clear();

        Preference.isLoggedIn = false;
        Preference.email = '';

        // 🔥 Local Notification Trigger
        LocalNotificationService.show(
          title: AppTexts.NOTIFY_PASSWORD_RESET_TITLE,
          body: AppTexts.NOTIFY_PASSWORD_RESET_BODY,
        );

        showCustomSnackBar(message, SnackbarState.success);
        await Future.delayed(const Duration(milliseconds: 500));
        FocusScope.of(Get.context!).unfocus();
        Get.offAllNamed(Routes.LOGIN);
      } else {
        showCustomSnackBar(message, SnackbarState.error);
      }
    } catch (e, stack) {
      print("SetNewPassword Error: $e\n$stack");
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// =====================
  /// PASSWORD VALIDATION
  /// =====================
  String? _validatePassword(String password) {
    password = password.trim();

    if (password.isEmpty) return 'New password cannot be empty';
    if (password.length < 8)
      return 'Password must be at least 8 characters long';

    // Strong password rule
    final strongPasswordPattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    if (!RegExp(strongPasswordPattern).hasMatch(password)) {
      return 'Include uppercase, lowercase, number & special character';
    }

    return null;
  }

  /// =====================
  /// CONFIRM PASSWORD VALIDATION
  /// =====================
  String? _validateConfirmPassword(String password, String confirmPassword) {
    confirmPassword = confirmPassword.trim();

    if (confirmPassword.isEmpty) return 'Confirm password cannot be empty';
    if (confirmPassword != password) return 'Passwords do not match';

    return null;
  }

  /// =====================
  /// REAL-TIME VALIDATION
  /// =====================
  void validateNewPassword(String value) =>
      newPasswordError.value = _validatePassword(value) ?? '';

  void validateConfirmPassword(String value) =>
      confirmPasswordError.value =
          _validateConfirmPassword(newPasswordController.text, value) ?? '';

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
