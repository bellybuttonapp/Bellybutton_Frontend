import 'package:bellybutton/app/modules/Auth/forgot_password/views/otp_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/themes/Font_style.dart';
import '../../../../core/themes/dimensions.dart';
import '../../../../global_widgets/Button/global_button.dart';
import '../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../../login/Widgets/login_textfield.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  final ForgotPasswordController controller = Get.put(
    ForgotPasswordController(),
  );
  ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              /// Illustration
              Center(child: Image.asset(app_images.Forget_pswrd, height: 150)),

              const SizedBox(height: 30),

              /// Title
              Text(
                app_texts.forgotPasswordTitle,
                style: customBoldText.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),

              const SizedBox(height: 10),

              /// Subtitle
              Text(
                app_texts.forgotPasswordSubTitle,
                style: customBoldText.copyWith(
                  color: AppColors.tertiaryColor,
                  fontSize: Dimensions.fontSizeSmall,
                ),
                textAlign: TextAlign.start,
              ),

              const SizedBox(height: 30),

              /// Email Input
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

              const SizedBox(height: 20),

              /// Send Code Button
              Obx(
                () => global_button(
                  loaderWhite: true,
                  isLoading: controller.isLoading.value,
                  title: "Send code",
                  backgroundColor: AppColors.primaryColor,
                  textColor: Colors.white,
                  onTap: () {
                    controller.Navigate_to_otp();
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
