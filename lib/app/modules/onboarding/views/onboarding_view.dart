import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import '../../../global_widgets/Button/global_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // System UI Styling
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return GetBuilder<OnboardingController>(
      builder: (controller) {
        return Scaffold(
          body: Stack(
            children: [
              /// Background
              Positioned.fill(
                child: Image.asset(
                  AppImages.ONBOARDING_PNG1,
                  fit: BoxFit.cover,
                ),
              ),

              /// Content
              SafeArea(
                child: Column(
                  children: [
                    const Expanded(flex: 60, child: SizedBox()),

                    /// Title & Subtitle
                    Padding(
                      padding: AppInsets.horizontalLg,
                      child: Column(
                        children: [
                          _buildTitle(size),
                          AppGap.v12,
                          _buildSubtitle(size),
                        ],
                      ),
                    ),

                    const Expanded(flex: 3, child: SizedBox()),

                    /// Bottom Button
                    Padding(
                      padding: AppInsets.all20,
                      child: Obx(
                        () => global_button(
                          isLoading: controller.isLoading.value,
                          title: AppTexts.ONBOARDING_BUTTON,
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
      },
    );
  }

  /// Title Widget
  Widget _buildTitle(Size size) {
    return Text(
      AppTexts.ONBOARDING_TITLE1,
      textAlign: TextAlign.center,
      style: AppText.headingLg.copyWith(
        color: AppColors.textColor3,
        fontSize: Dimensions.fontSizeLarge,
      ),
    );
  }

  /// Subtitle Widget
  Widget _buildSubtitle(Size size) {
    return Text(
      AppTexts.ONBOARDING_SUBTITLE1,
      textAlign: TextAlign.center,
      style: AppText.headingLg.copyWith(
        color: AppColors.tertiaryColor,
        fontSize: Dimensions.fontSizeSmall,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
