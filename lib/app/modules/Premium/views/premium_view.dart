// ignore_for_file: deprecated_member_use, annotate_overrides

import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import '../../../global_widgets/Button/global_button.dart';
import '../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../controllers/premium_controller.dart';

class PremiumView extends GetView<PremiumController> {
  final PremiumController controller = Get.put(PremiumController());
  PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppTexts.PREMIUM_TITLE),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.02),
            SvgPicture.asset(
              AppImages.PREMIUM,
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
            ),
            SizedBox(height: screenHeight * 0.02),
            Obx(() {
              final benefits = controller.getBenefitsForPlan();
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade200, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.shade50.withOpacity(0.2),
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.PREMIUM_SUBTITLE,
                      style: AppText.headingLg.copyWith(
                        color: AppColors.textColor,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ...benefits.map(
                      (benefit) => Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              benefit.icon,
                              width: screenWidth * 0.06,
                              height: screenWidth * 0.06,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Text(
                                benefit.text,
                                style: AppText.headingLg.copyWith(
                                  color: AppColors.tertiaryColor,
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: screenHeight * 0.03),
            Text(
              AppTexts.PREMIUM_CHOOSE_PLAN,
              style: AppText.headingLg.copyWith(
                color: AppColors.textColor,
                fontSize: screenWidth * 0.06,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _planBox(
                    AppTexts.PREMIUM_CURRENT_PLAN,
                    AppTexts.PREMIUM_FREE,
                    0,
                    controller.selectedPlan.value,
                    screenWidth,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  _planBox(
                    AppTexts.PREMIUM_BASE_PLAN,
                    AppTexts.PREMIUM_PLAN1_PRICE,
                    1,
                    controller.selectedPlan.value,
                    screenWidth,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  _planBox(
                    AppTexts.PREMIUM_LABEL,
                    AppTexts.PREMIUM_PLAN2_PRICE,
                    2,
                    controller.selectedPlan.value,
                    screenWidth,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              AppTexts.PREMIUM_CANCEL_ANYTIME,
              style: AppText.headingLg.copyWith(
                color: AppColors.tertiaryColor,
                fontSize: screenWidth * 0.035,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Obx(
              () => global_button(
                loaderWhite: true,
                isLoading: controller.isLoading.value,
                title: AppTexts.SUBSCRIBE_NOW,
                backgroundColor: AppColors.primaryColor,
                textColor: AppColors.textColor3,
                onTap: controller.SubscribeNow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planBox(
    String label,
    String price,
    int index,
    int selectedIndex,
    double screenWidth,
  ) {
    final isSelected = index == selectedIndex;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.find<PremiumController>().selectPlan(index),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.04,
            horizontal: screenWidth * 0.03,
          ),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryColor : AppColors.tertiaryColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppText.headingLg.copyWith(
                  fontSize: screenWidth * 0.035,
                  color:
                      isSelected ? Colors.blue.shade900 : Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                price,
                style: AppText.headingLg.copyWith(
                  fontSize: screenWidth * 0.045,
                  color:
                      isSelected ? Colors.blue.shade900 : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
