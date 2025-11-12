// ignore_for_file: non_constant_identifier_names

import 'package:get/get.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/constants/app_images.dart';
import '../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';

class Benefit {
  final String text;
  final String icon; // SVG path
  Benefit(this.text, this.icon);
}

class PremiumController extends GetxController {
  RxBool isLoading = false.obs;
  var selectedPlan = 0.obs;

  void selectPlan(int index) {
    selectedPlan.value = index;
  }

  List<Benefit> getBenefitsForPlan() {
    switch (selectedPlan.value) {
      case 1:
        return [
          Benefit(AppTexts.PREMIUM_PLAN1_BENEFIT1, AppImages.USERS_ICON),
          Benefit(AppTexts.PREMIUM_PLAN1_BENEFIT2, AppImages.UPLOAD_ICON),
          Benefit(AppTexts.PREMIUM_PLAN1_BENEFIT3, AppImages.FEATURE_ICON),
          Benefit(AppTexts.PREMIUM_PLAN1_BENEFIT4, AppImages.SHARE_ICON),
        ];
      case 2:
        return [
          Benefit(AppTexts.PREMIUM_PLAN2_BENEFIT1, AppImages.USERS_ICON),
          Benefit(AppTexts.PREMIUM_PLAN2_BENEFIT2, AppImages.UPLOAD_ICON),
          Benefit(AppTexts.PREMIUM_PLAN2_BENEFIT3, AppImages.FEATURE_ICON),
          Benefit(AppTexts.PREMIUM_PLAN2_BENEFIT4, AppImages.SHARE_ICON),
        ];
      case 3:
        return [
          Benefit(AppTexts.PREMIUM_PLAN2_BENEFIT1, AppImages.USERS_ICON),
          Benefit(AppTexts.PREMIUM_PLAN2_BENEFIT2, AppImages.UPLOAD_ICON),
          Benefit(AppTexts.PREMIUM_PLAN2_BENEFIT3, AppImages.FEATURE_ICON),
          Benefit(AppTexts.PREMIUM_PLAN2_BENEFIT4, AppImages.SHARE_ICON),
        ];
      default:
        return [
          Benefit(AppTexts.FREE_PLAN_LIMITED_FEATURES, AppImages.USERS_ICON),
        ];
    }
  }

  void SubscribeNow() {
    // Example: start loading
    isLoading.value = true;

    // Show error snack
    showCustomSnackBar(AppTexts.SUBSCRIBE_NOW, SnackbarState.pending);

    // Stop loading after some delay (demo)
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
    });
  }
}
