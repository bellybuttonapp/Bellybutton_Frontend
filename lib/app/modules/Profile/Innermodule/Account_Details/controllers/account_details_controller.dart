// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:bellybutton/app/core/constants/app_colors.dart';
import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../Controllers/oauth.dart';
import '../../../../../global_widgets/CustomBottomSheet/CustomBottomsheet.dart';

class AccountDetailsController extends GetxController {
  final nameController = TextEditingController();

  final isLoading = false.obs;
  final nameError = RxnString();

  /// Holds the picked image file
  final Rx<XFile?> pickedImage = Rx<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

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
      pickedImage.value = image; // update observable
      await AuthService().updatePhoto(image.path); // save / upload
    }
  }

  /// Validate name field
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

  /// Save changes (simulate async API call)
  Future<void> saveChanges() async {
    if (nameError.value != null) return;

    try {
      isLoading.value = true;
      final newName = nameController.text.trim();

      if (newName.isNotEmpty) {
        await AuthService().updateDisplayName(newName);
      }

      Get.snackbar(
        "Success",
        "Changes saved successfully!",
        snackPosition: SnackPosition.BOTTOM,
        // ignore: deprecated_member_use
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to save changes: $e",
        snackPosition: SnackPosition.BOTTOM,
        // ignore: deprecated_member_use
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
