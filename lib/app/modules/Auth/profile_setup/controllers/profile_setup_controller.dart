// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../api/PublicApiService.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/utils/helpers/validation_utils.dart';
import '../../../../core/utils/storage/preference.dart';
import '../../../../global_widgets/CustomBottomSheet/CustomBottomsheet.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../routes/app_pages.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileSetupController extends GetxController {
  // Controllers
  final nameController = TextEditingController();
  final bioController = TextEditingController();

  // Focus nodes
  final nameFocusNode = FocusNode();
  final bioFocusNode = FocusNode();

  // State
  final isLoading = false.obs;
  final nameError = RxnString();
  final Rx<XFile?> pickedImage = Rx<XFile?>(null);
  final ImagePicker picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Pre-fill name if available from login
    if (Preference.userName.isNotEmpty) {
      nameController.text = Preference.userName;
    }
  }

  //----------------------------------------------------
  // VALIDATE NAME
  //----------------------------------------------------
  void validateName(String value) {
    nameError.value = Validation.validateName(value.trim());
  }

  //----------------------------------------------------
  // PICK IMAGE
  //----------------------------------------------------
  Future<void> pickImage() async {
    try {
      XFile? selected;

      await Get.bottomSheet(
        CustomBottomSheet(
          title: AppTexts.SELECT_IMAGE,
          actions: [
            SheetAction(
              icon: SvgPicture.asset(
                AppImages.GALLERY,
                width: 20,
                color: AppColors.primaryColor,
              ),
              label: AppTexts.CHOOSE_PHOTO_FROM_GALLERY,
              onTap: () async {
                selected = await picker.pickImage(source: ImageSource.gallery);
                await _handleCrop(selected);
              },
            ),
            SheetAction(
              icon: SvgPicture.asset(
                AppImages.CAMERA,
                width: 20,
                color: AppColors.success,
              ),
              label: AppTexts.TAKE_PHOTO,
              onTap: () async {
                selected = await picker.pickImage(source: ImageSource.camera);
                await _handleCrop(selected);
              },
            ),
          ],
        ),
      );
    } catch (e) {
      print("pickImage() error: $e");
      showCustomSnackBar(
        AppTexts.FAILED_TO_UPDATE_PROFILE_PHOTO,
        SnackbarState.error,
      );
    }
  }

  Future<void> _handleCrop(XFile? image) async {
    if (image == null) {
      return;
    }

    final crop = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
    );

    if (crop == null) {
      showCustomSnackBar(
        AppTexts.IMAGE_CROPPING_CANCELLED,
        SnackbarState.error,
      );
      return;
    }

    pickedImage.value = XFile(crop.path);
    Get.back(); // Close bottom sheet
  }

  //----------------------------------------------------
  // SAVE PROFILE
  //----------------------------------------------------
  Future<void> saveProfile() async {
    hideKeyboard();

    final name = nameController.text.trim();
    nameError.value = Validation.validateName(name);

    if (nameError.value != null) {
      return;
    }

    if (name.isEmpty) {
      nameError.value = "Name is required";
      return;
    }

    isLoading.value = true;

    try {
      final bio = bioController.text.trim();
      File? imageFile;
      if (pickedImage.value != null) {
        imageFile = File(pickedImage.value!.path);
      }

      // Update profile
      final resp = await PublicApiService().updateProfile(
        userId: Preference.userId,
        email: Preference.email,
        fullName: name,
        bio: bio,
        phone: Preference.phone,
        address: Preference.address,
        imageFile: imageFile,
      );

      final msg = (resp["message"] ?? "").toString().toLowerCase();
      final isSuccess = msg.contains("success") ||
                        msg.contains("updated") ||
                        resp["data"] != null ||
                        resp["success"] == true ||
                        resp["success"]?.toString().toLowerCase() == "true";

      if (isSuccess) {
        final data = resp["data"] ?? {};

        // Update local storage
        Preference.userName = data["fullName"] ?? name;
        Preference.bio = data["bio"] ?? bio;

        if (data["profileImageUrl"] != null) {
          Preference.profileImage = data["profileImageUrl"];
        } else if (imageFile != null) {
          Preference.profileImage = imageFile.path;
        }

        // Mark profile as complete
        Preference.isProfileComplete = true;

        showCustomSnackBar(
          AppTexts.PROFILE_SETUP_SUCCESS,
          SnackbarState.success,
        );

        // Navigate to dashboard immediately
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        showCustomSnackBar(
          resp["message"] ?? AppTexts.FAILED_TO_UPDATE_PROFILE,
          SnackbarState.error,
        );
      }
    } catch (e) {
      print("saveProfile() error: $e");
      showCustomSnackBar(
        AppTexts.SOMETHING_WENT_WRONG,
        SnackbarState.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //----------------------------------------------------
  // SKIP PROFILE SETUP
  //----------------------------------------------------
  void skipSetup() {
    // Mark as skipped but allow user to continue
    Preference.isProfileComplete = true;
    Get.offAllNamed(Routes.DASHBOARD);
  }

  //----------------------------------------------------
  // HIDE KEYBOARD
  //----------------------------------------------------
  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    nameFocusNode.dispose();
    bioFocusNode.dispose();
    super.onClose();
  }
}
