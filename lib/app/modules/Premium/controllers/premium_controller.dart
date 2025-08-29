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
          Benefit(AppTexts.premiumPlan1Benefit1, app_images.usersIcon),
          Benefit(AppTexts.premiumPlan1Benefit2, app_images.uploadIcon),
          Benefit(AppTexts.premiumPlan1Benefit3, app_images.featureIcon),
          Benefit(AppTexts.premiumPlan1Benefit4, app_images.shareIcon),
        ];
      case 2:
        return [
          Benefit(AppTexts.premiumPlan2Benefit1, app_images.usersIcon),
          Benefit(AppTexts.premiumPlan2Benefit2, app_images.uploadIcon),
          Benefit(AppTexts.premiumPlan2Benefit3, app_images.featureIcon),
          Benefit(AppTexts.premiumPlan2Benefit4, app_images.shareIcon),
        ];
      case 3:
        return [
          Benefit(AppTexts.premiumPlan2Benefit1, app_images.usersIcon),
          Benefit(AppTexts.premiumPlan2Benefit2, app_images.uploadIcon),
          Benefit(AppTexts.premiumPlan2Benefit3, app_images.featureIcon),
          Benefit(AppTexts.premiumPlan2Benefit4, app_images.shareIcon),
        ];
      default:
        return [
          Benefit(
            "Free plan – Limited features available.",
            app_images.usersIcon,
          ),
        ];
    }
  }

  void SubscribeNow() {
    // Example: start loading
    isLoading.value = true;

    // Show error snack
    showCustomSnackBar(AppTexts.SubscribeNow, SnackbarState.pending);

    // Stop loading after some delay (demo)
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
    });
  }
}
