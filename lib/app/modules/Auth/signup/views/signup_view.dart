// ignore_for_file: deprecated_member_use

import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import '../../../../global_widgets/Button/global_button.dart';
import '../../login/Widgets/Signin_Button.dart';
import '../../login/controllers/login_controller.dart';
import '../Widgets/Signup_textfield.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  SignupView({super.key});
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final SignupController controller = Get.find<SignupController>();
    final LoginController loginController = Get.find<LoginController>();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(), // No bounce effect
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
                SizedBox(height: screenHeight * 0.1),

                // Logo
                Container(
                  height: screenWidth * 0.3,
                  width: screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: AppColors.textColor3,
                    borderRadius: BorderRadius.circular(screenWidth * 0.5),
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
                    size: screenWidth * 0.15,
                    color: AppColors.textColor,
                  ),
                ),

                SizedBox(height: screenHeight * 0.1),

                // Form Container
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: screenHeight * 0.05,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textColor3,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(screenWidth * 0.08),
                    ),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTexts.SIGNUP_TITLE,
                          style: customBoldText.copyWith(
                            fontSize: screenWidth * 0.06,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.01),

                        // Name
                        Obx(
                          () => Signup_textfield(
                            controller: controller.nameController,
                            hintText: AppTexts.SIGNUP_NAME,
                            obscureText: false,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            errorText:
                                controller.nameError.value?.isEmpty ?? true
                                    ? null
                                    : controller.nameError.value,
                            onChanged: controller.validateName,
                          ),
                        ),

                        // Email
                        Obx(
                          () => Signup_textfield(
                            controller: controller.emailController,
                            hintText: AppTexts.SIGNUP_EMAIL,
                            obscureText: false,
                            keyboardType: TextInputType.emailAddress,
                            errorText:
                                controller.emailError.value?.isEmpty ?? true
                                    ? null
                                    : controller.emailError.value,
                            onChanged: controller.validateEmail,
                          ),
                        ),

                        // Mobile with Country Picker
                        Obx(
                          () => Signup_textfield(
                            controller: controller.mobileController,
                            hintText: AppTexts.SIGNUP_MOBILE,
                            keyboardType: TextInputType.phone,
                            obscureText: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(15),
                            ],
                            prefixIcon: GestureDetector(
                              onTap: () => controller.showCountrySheet(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      controller.selectedCountry.value.flagEmoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "+${controller.selectedCountry.value.phoneCode}",
                                      style: customBoldText.copyWith(
                                        fontSize: screenWidth * 0.04,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                            onChanged: controller.validateMobile,
                            errorText:
                                controller.mobileError.value?.isEmpty ?? true
                                    ? null
                                    : controller.mobileError.value,
                          ),
                        ),
                        // Password
                        Obx(
                          () => Signup_textfield(
                            controller: controller.passwordController,
                            hintText: AppTexts.SIGNUP_PASSWORD,
                            obscureText: controller.isPasswordHidden.value,
                            errorText:
                                controller.passwordError.value?.isEmpty ?? true
                                    ? null
                                    : controller.passwordError.value,
                            keyboardType: TextInputType.visiblePassword,
                            onChanged: controller.validatePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordHidden.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.tertiaryColor,
                              ),
                              onPressed: controller.isPasswordHidden.toggle,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        // Signup Button
                        Obx(
                          () => global_button(
                            loaderWhite: true,
                            isLoading: controller.isLoading.value,
                            title: AppTexts.SIGNUP_BUTTON,
                            backgroundColor:
                                isDarkMode
                                    ? AppTheme.darkTheme.scaffoldBackgroundColor
                                    : AppTheme.lightTheme.primaryColor,
                            onTap:
                                controller.isLoading.value
                                    ? null
                                    : controller.signup,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        // OR Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: AppColors.tertiaryColor,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                              ),
                              child: Text(
                                AppTexts.OR_TEXT,
                                style: customBoldText.copyWith(
                                  fontSize: screenWidth * 0.035,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: AppColors.tertiaryColor,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        // Google Sign-in
                        Obx(
                          () => Signin_Button(
                            isLoading: loginController.isGoogleLoading.value,
                            onTap:
                                loginController.isGoogleLoading.value
                                    ? null
                                    : loginController.onSigninWithGoogle,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Already have account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppTexts.ALREADY_HAVE_ACCOUNT,
                              style: customBoldText.copyWith(
                                fontSize: screenWidth * 0.035,
                                color: AppColors.textColor,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.01),
                            GestureDetector(
                              onTap: controller.navigateToLogin,
                              child: Text(
                                AppTexts.BUTTON_LOGIN,
                                style: customBoldText.copyWith(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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