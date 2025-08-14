import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../core/themes/Font_style.dart';
import '../../../../core/themes/dimensions.dart';
import '../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: app_texts.ForgetPswd),
      body: Center(
        child: Text(
          app_texts.Working,
          style: customBoldText.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
      ),
    );
  }
}
