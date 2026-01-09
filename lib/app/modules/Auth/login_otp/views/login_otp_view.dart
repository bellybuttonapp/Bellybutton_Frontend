// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/utils/index.dart';
import '../../../../global_widgets/Button/global_button.dart';
import '../controllers/login_otp_controller.dart';

class LoginOtpView extends GetView<LoginOtpController> {
  const LoginOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Pin Theme
    final defaultPinTheme = PinTheme(
      width: screenWidth * 0.12,
      height: screenWidth * 0.13,
      textStyle: TextStyle(
        fontSize: screenWidth * 0.05,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primaryColor, width: 2),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.red, width: 2),
    );

    return GetBuilder<LoginOtpController>(
      builder: (controller) => Scaffold(
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

          // Back Button - Top Left
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.02,
            child: SafeArea(
              child: IconButton(
                onPressed: controller.goBack,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: screenWidth * 0.06,
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
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Title
                    Text(
                      AppTexts.LOGIN_OTP_TITLE,
                      style: customBoldText.copyWith(
                        fontSize: screenWidth * 0.055,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),

                    // Subtitle with phone number
                    Text(
                      "${AppTexts.LOGIN_OTP_SUBTITLE}\n${controller.phone}",
                      style: customMediumText.copyWith(
                        fontSize: screenWidth * 0.035,
                        color: AppColors.tertiaryColor,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // OTP Field with error
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (controller.otpError.value.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: screenHeight * 0.01,
                              ),
                              child: Text(
                                controller.otpError.value,
                                style: customMediumText.copyWith(
                                  color: Colors.red,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ),
                          Center(
                            child: Pinput(
                              length: 6,
                              controller: controller.otpController,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              errorPinTheme: errorPinTheme,
                              showCursor: true,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              pinAnimationType: PinAnimationType.scale,
                              // Enable OTP autofill hints for keyboard suggestions
                              autofillHints: const [AutofillHints.oneTimeCode],
                              onChanged: (val) {
                                if (controller.otpError.value.isNotEmpty) {
                                  controller.otpError.value = '';
                                }
                              },
                              onCompleted: (_) => controller.verifyOtp(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.035),

                    // Verify Button
                    Obx(
                      () => global_button(
                        loaderWhite: true,
                        title: AppTexts.LOGIN_OTP_VERIFY,
                        onTap: controller.isLoading.value
                            ? null
                            : controller.verifyOtp,
                        isLoading: controller.isLoading.value,
                        backgroundColor: isDarkMode
                            ? AppTheme.darkTheme.scaffoldBackgroundColor
                            : AppTheme.lightTheme.primaryColor,
                        textColor: Colors.white,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Resend Row with timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppTexts.LOGIN_OTP_DIDNT_GET,
                          style: customMediumText.copyWith(
                            color: AppColors.textColor,
                          ),
                        ),
                        Obx(
                          () => GestureDetector(
                            onTap: controller.canResend.value
                                ? controller.resendOtp
                                : null,
                            child: controller.canResend.value
                                ? Text(
                                    AppTexts.LOGIN_OTP_RESEND,
                                    style: customBoldText.copyWith(
                                      color: AppColors.primaryColor,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  )
                                : Text(
                                    "${AppTexts.LOGIN_OTP_RESEND_IN} ${controller.resendSeconds.value}s",
                                    style: customMediumText.copyWith(
                                      color: Colors.grey,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Change Number Link
                    Center(
                      child: GestureDetector(
                        onTap: controller.goBack,
                        child: Text(
                          AppTexts.LOGIN_OTP_CHANGE_NUMBER,
                          style: customBoldText.copyWith(
                            color: AppColors.primaryColor,
                            fontSize: screenWidth * 0.035,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    ],
                  ),
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
    ));
  }

  // Helper method to build profile circle images
  Widget _buildProfileCircle(String imagePath, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
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
