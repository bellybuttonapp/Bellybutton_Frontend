// ignore_for_file: annotate_overrides

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/AuthFormWidget/AuthFormWidget.dart';
import '../../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  final ResetPasswordController controller = Get.put(ResetPasswordController());
  ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textColor3, // <-- set your bg color here
      appBar: CustomAppBar(),
      body: Obx(
        () => AuthActionForm(
          imagePath: AppImages.FORGET_PSWRD,
          title: AppTexts.RESET_PASSWORD,
          subtitle: AppTexts.RESET_PASSWORD_SUBTITLE,
          hintText: AppTexts.LOGIN_EMAIL,
          controller: controller.emailController,
          errorText: controller.emailError.value,
          onChanged: controller.validateEmail,
          onTap: controller.sendResetLink,
          buttonText: AppTexts.SEND_CODE,
          isLoading: controller.isLoading.value,
          keyboardType: TextInputType.emailAddress,
        ),
      ),
    );
  }
}
