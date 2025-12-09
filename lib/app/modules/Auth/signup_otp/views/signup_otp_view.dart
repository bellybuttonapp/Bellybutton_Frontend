// ignore_for_file: deprecated_member_use, unused_field

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/utils/themes/font_style.dart';
import '../../../../global_widgets/Button/global_button.dart';
import '../controllers/signup_otp_controller.dart';

class SignupOtpView extends GetView<SignupOtpController> {
  final SignupOtpController _signupOtpController = Get.put(
    SignupOtpController(),
  );

  SignupOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // ======= Pin Theme ======= //
    final defaultPinTheme = PinTheme(
      width: size.width * 0.12,
      height: size.width * 0.13,
      textStyle: TextStyle(
        fontSize: size.width * 0.05,
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

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      body: GetBuilder<SignupOtpController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.LOGIN_PNG),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.1),

                    /// 🔒 Lock Icon
                    Container(
                      height: size.width * 0.3,
                      width: size.width * 0.3,
                      decoration: BoxDecoration(
                        color: AppColors.textColor3,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock,
                        size: size.width * 0.15,
                        color: AppColors.textColor,
                      ),
                    ),

                    SizedBox(height: size.height * 0.1),

                    /// White Bottom Card Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                        vertical: size.height * 0.05,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textColor3,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(size.width * 0.08),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Confirm Email",
                            style: customBoldText.copyWith(
                              fontSize: size.width * 0.065,
                            ),
                          ),
                          SizedBox(height: size.height * 0.015),
                          Text(
                            "Enter the verification code we sent to your email.",
                            style: customBoldText.copyWith(
                              fontSize: size.width * 0.04,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(height: size.height * 0.035),

                          /// OTP Field with error
                          Obx(
                            () => Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (controller.otpError.value.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: size.height * 0.015,
                                    ),
                                    child: Text(
                                      controller.otpError.value,
                                      style: customBoldText.copyWith(
                                        color: AppColors.primaryColor1,
                                        fontSize: size.width * 0.035,
                                      ),
                                    ),
                                  ),
                                Pinput(
                                  length: 6,
                                  controller: controller.otpController,
                                  defaultPinTheme: defaultPinTheme,
                                  focusedPinTheme: focusedPinTheme,
                                  showCursor: true,
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  pinAnimationType: PinAnimationType.scale,
                                  onChanged: (val) {
                                    if (controller.otpError.value.isNotEmpty) {
                                      controller.otpError.value = '';
                                    }
                                  },
                                  onCompleted: (_) => controller.verifyOtp(),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: size.height * 0.06),

                          /// Verify Button
                          global_button(
                            loaderWhite: true,
                            title: "Verify",
                            onTap: controller.verifyOtp,
                            isLoading: controller.isLoading.value,
                            backgroundColor: AppColors.primaryColor,
                            textColor: Colors.white,
                          ),

                          SizedBox(height: size.height * 0.028),

                          /// Resend Row
                          /// Resend Row with 30-sec timer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't get the code? ",
                                style: customBoldText.copyWith(
                                  color: AppColors.textColor,
                                ),
                              ),
                              Obx(
                                () => GestureDetector(
                                  onTap:
                                      controller.canResend.value
                                          ? controller.resendOtp
                                          : null,
                                  child:
                                      controller.canResend.value
                                          ? Text(
                                            "Resend",
                                            style: customBoldText.copyWith(
                                              color: AppColors.primaryColor,
                                              fontSize: size.width * 0.04,
                                            ),
                                          )
                                          : Text(
                                            "Resend in ${controller.resendSeconds.value}s",
                                            style: customBoldText.copyWith(
                                              color: Colors.grey,
                                              fontSize: size.width * 0.04,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: size.height * 0.22),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
