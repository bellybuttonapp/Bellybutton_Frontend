// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:io';
import 'package:bellybutton/app/Controllers/oauth.dart';
import 'package:bellybutton/app/modules/Profile/Innermodule/Reset_password/views/reset_password_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../api/end_points.dart';
import '../../../core/constants/app_texts.dart';
import '../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/storage/preference.dart';
import '../../Auth/login/controllers/login_controller.dart';
import '../Innermodule/Account_Details/views/account_details_view.dart';

class ProfileController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isProcessing = false.obs;
  RxBool autoSync = false.obs;
  RxBool isSigningOut = false.obs;
  Rx<User?> currentUser = AuthService().currentUser.obs;

  Rx<File?> pickedImage = Rx<File?>(null);

  void updatePickedImage(File? image) => pickedImage.value = image;

  @override
  void onInit() {
    super.onInit();

    // ✅ Load saved profile image if it’s a local file
    if (Preference.profileImage != null &&
        Preference.profileImage!.isNotEmpty &&
        !Preference.profileImage!.startsWith('http')) {
      pickedImage.value = File(Preference.profileImage!);
    }

    // ✅ Listen for Firebase Auth changes
    AuthService().authStateChanges.listen((user) {
      currentUser.value = user;
    });
  }

  void onAutoSyncChanged(bool value) => autoSync.value = value;

  void onEditProfile() {
    Get.to(
      () => AccountDetailsView(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 300),
    );
  }

  // void PremiumScreen() {
  //   Get.to(
  //     () => PremiumView(),
  //     transition: Transition.rightToLeft,
  //     duration: const Duration(milliseconds: 300),
  //   );
  // }

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
  }) {
    Get.dialog(
      CustomPopup(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: AppTexts.CANCEL,
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
      title: AppTexts.DELETE_POPUP_TITLE,
      message: AppTexts.DELETE_POPUP_SUBTITLE,
      confirmText: AppTexts.DELETE,
      onConfirm: () async {
        isProcessing.value = true;
        try {
          // 1️⃣ API account deletion
          try {
            await DioClient().postRequest(
              Endpoints.DELETE_ACCOUNT,
              data: {"email": Preference.email},
            );
          } catch (apiError) {
            print("API account deletion error: $apiError");
          }

          // 2️⃣ Delete Firebase account
          await AuthService().deleteAccount();

          // ✅ Clear data and navigate to login
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
      onConfirm: () async {
        isSigningOut.value = true;
        try {
          await AuthService().signOutUser();

          // 🔥 Remove only user session values – NOT uploaded list!
          Preference.box.delete(Preference.USER_ID);
          Preference.box.delete(Preference.USER_EMAIL);
          Preference.box.delete(Preference.TOKEN);
          Preference.isLoggedIn = false;

          // 🔐 Preserve uploaded photo history forever
          Preference.box.put(
            Preference.EVENT_UPLOADED_HASHES,
            Preference.box.get(
              Preference.EVENT_UPLOADED_HASHES,
              defaultValue: <String>[],
            ),
          );

          // Remove old login controller instance
          if (Get.isRegistered<LoginController>()) {
            Get.delete<LoginController>(force: true);
          }

          // 🚀 Reset Navigation
          Get.back();
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
