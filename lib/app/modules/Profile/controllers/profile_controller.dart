// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:io';

import 'package:bellybutton/app/Controllers/oauth.dart';
import 'package:bellybutton/app/modules/Premium/views/premium_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../api/DioClient.dart';
import '../../../api/end_points.dart';
import '../../../core/constants/app_texts.dart';
import '../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/preference.dart';
import '../../Auth/login/controllers/login_controller.dart';
import '../Innermodule/Account_Details/views/account_details_view.dart';

class ProfileController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isProcessing = false.obs;
  RxBool autoSync = false.obs;
  Rx<User?> currentUser = AuthService().currentUser.obs;

  Rx<File?> pickedImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    AuthService().authStateChanges.listen((user) {
      currentUser.value = user;
    });
  }

  void updatePickedImage(File? image) {
    pickedImage.value = image;
  }

  void onAutoSyncChanged(bool value) => autoSync.value = value;

  void onEditProfile() {
    Get.to(
      () => AccountDetailsView(),
      transition: Transition.upToDown,
      duration: const Duration(milliseconds: 300),
    );
  }

  void PremiumScreen() {
    Get.to(PremiumView());
  }

  void onSetNewPasswordTap() => print("Set New Password tapped");
  void onPrivacyTap() => print("Privacy & Permissions tapped");
  void onFaqsTap() => print("FAQs tapped");

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Future<void> Function() onConfirm,
  }) {
    Get.dialog(
      CustomPopup(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: AppTexts.cancel,
        isProcessing: isProcessing,
        onConfirm: onConfirm,
      ),
    );
  }

  /// =====================
  /// DELETE ACCOUNT
  /// =====================
  void onDeleteAccountTap() {
    _showConfirmationDialog(
      title: AppTexts.deletePopupTitle,
      message: AppTexts.deletePopupSubtitle,
      confirmText: AppTexts.delete,
      onConfirm: () async {
        isProcessing.value = true;
        try {
          // 1️⃣ Call API to delete user account (if logged in via API)
          try {
            await DioClient().postRequest(
              Endpoints.deleteAccount, // make sure you have this endpoint
              data: {"email": Preference.email},
            );
          } catch (apiError) {
            print("API account deletion error: $apiError");
          }

          // 2️⃣ Delete Firebase account
          await AuthService().deleteAccount();

          // ✅ Clear login flag and all preferences
          Preference.clearAll();

          Get.deleteAll(force: true);
          Get.back();
          Get.offAllNamed(Routes.LOGIN);

          showCustomSnackBar(
            AppTexts.accountDeletedSuccess,
            SnackbarState.success,
          );
        } catch (e) {
          showCustomSnackBar(AppTexts.accountDeleteError, SnackbarState.error);
          print("Account deletion error: $e");
        } finally {
          isProcessing.value = false;
        }
      },
    );
  }

  /// =====================
  /// SIGN OUT
  /// =====================
  void onSignOut() {
    _showConfirmationDialog(
      title: AppTexts.signOutPopupTitle,
      message: AppTexts.signOutPopupSubtitle,
      confirmText: AppTexts.logout,
      onConfirm: () async {
        isLoading.value = true;
        try {
          // Call the AuthService to sign out (Firebase + Google)
          await AuthService().signOut();

          // Clear login flags
          Preference.isLoggedIn = false;
          Preference.email = '';

          // Remove only the login controller
          if (Get.isRegistered<LoginController>()) {
            Get.delete<LoginController>(force: true);
          }

          // Close the dialog
          Get.back();

          // Navigate to login screen
          Get.offAllNamed(Routes.LOGIN);

          showCustomSnackBar(AppTexts.logoutSuccess, SnackbarState.success);
        } catch (e) {
          showCustomSnackBar(AppTexts.logoutError, SnackbarState.error);
          print("Logout error: $e");
        } finally {
          isLoading.value = false;
        }
      },
    );
  }
}
