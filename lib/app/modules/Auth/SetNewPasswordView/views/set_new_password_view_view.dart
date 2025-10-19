// ignore_for_file: annotate_overrides

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../global_widgets/AuthFormWidget/AuthFormWidget.dart';
import '../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../controllers/set_new_password_view_controller.dart';

class SetNewPasswordView extends GetView<SetNewPasswordViewController> {
  final SetNewPasswordViewController controller = Get.put(
    SetNewPasswordViewController(),
  );
  SetNewPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.textColor3,
      appBar: CustomAppBar(),
      body: GetBuilder<SetNewPasswordViewController>(
        builder: (controller) {
          return Obx(() {
            // if (controller.isDisposed) return SizedBox.shrink();
            return AuthActionForm(
              imagePath: app_images.Forget_pswrd,
              title: AppTexts.setNewPassword,
              subtitle: AppTexts.setNewPasswordSubtitle,

              hintText: AppTexts.newPassword,
              controller: controller.newPasswordController,
              errorText: controller.newPasswordError.value,
              onChanged: controller.validateNewPassword,
              obscureText: controller.isPasswordHidden.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordHidden.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.tertiaryColor,
                  size: screenWidth * 0.06,
                ),
                onPressed: () {
                  controller.isPasswordHidden.toggle();
                },
              ),

              hintText2: AppTexts.confirmPassword,
              controller2: controller.confirmPasswordController,
              errorText2: controller.confirmPasswordError.value,
              onChanged2: controller.validateConfirmPassword,
              // For second field
              obscureText2: controller.isPasswordHidden.value,
              // suffixIcon2: IconButton(
              //   icon: Icon(
              //     controller.isConfirmPasswordHidden.value
              //         ? Icons.visibility_off
              //         : Icons.visibility,
              //     color: AppColors.tertiaryColor,
              //     size: screenWidth * 0.06,
              //   ),
              //   onPressed: () {
              //     controller.isConfirmPasswordHidden.toggle();
              //   },
              // ),
              onTap: controller.confirmNewPassword,
              buttonText: AppTexts.confirmPassword,
              isLoading: controller.isLoading.value,
            );
          });
        },
      ),
    );
  }
}
