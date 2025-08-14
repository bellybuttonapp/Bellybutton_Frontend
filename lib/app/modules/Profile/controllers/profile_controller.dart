import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:bellybutton/app/modules/Profile/Innermodule/Account_Details/views/account_details_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bellybutton/app/routes/app_pages.dart';
import '../../../global_widgets/CustomPopup/CustomPopup.dart';

class ProfileController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isProcessing = false.obs;
  RxBool autoSync = false.obs;

  void onAutoSyncChanged(bool value) {
    autoSync.value = value;
    print("Auto-Sync Settings: $value");
  }

  void onEditProfile() {
    Get.to(
      () => AccountDetailsView(),
      transition: Transition.upToDown, // You can use slide, rightToLeft, etc.
      duration: const Duration(milliseconds: 300),
    );
  }

  void onNotificationsTap() => print("Notifications tapped");
  void onPrivacyTap() => print("Privacy & Permissions tapped");
  void onFaqsTap() => print("FAQs tapped");

  /// Common method to show a confirmation dialog
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
        cancelText: app_texts.Cancel,
        isProcessing: isProcessing,
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.4),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        onConfirm: onConfirm,
      ),
    );
  }

  /// Delete Account
  void onDeleteAccountTap() {
    _showConfirmationDialog(
      title: app_texts.D_POPup_Title,
      message: app_texts.D_POPup_SubTitle,
      confirmText: app_texts.Delete,
      onConfirm: () async {
        isProcessing.value = true;
        try {
          // await FirebaseAuth.instance.currentUser?.delete();
          Get.deleteAll(force: true);
          Get.back();
          // showCustomSnackBar('Your account has been deleted successfully.', ErrorState.success);
          Get.offAllNamed(Routes.LOGIN);
        } catch (e) {
          // showCustomSnackBar('Failed to delete account. Please try again.', ErrorState.error);
        } finally {
          isProcessing.value = false;
        }
      },
    );
  }

  /// Sign Out
  void onSignOut() {
    _showConfirmationDialog(
      title: app_texts.S_POPup_Title,
      message: app_texts.s_POPup_SubTitle,
      confirmText: app_texts.Log_out,
      onConfirm: () async {
        isProcessing.value = true;
        try {
          // await FirebaseAuth.instance.signOut();
          Get.deleteAll(force: true);
          Get.back();
          // showCustomSnackBar('You have been logged out successfully.', ErrorState.success);
          Get.offAllNamed(Routes.LOGIN);
        } catch (e) {
          // showCustomSnackBar('Logout failed. Please try again.', ErrorState.error);
        } finally {
          isProcessing.value = false;
        }
      },
    );
  }
}
