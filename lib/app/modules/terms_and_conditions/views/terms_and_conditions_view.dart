import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/utils/themes/font_style.dart';
import '../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../global_widgets/Shimmers/TermsContentShimmer.dart';
import '../controllers/terms_and_conditions_controller.dart';

class TermsAndConditionsView extends GetView<TermsAndConditionsController> {
  const TermsAndConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppTexts.PRIVACY_PERMISSIONS),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const TermsContentShimmer();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: screenWidth * 0.15,
                  color: AppColors.tertiaryColor,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  controller.errorMessage.value,
                  style: customBoldText.copyWith(
                    fontSize: screenWidth * 0.04,
                    color: AppColors.tertiaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02),
                TextButton(
                  onPressed: controller.fetchTermsAndConditions,
                  child: Text(
                    "Retry",
                    style: customBoldText.copyWith(
                      fontSize: screenWidth * 0.035,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          child: HtmlWidget(
            controller.content.value,
            textStyle: customBoldText.copyWith(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.6,
            ),
            customStylesBuilder: (element) {
              if (element.localName == 'h2') {
                return {
                  'font-size': '${screenWidth * 0.05}px',
                  'font-weight': '700',
                  'color': isDark ? '#FFFFFF' : '#000000',
                  'margin-bottom': '12px',
                };
              }
              if (element.localName == 'h3') {
                return {
                  'font-size': '${screenWidth * 0.042}px',
                  'font-weight': '600',
                  'color': isDark ? '#FFFFFF' : '#1a1a1a',
                  'margin-top': '16px',
                  'margin-bottom': '8px',
                };
              }
              if (element.localName == 'p') {
                return {
                  'font-size': '${screenWidth * 0.038}px',
                  'color': isDark ? '#E0E0E0' : '#333333',
                  'line-height': '1.6',
                };
              }
              if (element.localName == 'li') {
                return {
                  'font-size': '${screenWidth * 0.036}px',
                  'color': isDark ? '#D0D0D0' : '#444444',
                  'margin-bottom': '6px',
                };
              }
              return null;
            },
          ),
        );
      }),
    );
  }
}
