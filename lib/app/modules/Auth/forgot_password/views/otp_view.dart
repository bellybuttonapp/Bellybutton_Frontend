// ignore_for_file: annotate_overrides, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_texts.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import '../../../../global_widgets/Button/global_button.dart';
import '../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../controllers/forgot_password_controller.dart';

class OtpView extends GetView<ForgotPasswordController> {
  final ForgotPasswordController controller = Get.put(
    ForgotPasswordController(),
  );

  OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final basePinTheme = PinTheme(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      width: screenWidth * 0.12,
      height: screenHeight * 0.07,
      textStyle: customBoldText.copyWith(fontSize: screenWidth * 0.05),
      decoration: BoxDecoration(
        color: AppColors.textColor3,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.tertiaryColor, width: 0.8),
      ),
    );

    final focusedPinTheme = basePinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primaryColor, width: 2),
      boxShadow: [
        BoxShadow(
          blurRadius: 8,
          offset: const Offset(0, 2),
          color: AppColors.primaryColor.withOpacity(0.15),
        ),
      ],
    );

    final submittedPinTheme = basePinTheme.copyDecorationWith(
      color: AppColors.textColor3,
      border: Border.all(color: AppColors.tertiaryColor.withOpacity(0.2)),
    );

    final errorPinTheme = basePinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primaryColor1, width: 2),
    );

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.05),

                Center(
                  child: Image.asset(
                    AppImages.FORGET_PSWRD,
                    height: screenHeight * 0.2,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                Text(
                  AppTexts.OTP_TITLE,
                  style: customBoldText.copyWith(fontSize: screenWidth * 0.06),
                ),
                SizedBox(height: screenHeight * 0.01),

                Text(
                  AppTexts.OTP_SUBTITLE,
                  style: customBoldText.copyWith(
                    color: AppColors.tertiaryColor,
                    fontSize: screenWidth * 0.04,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: screenHeight * 0.03),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (controller.otpError.value.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.005),
                        child: Text(
                          controller.otpError.value,
                          style: customBoldText.copyWith(
                            color: AppColors.primaryColor1,
                            fontSize: screenWidth * 0.035,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                    Pinput(
                      length: 4, // your 4-digit OTP
                      controller: controller.otpController,
                      focusNode: controller.otpFocusNode,
                      autofocus: true,
                      pinAnimationType: PinAnimationType.fade,
                      closeKeyboardWhenCompleted: true,
                      showCursor: true,
                      obscureText: true,
                      obscuringCharacter: "*",
                      defaultPinTheme: basePinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: submittedPinTheme,
                      errorPinTheme: errorPinTheme,
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                      autofillHints: const [
                        AutofillHints.oneTimeCode,
                      ], // ✅ Enable OTP autofill
                      onChanged: (val) {
                        controller.otp.value = val;
                        if (controller.otpError.value.isNotEmpty) {
                          controller.otpError.value = '';
                        }
                      },
                      onCompleted: (_) => controller.verifyOtp(),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),

                global_button(
                  loaderWhite: true,
                  isLoading: controller.isLoading.value,
                  title: "Verify",
                  backgroundColor: AppColors.primaryColor,
                  textColor: Colors.white,
                  onTap: controller.verifyOtp,
                ),

                SizedBox(height: screenHeight * 0.015),
                Obx(
                  () => Row(
                    children: [
                      Text(
                        AppTexts.RESEND_OTP,
                        style: customBoldText.copyWith(
                          color: AppColors.tertiaryColor,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.015),

                      controller.isResendEnabled.value
                          ? GestureDetector(
                            onTap: () async {
                              await controller
                                  .resendOtp(); // Only resend, no effect on Verify loader
                            },
                            child: Obx(
                              () =>
                                  controller.isResendLoading.value
                                      ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(
                                        AppTexts.RESEND_NOW,
                                        style: customBoldText.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor,
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                            ),
                          )
                          : Text(
                            "Resend in ${controller.resendSeconds.value}s",
                            style: customBoldText.copyWith(
                              color: AppColors.tertiaryColor,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
