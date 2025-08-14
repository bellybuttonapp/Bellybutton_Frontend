import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/themes/Font_style.dart';
import '../../../core/themes/dimensions.dart';
import '../../../global_widgets/Button/global_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          /// Background
          Positioned.fill(child: Image.asset(app_images.on, fit: BoxFit.cover)),

          /// Content
          SafeArea(
            child: Column(
              children: [
                const Expanded(flex: 60, child: SizedBox()),

                /// Title & Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_LARGE,
                  ),
                  child: Column(
                    children: [
                      _buildTitle(size),
                      const SizedBox(height: 12),
                      _buildSubtitle(size),
                    ],
                  ),
                ),

                const Expanded(flex: 3, child: SizedBox()),

                /// Bottom Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_LARGE,
                    vertical: Dimensions.PADDING_SIZE_LARGE,
                  ),
                  child: Obx(
                    () => global_button(
                      isLoading: controller.isLoading.value, // ✅ Reactive
                      title: app_texts.onboardingbutton,
                      backgroundColor: AppColors.textColor3,
                      textColor: AppColors.primaryColor,
                      onTap: controller.goToNext,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Title Widget
  Widget _buildTitle(Size size) {
    return Text(
      app_texts.onboardingTitle1,
      textAlign: TextAlign.center,
      style: customBoldText.copyWith(
        color: AppColors.textColor3,
        fontSize: Dimensions.fontSizeLarge,
      ),
    );
  }

  /// Subtitle Widget
  Widget _buildSubtitle(Size size) {
    return Text(
      app_texts.onboardingSubtitle1,
      textAlign: TextAlign.center,
      style: customBoldText.copyWith(
        color: AppColors.tertiaryColor,
        fontSize: Dimensions.fontSizeSmall,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
