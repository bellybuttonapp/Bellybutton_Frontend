// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
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
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFBACCCC),
      body: Stack(
        children: [
          // Background Gradient - Full top area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.1399, 0.274, ],
                  colors: [
                    Color(0xFF070B17), // 0%
                    Color(0xFF060F1E), // 13.99%
                    Color(0xFF051938), // 27.4%
                    // Color(0xFF0F508A), // 47.6%
                    // Color(0xFF438AB6), // 63.94%
                    // Color(0xFF6AA8C4), // 76.92%
                    // Color(0xFF91BECE), // 85.58%
                    // Color(0xFFBACCCC), // 100%
                  ],
                ),
              ),
            ),
          ),

          // Profile Picture 1 - Top Left
          Positioned(
            top: screenHeight * 0.08,
            left: screenWidth * 0.05,
            child: _buildProfileCircle(
              AppImages.PROFILE_1,
              screenWidth * 0.14,
            ),
          ),

          // Profile Picture 2 - Top Right
          Positioned(
            top: screenHeight * 0.06,
            right: screenWidth * 0.08,
            child: _buildProfileCircle(
              AppImages.PROFILE_2,
              screenWidth * 0.12,
            ),
          ),

          // Profile Picture 3 - Middle Left
          Positioned(
            top: screenHeight * 0.22,
            left: screenWidth * 0.12,
            child: _buildProfileCircle(
              AppImages.PROFILE_3,
              screenWidth * 0.11,
            ),
          ),

          // Profile Picture 4 - Middle Right
          Positioned(
            top: screenHeight * 0.18,
            right: screenWidth * 0.05,
            child: _buildProfileCircle(
              AppImages.PROFILE_4,
              screenWidth * 0.15,
            ),
          ),

          // White Form Card - Overlaps background
          Positioned(
            top: screenHeight * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
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
                      style: customBoldText.copyWith(
                        fontSize: screenWidth * 0.055,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),

                    // Subtitle
                    Text(
                      AppTexts.PHONE_LOGIN_SUBTITLE,
                      style: customMediumText.copyWith(
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
                                  style: customBoldText.copyWith(
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

                    // Send OTP Button
                    Obx(
                      () => global_button(
                        loaderWhite: true,
                        isLoading: controller.isLoading.value,
                        title: AppTexts.PHONE_LOGIN_SEND_OTP,
                        backgroundColor: isDarkMode
                            ? AppTheme.darkTheme.scaffoldBackgroundColor
                            : AppTheme.lightTheme.primaryColor,
                        onTap: controller.isLoading.value
                            ? null
                            : controller.sendOtp,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Terms Text
                    Center(
                      child: Text(
                        AppTexts.PHONE_LOGIN_TERMS,
                        style: customMediumText.copyWith(
                          fontSize: screenWidth * 0.03,
                          color: AppColors.textColor.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // App Icon - Centered in the visible background area
          Positioned(
            top: screenHeight * 0.12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: screenWidth * 0.26,
                width: screenWidth * 0.26,
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
                    child: Image.asset(
                      AppImages.APP_ICON,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
