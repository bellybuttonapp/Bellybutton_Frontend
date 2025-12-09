// ignore_for_file: non_constant_identifier_names, avoid_print, unused_local_variable, unnecessary_null_comparison

import 'dart:io';
import 'package:bellybutton/app/Controllers/oauth.dart';
import 'package:bellybutton/app/modules/Profile/Innermodule/Reset_password/views/reset_password_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class ProfileController extends GetxController {
  RxBool isLoading = false.obs; //--for shimmer / profile fetch
  RxBool isProcessing = false.obs; //--for delete account
  RxBool autoSync = false.obs; //--For auto sync
  RxBool isSigningOut = false.obs; //--for sign out button loader
  Rx<User?> currentUser = AuthService().currentUser.obs;
  RxMap<String, dynamic> userProfile = <String, dynamic>{}.obs;
  Rx<File?> pickedImage = Rx<File?>(null);

  void updatePickedImage(File? image) => pickedImage.value = image;

  @override
  void onInit() {
    super.onInit();

    if (Preference.userId != null) {
      fetchProfileById(Preference.userId!);
    }

    // Listen for Firebase Auth changes
    AuthService().authStateChanges.listen((user) {
      currentUser.value = user;
    });
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
        print("✅ Profile synced to Preference - userName: ${Preference.userName}, bio: ${Preference.bio}");
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

  void onAutoSyncChanged(bool value) => autoSync.value = value;

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

  void ResetPassword() {
    Get.to(
      () => ResetPasswordView(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  void onPrivacyTap() => print("Privacy & Permissions tapped");
  void onFaqsTap() => print("FAQs tapped");

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Future<void> Function() onConfirm,
    RxBool? processingState,
  }) {
    Get.dialog(
      CustomPopup(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: AppTexts.CANCEL,
        isProcessing: processingState ?? isProcessing,
        onConfirm: onConfirm,
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
      onConfirm: () async {
        isProcessing.value = true;
        try {
          try {
            await DioClient().postRequest(
              Endpoints.DELETE_ACCOUNT,
              data: {"email": Preference.email},
            );
          } catch (apiError) {
            print("API account deletion error: $apiError");
          }

          await AuthService().deleteAccount();
          Preference.clearAll();
          Get.deleteAll(force: true);
          Get.back();
          Get.offAllNamed(Routes.LOGIN);

          showCustomSnackBar(
            AppTexts.ACCOUNT_DELETED_SUCCESS,
            SnackbarState.success,
          );
        } catch (e) {
          showCustomSnackBar(
            AppTexts.ACCOUNT_DELETE_ERROR,
            SnackbarState.error,
          );
          print("Account deletion error: $e");
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
      onConfirm: () async {
        isSigningOut.value = true;
        try {
          await AuthService().signOutUser();

          // Clear all user data from Preference (preserves EVENT_UPLOADED_HASHES)
          Preference.clearAll();
          Preference.isLoggedIn = false;

          // Clear local controller state
          userProfile.value = {};
          pickedImage.value = null;

          // Close the dialog first
          Get.back();

          // Delete all controllers to clear cached data
          Get.deleteAll(force: true);

          Get.offAllNamed(Routes.LOGIN);

          showCustomSnackBar(AppTexts.LOGOUT_SUCCESS, SnackbarState.success);
        } catch (e) {
          showCustomSnackBar(AppTexts.LOGOUT_ERROR, SnackbarState.error);
          print("Logout error: $e");
        } finally {
          isSigningOut.value = false;
        }
      },
    );
  }
}
