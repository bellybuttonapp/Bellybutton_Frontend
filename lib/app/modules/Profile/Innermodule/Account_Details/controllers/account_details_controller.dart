// ignore_for_file: unused_import, deprecated_member_use, unused_field

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
import 'package:image_cropper/image_cropper.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../utils/preference.dart';
import '../../../controllers/profile_controller.dart';

class AccountDetailsController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  final isLoading = false.obs;
  final nameError = RxnString();

  final Rx<XFile?> pickedImage = Rx<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final user = AuthService().currentUser;

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
    try {
      final ImagePicker picker = ImagePicker();
      XFile? selectedImage;

      await Get.bottomSheet<void>(
        CustomBottomSheet(
          title: AppTexts.SELECT_IMAGE,
          actions: [
            SheetAction(
              icon: SvgPicture.asset(
                AppImages.GALLERY,
                width: 20,
                height: 20,
                color: AppColors.primaryColor,
              ),
              label: AppTexts.CHOOSE_PHOTO_FROM_GALLERY,
              onTap: () async {
                await Future.delayed(const Duration(milliseconds: 200));
                selectedImage = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                await _handleCropAndUpload(selectedImage);
              },
            ),
            SheetAction(
              icon: SvgPicture.asset(
                AppImages.CAMERA,
                width: 20,
                height: 20,
                color: AppColors.success,
              ),
              label: AppTexts.TAKE_PHOTO,
              onTap: () async {
                await Future.delayed(const Duration(milliseconds: 200));
                selectedImage = await picker.pickImage(
                  source: ImageSource.camera,
                );
                await _handleCropAndUpload(selectedImage);
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
    } catch (e) {
      debugPrint("Image picker error: $e");
      showCustomSnackBar(
        AppTexts.FAILED_TO_UPDATE_PROFILE_PHOTO,
        SnackbarState.error,
      );
    }
  }

  /// Crop + Update local & remote
  Future<void> _handleCropAndUpload(XFile? selectedImage) async {
    if (selectedImage == null) {
      showCustomSnackBar(AppTexts.NO_IMAGE_SELECTED, SnackbarState.warning);
      return;
    }

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: selectedImage.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppTexts.EDIT_PROFILE_PHOTO,
          toolbarColor: AppColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: AppColors.primaryColor,
        ),
        IOSUiSettings(
          title: AppTexts.EDIT_PROFILE_PHOTO,
          aspectRatioLockEnabled: true,
          doneButtonTitle: AppTexts.DONE,
          cancelButtonTitle: AppTexts.CANCEL,
        ),
      ],
    );

    if (croppedFile == null) {
      showCustomSnackBar(
        AppTexts.IMAGE_CROPPING_CANCELLED,
        SnackbarState.warning,
      );
      return;
    }

    final croppedXFile = XFile(croppedFile.path);
    pickedImage.value = croppedXFile;

    // ✅ Update Firebase photo
    await AuthService().updatePhoto(croppedXFile.path);
    Preference.profileImage = croppedXFile.path;

    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().updatePickedImage(File(croppedXFile.path));
    }

    showCustomSnackBar(
      AppTexts.PROFILE_PHOTO_UPDATED_SUCCESSFULLY,
      SnackbarState.success,
    );
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

  /// Save changes with API integration
  Future<void> saveChanges() async {
    if (nameError.value != null) return;

    final newName = nameController.text.trim();
    final newBio = bioController.text.trim();
    final email = emailController.text.trim();
    final imagePath = Preference.profileImage ?? '';
    final phone = Preference.phone ?? "";
    final address = Preference.address ?? "";

    if (newName.isEmpty) {
      showCustomSnackBar("Name cannot be empty", SnackbarState.warning);
      return;
    }

    try {
      isLoading.value = true;

      // ✅ API call
      final apiResponse = await PublicApiService().updateProfile(
        email: email,
        fullName: newName,
        phone: phone,
        address: address,
        bio: newBio,
        profileImageUrl: imagePath,
      );

      if (apiResponse["status"] == true ||
          apiResponse["success"] == true ||
          apiResponse["message"] == "Profile updated successfully") {
        // ✅ Firebase
        await AuthService().updateDisplayName(newName);

        // ✅ Local update
        Preference.userName = newName;
        Preference.email = email;
        Preference.bio = newBio;

        showCustomSnackBar(
          AppTexts.PROFILE_UPDATED_SUCCESSFULLY,
          SnackbarState.success,
        );
      } else {
        showCustomSnackBar(
          apiResponse["message"] ?? "Failed to update profile",
          SnackbarState.error,
        );
      }
    } catch (e) {
      debugPrint("❌ Profile update failed: $e");
      showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
