// ignore_for_file: unused_import, deprecated_member_use, unused_field, curly_braces_in_flow_control_structures, avoid_print

import 'dart:async';
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
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../core/utils/storage/preference.dart';
import '../../../controllers/profile_controller.dart';

class AccountDetailsController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  /// ---------------- FOCUS NODES ----------------
  final nameFocusNode = FocusNode();
  final bioFocusNode = FocusNode();

  final isLoading = false.obs;
  final nameError = RxnString();

  final hasChanges = false.obs;

  final Rx<XFile?> pickedImage = Rx<XFile?>(null);
  final ImagePicker picker = ImagePicker();

  /// ---------------- ROTATING BIO SUGGESTIONS ----------------
  var currentBioSuggestionIndex = 0.obs;
  var isBioEmpty = true.obs;
  Timer? _suggestionTimer;

  /// ---------------- EDIT MODE STATES ----------------
  var isNameEditing = false.obs;
  var isBioEditing = false.obs;

  void toggleNameEdit() {
    isNameEditing.value = !isNameEditing.value;
    if (isNameEditing.value) {
      isBioEditing.value = false;
      Future.delayed(const Duration(milliseconds: 100), () {
        nameFocusNode.requestFocus();
      });
    } else {
      nameFocusNode.unfocus();
    }
  }

  void toggleBioEdit() {
    isBioEditing.value = !isBioEditing.value;
    if (isBioEditing.value) {
      isNameEditing.value = false;
      Future.delayed(const Duration(milliseconds: 100), () {
        bioFocusNode.requestFocus();
      });
    } else {
      bioFocusNode.unfocus();
    }
  }

  String get currentBioSuggestion =>
      AppTexts.BIO_SUGGESTIONS[currentBioSuggestionIndex.value];

  @override
  void onInit() {
    super.onInit();

    final user = AuthService().currentUser;

    // Get data from ProfileController if available (most recent from API)
    Map<String, dynamic> profile = {};
    if (Get.isRegistered<ProfileController>()) {
      profile = Get.find<ProfileController>().userProfile;
    }

    // Debug: Print all data sources
    print("🔍 AccountDetails - Profile data: $profile");
    print("🔍 AccountDetails - Preference.userName: '${Preference.userName}'");
    print("🔍 AccountDetails - Preference.bio: '${Preference.bio}'");
    print("🔍 AccountDetails - Preference.profileImage: '${Preference.profileImage}'");
    print("🔍 AccountDetails - Firebase user: ${user?.displayName}");

    // Priority: ProfileController data > Preference > Firebase user > default
    final profileName = profile['fullName']?.toString().trim() ?? '';
    final profileBio = profile['bio']?.toString().trim() ?? '';
    final profileEmail = profile['email']?.toString().trim() ?? '';

    nameController.text = profileName.isNotEmpty
        ? profileName
        : Preference.userName.isNotEmpty
            ? Preference.userName
            : (user?.displayName ?? "");

    bioController.text = profileBio.isNotEmpty
        ? profileBio
        : Preference.bio.isNotEmpty
            ? Preference.bio
            : "";

    emailController.text = profileEmail.isNotEmpty
        ? profileEmail
        : Preference.email.isNotEmpty
            ? Preference.email
            : (user?.email ?? "");

    print("🔍 AccountDetails - Final name: '${nameController.text}'");
    print("🔍 AccountDetails - Final bio: '${bioController.text}'");

    // Set initial bio empty state
    isBioEmpty.value = bioController.text.isEmpty;

    nameController.addListener(checkForChanges);
    bioController.addListener(() {
      checkForChanges();
      isBioEmpty.value = bioController.text.isEmpty;
    });

    _startSuggestionTimer();
  }

  void _startSuggestionTimer() {
    _suggestionTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      // Only rotate if bio field is empty
      if (bioController.text.isEmpty) {
        currentBioSuggestionIndex.value =
            (currentBioSuggestionIndex.value + 1) % AppTexts.BIO_SUGGESTIONS.length;
      }
    });
  }

  void checkForChanges() {
    Map<String, dynamic> profile = {};
    if (Get.isRegistered<ProfileController>()) {
      profile = Get.find<ProfileController>().userProfile;
    }

    final nameChanged =
        nameController.text.trim() != (profile['fullName'] ?? '');
    final bioChanged = bioController.text.trim() != (profile['bio'] ?? '');
    final imageChanged = pickedImage.value != null;

    hasChanges.value = nameChanged || bioChanged || imageChanged;
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
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
  }

  void validateName(String v) {
    nameError.value = Validation.validateName(v.trim());
    checkForChanges();
  }

  /// Discard all unsaved changes and restore original values
  void discardChanges() {
    if (!hasChanges.value) {
      Get.back();
      return;
    }

    Get.dialog(
      CustomPopup(
        title: AppTexts.DISCARD_CHANGES_TITLE,
        message: AppTexts.DISCARD_CHANGES_SUBTITLE,
        confirmText: AppTexts.DISCARD,
        cancelText: AppTexts.CANCEL,
        isProcessing: false.obs,
        onConfirm: () {
          _resetToOriginalValues();
          Get.back(); // Close dialog
          Get.back(); // Go back to profile
        },
      ),
    );
  }

  /// Reset all fields to original values
  void _resetToOriginalValues() {
    final user = AuthService().currentUser;
    Map<String, dynamic> profile = {};
    if (Get.isRegistered<ProfileController>()) {
      profile = Get.find<ProfileController>().userProfile;
    }

    final profileName = profile['fullName']?.toString().trim() ?? '';
    final profileBio = profile['bio']?.toString().trim() ?? '';
    final profileEmail = profile['email']?.toString().trim() ?? '';

    nameController.text = profileName.isNotEmpty
        ? profileName
        : Preference.userName.isNotEmpty
            ? Preference.userName
            : (user?.displayName ?? "");

    bioController.text = profileBio.isNotEmpty
        ? profileBio
        : Preference.bio.isNotEmpty
            ? Preference.bio
            : "";

    emailController.text = profileEmail.isNotEmpty
        ? profileEmail
        : Preference.email.isNotEmpty
            ? Preference.email
            : (user?.email ?? "");

    // Clear picked image
    pickedImage.value = null;

    // Reset ProfileController picked image if it was changed
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().pickedImage.value = null;
    }

    hasChanges.value = false;
    nameError.value = null;
  }

  /// Handle back button press - show discard popup if there are unsaved changes
  Future<bool> onWillPop() async {
    if (hasChanges.value) {
      discardChanges();
      return false;
    }
    return true;
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
        final data = resp["data"];

        // Update local storage
        Preference.userName = data["fullName"] ?? Preference.userName;
        Preference.email = data["email"] ?? Preference.email;
        Preference.bio = data["bio"] ?? Preference.bio;

        if (data["profileImageUrl"] != null) {
          Preference.profileImage = data["profileImageUrl"];
          pickedImage.value = null; // Clear local file reference
        }

        // 🔥 Directly update ProfileController userProfile for immediate UI refresh
        if (Get.isRegistered<ProfileController>()) {
          final profileController = Get.find<ProfileController>();
          // Update the userProfile map directly for immediate reactivity
          profileController.userProfile.value = {
            ...profileController.userProfile,
            'fullName': data["fullName"] ?? Preference.userName,
            'email': data["email"] ?? Preference.email,
            'bio': data["bio"] ?? Preference.bio,
            'profileImageUrl': data["profileImageUrl"] ?? Preference.profileImage,
            'phone': data["phone"] ?? Preference.phone,
            'address': data["address"] ?? Preference.address,
          };
          // Clear picked image in ProfileController since we have URL now
          if (data["profileImageUrl"] != null) {
            profileController.pickedImage.value = null;
          }
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
          hideKeyboard();
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

  @override
  void onClose() {
    _suggestionTimer?.cancel();
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    nameFocusNode.dispose();
    bioFocusNode.dispose();
    super.onClose();
  }
}