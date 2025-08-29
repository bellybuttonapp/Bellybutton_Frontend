// ignore_for_file: annotate_overrides, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/themes/Font_style.dart';
import '../../../../core/themes/dimensions.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final basePinTheme = PinTheme(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ), // 👈 Space between boxes
      width: 50,
      height: 56,
      textStyle: customBoldText.copyWith(fontSize: Dimensions.fontSizeLarge),
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
          padding: const EdgeInsets.all(20.0),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                Center(
                  child: Image.asset(app_images.Forget_pswrd, height: 150),
                ),
                const SizedBox(height: 30),

                Text(
                  AppTexts.otpTitle,
                  style: customBoldText.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  AppTexts.otpSubtitle,
                  style: customBoldText.copyWith(
                    color: AppColors.tertiaryColor,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 30),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (controller.otpError.value.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          controller.otpError.value,
                          style: customBoldText.copyWith(
                            color: AppColors.primaryColor1,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],

                    Pinput(
                      length: 6,
                      controller: controller.otpController,
                      focusNode: controller.otpFocusNode,
                      autofocus: true,
                      pinAnimationType: PinAnimationType.fade,
                      closeKeyboardWhenCompleted: true,
                      showCursor: true,
                      // obscureText: true,
                      // obscuringCharacter: "*",
                      defaultPinTheme: basePinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: submittedPinTheme,
                      errorPinTheme: errorPinTheme,
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
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
                const SizedBox(height: 24),

                global_button(
                  loaderWhite: true,
                  isLoading: controller.isLoading.value,
                  title: "Verify",
                  backgroundColor: AppColors.primaryColor,
                  textColor: Colors.white,
                  onTap: controller.verifyOtp,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Text(
                      AppTexts.resendOtp,
                      style: customBoldText.copyWith(
                        color: AppColors.tertiaryColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(width: 6),

                    controller.isResendEnabled.value
                        ? GestureDetector(
                          onTap: () {
                            controller.startResendTimer();
                            Get.snackbar("OTP", "Resent code to your email");
                          },
                          child: Text(
                            AppTexts.resendNow,
                            style: customBoldText.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        )
                        : Text(
                          "Resend in ${controller.resendSeconds.value}s",
                          style: customBoldText.copyWith(
                            color: AppColors.tertiaryColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
