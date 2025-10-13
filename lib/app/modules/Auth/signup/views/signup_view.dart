// ignore_for_file: deprecated_member_use

import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/themes/Font_style.dart';
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

    // 📱 MediaQuery for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.primaryColor,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.2),

            // 🔒 Logo
            Container(
              height: screenWidth * 0.3,
              width: screenWidth * 0.3,
              decoration: BoxDecoration(
                color: AppColors.textColor3,
                borderRadius: BorderRadius.circular(100),
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

            // 📋 Form Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.05,
              ),
              decoration: const BoxDecoration(
                color: AppColors.textColor3,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(35),
                  topLeft: Radius.circular(35),
                ),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      AppTexts.signupTitle,
                      style: customBoldText.copyWith(
                        fontSize: screenWidth * 0.06, // responsive title
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // 📝 Name Field
                    Obx(
                      () => Signup_textfield(
                        controller: controller.nameController,
                        hintText: AppTexts.signupName,
                        obscureText: false,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words, // ✅ added
                        errorText: controller.nameError.value,
                        onChanged: controller.validateName,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    // 📧 Email Field
                    Obx(
                      () => Signup_textfield(
                        controller: controller.emailController,
                        hintText: AppTexts.signupEmail,
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization:
                            TextCapitalization
                                .none, // Email usually stay as typed
                        errorText: controller.emailError.value,
                        onChanged: controller.validateEmail,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    // 🔑 Password Field
                    Obx(
                      () => Signup_textfield(
                        controller: controller.passwordController,
                        hintText: AppTexts.signupPassword,
                        obscureText: controller.isPasswordHidden.value,
                        errorText: controller.passwordError.value,
                        textCapitalization:
                            TextCapitalization
                                .none, // passwords usually stay as typed
                        keyboardType: TextInputType.visiblePassword, // ✅ added
                        onChanged: controller.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.tertiaryColor,
                          ),
                          onPressed: () {
                            controller.isPasswordHidden.toggle();
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // 🔘 Signup Button
                    Obx(
                      () => global_button(
                        loaderWhite: true,
                        isLoading: controller.isLoading.value,
                        onTap: () {
                          if (formKey.currentState!.validate() &&
                              !controller.isLoading.value) {
                            controller.signup();
                          }
                        },
                        title: AppTexts.signupButton,
                        backgroundColor:
                            isDarkMode
                                ? AppTheme.darkTheme.scaffoldBackgroundColor
                                : AppTheme.lightTheme.primaryColor,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // ✅ Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Row(
                            children: [
                              Transform.scale(
                                scale:
                                    screenWidth * 0.0028 + 0.01, // responsive
                                child: Checkbox(
                                  value: controller.rememberMe.value,
                                  onChanged: (value) {
                                    controller.rememberMe.value =
                                        value ?? false;
                                  },
                                  activeColor: AppColors.primaryColor,
                                  checkColor: AppColors.textColor3,
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              Text(
                                AppTexts.rememberMe,
                                style: customBoldText.copyWith(
                                  color: Colors.grey[500],
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.forgetPassword,
                          child: Text(
                            AppTexts.forgotPassword,
                            style: customBoldText.copyWith(
                              color: AppColors.tertiaryColor,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // 🔄 Divider OR
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
                            AppTexts.orText,
                            style: customBoldText.copyWith(
                              fontSize: screenWidth * 0.035,
                              color: Colors.black,
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

                    SizedBox(height: screenHeight * 0.04),

                    // 🔘 Google Sign-in Button
                    Obx(
                      () => Signin_Button(
                        isLoading: loginController.isGoogleLoading.value,
                        onTap:
                            loginController.isGoogleLoading.value
                                ? null
                                : loginController.onSigninWithGoogle,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // 🔗 Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppTexts.AlreadyHaveAccount,
                          style: customBoldText.copyWith(
                            fontSize: screenWidth * 0.035,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        GestureDetector(
                          onTap: controller.navigateToLogin,
                          child: Text(
                            AppTexts.buttonLogin,
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
    );
  }
}
