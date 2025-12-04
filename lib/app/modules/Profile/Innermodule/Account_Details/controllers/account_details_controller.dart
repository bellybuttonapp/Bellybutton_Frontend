// ignore_for_file: unused_import, deprecated_member_use, unused_field, curly_braces_in_flow_control_structures

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
import '../../../../../core/services/local_notification_service.dart';
import '../../../../../core/utils/helpers/validation_utils.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../core/utils/storage/preference.dart';
import '../../../controllers/profile_controller.dart';

class AccountDetailsController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  final isLoading = false.obs;
  final nameError = RxnString();

  final hasChanges = false.obs;

  final Rx<XFile?> pickedImage = Rx<XFile?>(null);
  final ImagePicker picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();

    final user = AuthService().currentUser;

    nameController.text =
        Preference.userName.isNotEmpty
            ? Preference.userName
            : (user?.displayName ?? "Example User");

    bioController.text = Preference.bio.isNotEmpty ? Preference.bio : "";

    emailController.text =
        Preference.email.isNotEmpty
            ? Preference.email
            : (user?.email ?? "example@email.com");

    nameController.addListener(checkForChanges);
    bioController.addListener(checkForChanges);
  }

  void checkForChanges() {
    final nameChanged = nameController.text.trim() != Preference.userName;
    final bioChanged = bioController.text.trim() != Preference.bio;
    final imageChanged = pickedImage.value != null;

    hasChanges.value = nameChanged || bioChanged || imageChanged;
  }

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
      showCustomSnackBar(
        AppTexts.FAILED_TO_UPDATE_PROFILE_PHOTO,
        SnackbarState.error,
      );
    }
  }

  Future<void> _handleCrop(XFile? image) async {
    if (image == null) {
      showCustomSnackBar(AppTexts.NO_IMAGE_SELECTED, SnackbarState.error);
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

    final cropped = XFile(crop.path);
    pickedImage.value = cropped;

    Preference.profileImage = cropped.path;

    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().updatePickedImage(File(cropped.path));
    }

    checkForChanges();

    showCustomSnackBar(
      AppTexts.PROFILE_PHOTO_UPDATED_SUCCESSFULLY,
      SnackbarState.success,
    );
  }

  void validateName(String v) {
    nameError.value = Validation.validateName(v.trim());
    checkForChanges();
  }

  Future<void> saveChanges() async {
    nameError.value = Validation.validateName(nameController.text.trim());
    final emailErr = Validation.validateEmail(emailController.text.trim());

    if (nameError.value != null) {
      showCustomSnackBar(nameError.value!, SnackbarState.error);
      return;
    }

    if (emailErr != null) {
      showCustomSnackBar(emailErr, SnackbarState.error);
      return;
    }

    isLoading.value = true;

    final name = nameController.text.trim();
    final bio = bioController.text.trim();
    final email = emailController.text.trim();

    File? imageFile;
    if (pickedImage.value != null) {
      imageFile = File(pickedImage.value!.path);
    }

    try {
      final resp = await PublicApiService().updateProfile(
        userId: Preference.userId,
        email: email,
        fullName: name,
        bio: bio,
        phone: Preference.phone,
        address: Preference.address,
        imageFile: imageFile,
      );

      final msg = (resp["message"] ?? "").toString().toLowerCase();

      if (msg.contains("profile updated successfully")) {
        Preference.userName = resp["data"]["fullName"];
        Preference.email = resp["data"]["email"];
        Preference.bio = resp["data"]["bio"];

        if (resp["data"]["profileImageUrl"] != null) {
          Preference.profileImage = resp["data"]["profileImageUrl"];
        }

        hasChanges.value = false;

        showCustomSnackBar(
          AppTexts.PROFILE_UPDATED_SUCCESSFULLY,
          SnackbarState.success,
        );

        LocalNotificationService.show(
          title: AppTexts.NOTIFY_PROFILE_UPDATED_TITLE,
          body: AppTexts.NOTIFY_PROFILE_UPDATED_BODY,
        );

        Future.delayed(const Duration(milliseconds: 600), () {
          Get.back();
        });
      } else {
        showCustomSnackBar(
          AppTexts.FAILED_TO_UPDATE_PROFILE,
          SnackbarState.error,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        AppTexts.FAILED_TO_UPDATE_PROFILE,
        SnackbarState.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
