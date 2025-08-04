import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/themes/Font_style.dart';
import '../../../../core/themes/dimensions.dart';
import '../../../../global_widgets/Button/global_button.dart';
import '../../login/Widgets/Signin_Button.dart';
import '../../login/Widgets/login_textfield.dart';
import '../controllers/signup_controller.dart';
import '../../login/views/login_view.dart';

class SignupView extends GetView<SignupController> {
  SignupView({super.key});
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupController>(); // manually get controller
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 29, 60),
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
                color: Colors.white,
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
                color: const Color.fromARGB(255, 6, 29, 60),
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
                color: Colors.white,
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
                      () => login_textfield(
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
                      () => login_textfield(
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
                      () => login_textfield(
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
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            controller.isPasswordHidden.toggle();
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    global_button(
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          controller.signup();
                        }
                      },
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
                                  activeColor: Colors.blue,
                                  checkColor: Colors.grey[500],
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
                        Text(
                          app_texts.forgotPassword,
                          style: customBoldText.copyWith(
                            color: Colors.grey[500],
                            fontSize: Dimensions.fontSizeSmall,
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
                            color: Colors.grey[400],
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
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    Signin_Button(onTap: controller.Signin_Button),

                    SizedBox(height: screenHeight * 0.05),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          app_texts.alreadyHaveAccount,
                          style: customBoldText.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        GestureDetector(
                          onTap: controller.navigateToLogin,
                          child: Text(
                            app_texts.buttonLogin,
                            style: customBoldText.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: const Color.fromARGB(255, 6, 29, 60),
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
