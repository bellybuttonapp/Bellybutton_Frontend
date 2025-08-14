import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/themes/Font_style.dart';
import '../../../../core/themes/dimensions.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../global_widgets/Button/global_button.dart';
import '../Widgets/login_textfield.dart';
import '../Widgets/Signin_Button.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({super.key});
  final _formKey = GlobalKey<FormState>(); // <--- define here

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final controller = Get.find<LoginController>(); // manually get controller
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

            SizedBox(height: screenHeight * 0.10),

            // 📋 Login Form Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.05,
              ),
              decoration: const BoxDecoration(
                color: AppColors.textColor3,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app_texts.loginTitle,
                      style: customBoldText.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // 📧 Email Field
                    Obx(
                      () => login_textfield(
                        controller: controller.emailController,
                        hintText: app_texts.loginEmail,
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        errorText: controller.emailError.value,
                        onChanged: controller.validateEmail,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    // 🔑 Password Field
                    Obx(
                      () => login_textfield(
                        controller: controller.passwordController,
                        hintText: app_texts.loginPassword,
                        obscureText: controller.isPasswordHidden.value,
                        errorText: controller.passwordError.value,
                        onChanged: controller.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.tertiaryColor,
                          ),
                          onPressed: () => controller.isPasswordHidden.toggle(),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // 🔘 Login Button
                    Obx(
                      () => global_button(
                        loaderWhite: true, // loader color will be white
                        isLoading: controller.isLoading.value,
                        title: app_texts.loginbutton,
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

                    SizedBox(height: screenHeight * 0.01),

                    // 🔘 Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Row(
                            children: [
                              Transform.scale(
                                scale: 0.8,
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
                                app_texts.rememberMe,
                                style: customBoldText.copyWith(
                                  color: AppColors.tertiaryColor,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap:controller.forget_Paswd,
                          child: Text(
                            app_texts.forgotPassword,
                            style: customBoldText.copyWith(
                              color: AppColors.tertiaryColor,
                              fontSize: Dimensions.fontSizeSmall,
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
                            app_texts.orText,
                            style: customBoldText.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
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
                                : controller.onSigninWithGoogle,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // 🔗 Sign-up Redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          app_texts.dontHaveAccount,
                          style: customBoldText.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        GestureDetector(
                          onTap: controller.navigateToSignup,
                          child: Text(
                            app_texts.buttonSignup,
                            style: customBoldText.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: Dimensions.fontSizeSmall,
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
