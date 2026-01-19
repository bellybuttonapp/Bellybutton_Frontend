// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/utils/index.dart';
import '../../../../global_widgets/Button/global_button.dart';
import '../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../controllers/phone_login_controller.dart';

class PhoneLoginView extends GetView<PhoneLoginController> {
  const PhoneLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFBACCCC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top section with gradient background and profile pictures
            SizedBox(
              height: screenHeight * 0.38,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background Gradient - Full top area
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.1399, 0.274],
                          colors: [
                            Color(0xFF070B17), // 0%
                            Color(0xFF060F1E), // 13.99%
                            Color(0xFF051938), // 27.4%
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Profile Picture 1 - Top Left
                  Positioned(
                    top: screenHeight * 0.02,
                    left: screenWidth * 0.02,
                    child: _buildProfileCircle(
                      AppImages.PROFILE_1,
                      screenWidth * 0.14,
                    ),
                  ),

                  // Profile Picture 2 - Top Right
                  Positioned(
                    top: screenHeight * 0.02,
                    right: screenWidth * 0.02,
                    child: _buildProfileCircle(
                      AppImages.PROFILE_2,
                      screenWidth * 0.12,
                    ),
                  ),

                  // Profile Picture 3 - Bottom Left
                  Positioned(
                    top: screenHeight * 0.28,
                    left: screenWidth * 0.02,
                    child: _buildProfileCircle(
                      AppImages.PROFILE_3,
                      screenWidth * 0.11,
                    ),
                  ),

                  // Profile Picture 4 - Bottom Right
                  Positioned(
                    top: screenHeight * 0.26,
                    right: screenWidth * 0.02,
                    child: _buildProfileCircle(
                      AppImages.PROFILE_4,
                      screenWidth * 0.15,
                    ),
                  ),

                  // App Icon - Centered in the visible background area
                  Positioned(
                    top: screenHeight * 0.12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        height: screenWidth * 0.42,
                        width: screenWidth * 0.42,
                        decoration: BoxDecoration(
                          color: AppColors.textColor3,
                          borderRadius: BorderRadius.circular(screenWidth * 0.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            child: SvgPicture.asset(
                              AppImages.APP_ICON_WITH_TEXT,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // White Form Card
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: screenHeight * 0.62,
              ),
              decoration: BoxDecoration(
                color: AppColors.textColor3,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(screenWidth * 0.07),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.035,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      AppTexts.PHONE_LOGIN_TITLE,
                      style: AppText.headingLg.copyWith(
                        fontSize: screenWidth * 0.055,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),

                    // Subtitle
                    Text(
                      AppTexts.PHONE_LOGIN_SUBTITLE,
                      style: AppText.labelLg.copyWith(
                        fontSize: screenWidth * 0.035,
                        color: AppColors.tertiaryColor,
                      ),
                    ),

                    // Phone Number Field using GlobalTextField
                    Obx(
                      () => GlobalTextField(
                        controller: controller.phoneController,
                        hintText: AppTexts.PHONE_LOGIN_HINT,
                        keyboardType: TextInputType.phone,
                        errorText: controller.phoneError.value,
                        maxLength: controller.maxPhoneLength,
                        onChanged: controller.validatePhone,
                        prefixIcon: GestureDetector(
                          onTap: () => controller.showCountrySheet(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  controller.selectedCountry.value.flagEmoji,
                                  style: TextStyle(fontSize: screenWidth * 0.05),
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  "+${controller.selectedCountry.value.phoneCode}",
                                  style: AppText.headingLg.copyWith(
                                    fontSize: screenWidth * 0.035,
                                    color: AppColors.tertiaryColor,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.tertiaryColor,
                                  size: screenWidth * 0.05,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Terms & Conditions Checkbox
                    Obx(
                      () => Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: controller.termsAccepted.value,
                              activeColor: AppColors.primaryColor,
                              onChanged: (val) {
                                controller.termsAccepted.value = val ?? false;
                              },
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  AppTexts.TERMS_ACCEPT_CHECKBOX,
                                  style: AppText.labelLg.copyWith(
                                    fontSize: screenWidth * 0.035,
                                    color: AppColors.tertiaryColor,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: controller.showTermsDialog,
                                  child: Text(
                                    AppTexts.TERMS_LINK_TEXT,
                                    style: AppText.headingLg.copyWith(
                                      fontSize: screenWidth * 0.035,
                                      color: AppColors.primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Send OTP Button
                    Obx(
                      () => global_button(
                        loaderWhite: true,
                        isLoading: controller.isLoading.value,
                        title: AppTexts.PHONE_LOGIN_SEND_OTP,
                        backgroundColor: controller.termsAccepted.value
                            ? (isDarkMode
                                ? AppTheme.darkTheme.scaffoldBackgroundColor
                                : AppTheme.lightTheme.primaryColor)
                            : Colors.grey, // Gray when terms not accepted
                        onTap: (controller.isLoading.value || !controller.termsAccepted.value)
                            ? null
                            : controller.sendOtp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build profile circle images
  Widget _buildProfileCircle(String imagePath, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // shape: BoxShape.circle,
        // border: Border.all(
        //   color: Colors.white,
        //   width: 2,
        // ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primaryColor.withOpacity(0.3),
              child: Icon(
                Icons.person,
                size: size * 0.5,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
