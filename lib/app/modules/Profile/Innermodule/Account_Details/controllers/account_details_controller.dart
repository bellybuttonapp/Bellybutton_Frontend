import 'dart:io';
import 'package:bellybutton/app/Controllers/oauth.dart';
import 'package:bellybutton/app/core/constants/app_colors.dart';
import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:bellybutton/app/global_widgets/CustomBottomSheet/CustomBottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../utils/preference.dart';

class AccountDetailsController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final nameError = RxnString();

  final Rx<XFile?> pickedImage = Rx<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final user = AuthService().currentUser;

    // Initialize name & email from Preference or Firebase
    nameController.text =
        Preference.userName.isNotEmpty
            ? Preference.userName
            : (user?.displayName ?? "Example Name");

    emailController.text =
        Preference.email.isNotEmpty
            ? Preference.email
            : (user?.email ?? "example@email.com");
  }

  /// Pick image from gallery or camera
  Future<void> pickImage() async {
    final XFile? image = await Get.bottomSheet<XFile?>(
      CustomBottomSheet(
        title: AppTexts.Selectimage,
        actions: [
          SheetAction(
            icon: SvgPicture.asset(
              app_images.Gallery,
              width: 20,
              height: 20,
              color: AppColors.primaryColor,
            ),
            label: AppTexts.Choosephotofromgallery,
            onTap: () async {
              final picked = await _picker.pickImage(
                source: ImageSource.gallery,
              );
              Get.back(result: picked);
            },
          ),
          SheetAction(
            icon: SvgPicture.asset(
              app_images.Camera,
              width: 20,
              height: 20,
              color: AppColors.success,
            ),
            label: AppTexts.Takeaphoto,
            onTap: () async {
              final picked = await _picker.pickImage(
                source: ImageSource.camera,
              );
              Get.back(result: picked);
            },
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );

    if (image != null) {
      pickedImage.value = image;
      await AuthService().updatePhoto(image.path);
      Preference.profileImage = image.path;
    }
  }

  /// Validate name
  void validateName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      nameError.value = 'Name cannot be empty';
    } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(trimmed)) {
      nameError.value = 'Only letters allowed';
    } else if (trimmed.length < 3) {
      nameError.value = 'At least 3 characters required';
    } else {
      nameError.value = null;
    }
  }

  /// Save changes to Firebase & Preference
  /// Save changes to Firebase & Preference
  Future<void> saveChanges() async {
    if (nameError.value != null) return;

    final newName = nameController.text.trim();
    if (newName.isEmpty) return;

    try {
      isLoading.value = true;

      // Update Firebase
      await AuthService().updateDisplayName(newName);

      // Update Preference
      Preference.userName = newName;
      Preference.email = emailController.text.trim();

      // Show success snackbar
      showCustomSnackBar(AppTexts.loginSuccess, SnackbarState.success);
    } catch (e) {
      // Show error snackbar
      showCustomSnackBar(AppTexts.noInternet, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
