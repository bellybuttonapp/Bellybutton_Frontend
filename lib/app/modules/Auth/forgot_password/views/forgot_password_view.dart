// ignore_for_file: annotate_overrides

import 'package:bellybutton/app/global_widgets/GlobalTextField/GlobalTextField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/themes/Font_style.dart';
import '../../../../global_widgets/Button/global_button.dart';
import '../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  final ForgotPasswordController controller = Get.put(
    ForgotPasswordController(),
  );
  ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // MediaQuery for responsive UI
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05), // responsive padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.05),

              /// Illustration
              Center(
                child: Image.asset(
                  app_images.Forget_pswrd,
                  height: screenHeight * 0.2, // responsive image
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              /// Title
              Text(
                AppTexts.forgotPasswordTitle,
                style: customBoldText.copyWith(
                  fontSize: screenWidth * 0.06, // responsive font
                ),
              ),

              SizedBox(height: screenHeight * 0.015),

              /// Subtitle
              Text(
                AppTexts.forgotPasswordSubtitle,
                style: customBoldText.copyWith(
                  color: AppColors.tertiaryColor,
                  fontSize: screenWidth * 0.04, // responsive font
                ),
                textAlign: TextAlign.start,
              ),

              SizedBox(height: screenHeight * 0.04),

              /// Email Input
              Obx(
                () => GlobalTextField(
                  controller: controller.emailController,
                  hintText: AppTexts.loginEmail,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  errorText: controller.emailError.value,
                  onChanged: controller.validateEmail,
                ),
              ),

              SizedBox(height: screenHeight * 0.025),

              /// Send Code Button
              Obx(
                () => global_button(
                  loaderWhite: true,
                  isLoading: controller.isLoading.value,
                  title: "Send code",
                  backgroundColor: AppColors.primaryColor,
                  textColor: Colors.white,
                  onTap: () {
                    controller.sendCode();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
