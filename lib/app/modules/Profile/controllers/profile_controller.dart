// ignore_for_file: non_constant_identifier_names, avoid_print, unused_local_variable, unnecessary_null_comparison

import 'dart:io';
import 'package:bellybutton/app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:bellybutton/app/Controllers/oauth.dart';
import 'package:get/get.dart';
import '../../../api/PublicApiService.dart';
import '../../../core/network/dio_client.dart';
import '../../../api/end_points.dart';
import '../../../core/constants/app_texts.dart';
import '../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/storage/preference.dart';
import '../Innermodule/Account_Details/views/account_details_view.dart';
import '../../../modules/terms_and_conditions/views/terms_and_conditions_view.dart';
import '../../../modules/terms_and_conditions/bindings/terms_and_conditions_binding.dart';

class ProfileController extends GetxController {
  RxBool isLoading = false.obs; //--for shimmer / profile fetch
  RxBool isProcessing = false.obs; //--for delete account
  RxBool autoSync = false.obs; //--For auto sync
  RxBool isSigningOut = false.obs; //--for sign out button loader
  RxMap<String, dynamic> userProfile = <String, dynamic>{}.obs;
  Rx<File?> pickedImage = Rx<File?>(null);

  void updatePickedImage(File? image) => pickedImage.value = image;

  @override
  void onInit() {
    super.onInit();

    // Load autoSync setting from Preference
    autoSync.value = Preference.autoSync;

    if (Preference.userId > 0) {
      fetchProfileById(Preference.userId);
    }
  }

  Future<void> fetchProfileById(int userId) async {
    isLoading.value = true;

    try {
      final result = await PublicApiService().getProfileById(userId);

      // Check if data exists (API returns {data: {...}, message: "..."})
      if (result["data"] != null) {
        final data = result["data"];
        userProfile.value = data;

        // Sync to Preference for persistence across logout/login
        if (data["fullName"] != null) {
          Preference.userName = data["fullName"];
        }
        if (data["email"] != null) {
          Preference.email = data["email"];
        }
        if (data["bio"] != null) {
          Preference.bio = data["bio"];
        }
        if (data["profileImageUrl"] != null) {
          Preference.profileImage = data["profileImageUrl"];
        }
        if (data["phone"] != null) {
          Preference.phone = data["phone"];
        }
        if (data["address"] != null) {
          Preference.address = data["address"];
        }
        print(
          "✅ Profile synced to Preference - userName: ${Preference.userName}, bio: ${Preference.bio}",
        );
      } else {
        final msg = result["message"] ?? "Failed to fetch profile";
        print("⚠️ Profile fetch failed: $msg");
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onAutoSyncChanged(bool value) {
    autoSync.value = value;
    Preference.autoSync = value; // Persist to storage
  }

  void onEditProfile() async {
    // Wait for profile data to be loaded before opening AccountDetails
    if (userProfile.isEmpty && Preference.userId > 0) {
      await fetchProfileById(Preference.userId);
    }

    await Get.to(
      () => AccountDetailsView(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 300),
    );

    // Refresh profile data when returning from AccountDetails
    if (Preference.userId > 0) {
      fetchProfileById(Preference.userId);
    }
  }

  // Reset password functionality removed - using OTP login now

  void onPrivacyTap() {
    Get.to(
      () => const TermsAndConditionsView(),
      binding: TermsAndConditionsBinding(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 350),
      preventDuplicates: true,
    );
  }

  void onFaqsTap() => print("FAQs tapped");

void _showConfirmationDialog({
  required String title,
  required String message,
  required String confirmText,
  required Future<void> Function() onConfirm,
  RxBool? processingState,

  // 🔥 Optional button colors
  Color? confirmButtonColor,
  Color? cancelButtonColor,
}) {
  Get.dialog(
    CustomPopup(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: AppTexts.CANCEL,
      isProcessing: processingState ?? isProcessing,
      onConfirm: onConfirm,

      // pass colors
      confirmButtonColor: confirmButtonColor,
      cancelButtonColor: cancelButtonColor,
    ),
  );
}


  /// =====================
  /// DELETE ACCOUNT
  /// =====================
void onDeleteAccountTap() {
  _showConfirmationDialog(
    title: AppTexts.DELETE_POPUP_TITLE,
    message: AppTexts.DELETE_POPUP_SUBTITLE,
    confirmText: AppTexts.DELETE,

    // 🔥 Red destructive action
    confirmButtonColor:AppColors.error,
    cancelButtonColor: AppColors.primaryColor,

    onConfirm: () async {
      isProcessing.value = true;
      try {
        await DioClient().postRequest(
          Endpoints.DELETE_ACCOUNT,
          data: {"email": Preference.email},
        );

        await AuthService().deleteAccount();
        Preference.clearAll();
        Get.deleteAll(force: true);

        Get.back();
        Get.offAllNamed(Routes.PHONE_LOGIN);

        showCustomSnackBar(
          AppTexts.ACCOUNT_DELETED_SUCCESS,
          SnackbarState.success,
        );
      } catch (e) {
        showCustomSnackBar(
          AppTexts.ACCOUNT_DELETE_ERROR,
          SnackbarState.error,
        );
      } finally {
        isProcessing.value = false;
      }
    },
  );
}


  void onSignOut() {
  _showConfirmationDialog(
    title: AppTexts.SIGNOUT_POPUP_TITLE,
    message: AppTexts.SIGNOUT_POPUP_SUBTITLE,
    confirmText: AppTexts.LOGOUT,
    processingState: isSigningOut,

    // 🔥 Same styling pattern as Delete Account
       confirmButtonColor:AppColors.error,
    cancelButtonColor: AppColors.primaryColor,

    onConfirm: () async {
      isSigningOut.value = true;
      try {
        await AuthService().signOutUser();

        // Clear all user data from Preference
        Preference.clearAll();
        Preference.isLoggedIn = false;

        // Clear local controller state
        userProfile.value = {};
        pickedImage.value = null;

        // Close popup
        Get.back();

        // Clear controllers
        Get.deleteAll(force: true);

        Get.offAllNamed(Routes.PHONE_LOGIN);

        showCustomSnackBar(
          AppTexts.LOGOUT_SUCCESS,
          SnackbarState.success,
        );
      } catch (e) {
        showCustomSnackBar(
          AppTexts.LOGOUT_ERROR,
          SnackbarState.error,
        );
        print("Logout error: $e");
      } finally {
        isSigningOut.value = false;
      }
    },
  );
}

}
