import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountDetailsController extends GetxController {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var nameError = RxnString();
  var passwordError = RxnString();

  // Validate Name
  void validateName(String value) {
    if (value.trim().isEmpty) {
      nameError.value = 'Name cannot be empty';
    } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      nameError.value = 'Only letters allowed';
    } else if (value.trim().length < 3) {
      nameError.value = 'At least 3 characters required';
    } else {
      nameError.value = null;
    }
  }

  // Validate Password
  void validatePassword(String value) {
    if (value.isEmpty) {
      passwordError.value = 'Password cannot be empty';
    } else if (value.length < 8) {
      passwordError.value = 'Must be at least 8 characters';
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      passwordError.value = 'Must contain at least 1 uppercase letter';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      passwordError.value = 'Must contain at least 1 number';
    } else if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      passwordError.value = 'Must contain at least 1 special character';
    } else {
      passwordError.value = null;
    }
  }

  // Save changes simulation
  Future<void> saveChanges() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    Get.snackbar(
      "Success",
      "Changes saved successfully!",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
