import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/themes/Font_style.dart';
import '../../../../core/themes/dimensions.dart';
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

    // final controller = Get.find<SignupController>(); // manually get controller
    final SignupController controller = Get.find<SignupController>();
    final LoginController loginController = Get.find<LoginController>();

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

            // Logo
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

            // Form Container
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
                    Text(
                      app_texts.signupTitle,
                      style: customBoldText.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                    Obx(
                      () => Signup_textfield(
                        controller: controller.nameController,
                        hintText: app_texts.signupName,
                        obscureText: false,
                        keyboardType: TextInputType.name,
                        errorText: controller.nameError.value,
                        onChanged: controller.validatename,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Obx(
                      () => Signup_textfield(
                        controller: controller.emailController,
                        hintText: app_texts.signupEmail,
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        errorText: controller.emailError.value,
                        onChanged: controller.validateEmail,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Obx(
                      () => Signup_textfield(
                        controller: controller.passwordController,
                        hintText: app_texts.signupPassword,
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
                          onPressed: () {
                            controller.isPasswordHidden.toggle();
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    Obx(
                      () => global_button(
                        loaderWhite: true,
                        isLoading:
                            controller.isLoading.value, // pass isLoading here
                        onTap: () {
                          if (formKey.currentState!.validate() &&
                              !controller.isLoading.value) {
                            controller.signup();
                          }
                        },
                        title: app_texts.signupbutton,
                        backgroundColor:
                            isDarkMode
                                ? AppTheme.darkTheme.scaffoldBackgroundColor
                                : AppTheme.lightTheme.primaryColor,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.01),

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
                                  color: Colors.grey[500],
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.forget_Paswd,
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          app_texts.alreadyHaveAccount,
                          style: customBoldText.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        GestureDetector(
                          onTap: controller.navigateToLogin,
                          child: Text(
                            app_texts.buttonLogin,
                            style: customBoldText.copyWith(
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
