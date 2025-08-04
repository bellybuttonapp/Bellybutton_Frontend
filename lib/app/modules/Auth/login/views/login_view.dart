import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final controller = Get.find<LoginController>(); // manually get controller
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 29, 60),
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

            // 📋 Login Form Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.05,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
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
                            color: Colors.grey,
                          ),
                          onPressed: () => controller.isPasswordHidden.toggle(),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // 🔘 Login Button
                    global_button(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          controller.login();
                        }
                      },
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

                    // 🔄 OR Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(thickness: 0.5)),
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
                        const Expanded(child: Divider(thickness: 0.5)),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // 🔘 Google Sign-in Button
                    Signin_Button(onTap: controller.onSigninWithGoogle),

                    SizedBox(height: screenHeight * 0.05),

                    // 🔗 Sign-up Redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          app_texts.dontHaveAccount,
                          style: customBoldText.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        GestureDetector(
                          onTap: controller.navigateToSignup,
                          child: Text(
                            app_texts.buttonSignup,
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
