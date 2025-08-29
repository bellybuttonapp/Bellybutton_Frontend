// ignore_for_file: deprecated_member_use, annotate_overrides, unrelated_type_equality_checks

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/themes/Font_style.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../global_widgets/Button/global_button.dart';
import '../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../Widgets/login_textfield.dart';
import '../Widgets/Signin_Button.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  final LoginController controller = Get.put(LoginController());
  LoginView({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<LoginController>();

    // 📱 MediaQuery for responsiveness
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

            // 🔒 Logo Section
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

            // 📋 Login Form Section
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
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.loginTitle,
                      style: customBoldText.copyWith(
                        fontSize: screenWidth * 0.06, // responsive title
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // 📧 Email Field
                    Obx(
                      () => login_textfield(
                        controller: controller.emailController,
                        hintText: AppTexts.loginEmail,
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        errorText:
                            controller.emailError.value.isEmpty
                                ? null
                                : controller.emailError.value,
                        onChanged: controller.validateEmail,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // 🔑 Password Field
                    Obx(
                      () => login_textfield(
                        controller: controller.passwordController,
                        hintText: AppTexts.loginPassword,
                        obscureText: controller.isPasswordHidden.value,
                        errorText:
                            controller.passwordError.value.isEmpty
                                ? null
                                : controller.passwordError.value,
                        onChanged: controller.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.tertiaryColor,
                            size: screenWidth * 0.06,
                          ),
                          onPressed: () => controller.isPasswordHidden.toggle(),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // 🔘 Login Button
                    Obx(
                      () => global_button(
                        loaderWhite: true,
                        isLoading: controller.isLoading.value,
                        title: AppTexts.loginTitle,
                        backgroundColor:
                            isDarkMode
                                ? AppTheme.darkTheme.scaffoldBackgroundColor
                                : AppTheme.lightTheme.primaryColor,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            controller.login();
                          }
                        },
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // 🔘 Remember Me & Forgot Password
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
                                  color: AppColors.tertiaryColor,
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

                    // 🔄 OR Divider
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
                    SizedBox(height: screenHeight * 0.04),

                    // 🔘 Google Sign-in Button
                    Obx(
                      () => Signin_Button(
                        isLoading: controller.isGoogleLoading.value,
                        onTap:
                            controller.isGoogleLoading.value
                                ? null
                                : () async {
                                  final connectivityResult =
                                      await Connectivity().checkConnectivity();

                                  if (connectivityResult ==
                                      ConnectivityResult.none) {
                                    showCustomSnackBar(
                                      'No internet connection',
                                      SnackbarState.error,
                                    );
                                    return;
                                  }

                                  await controller.onSigninWithGoogle();
                                },
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // 🔗 Sign-up Redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppTexts.dontHaveAccount,
                          style: customBoldText.copyWith(
                            fontSize: screenWidth * 0.035,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.015),
                        GestureDetector(
                          onTap: controller.navigateToSignup,
                          child: Text(
                            AppTexts.buttonSignup,
                            style: customBoldText.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
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
