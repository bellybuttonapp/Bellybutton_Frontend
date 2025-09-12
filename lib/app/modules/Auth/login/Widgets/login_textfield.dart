// ignore_for_file: camel_case_types

import 'package:bellybutton/app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/Font_style.dart';

class login_textfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final String? errorText;
  final void Function(String)? onChanged;

  const login_textfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width & height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: screenHeight * 0.02), // dynamic spacing
            TextFormField(
              style: customBoldText.copyWith(
                color: AppColors.textColor,
                fontSize: screenWidth * 0.035, // responsive font size
              ),
              controller: controller,
              obscureText: obscureText,
              obscuringCharacter: '*',
              keyboardType: keyboardType,
              validator: validator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintStyle: customBoldText.copyWith(
                  color: AppColors.tertiaryColor,
                  fontSize: screenWidth * 0.035, // responsive font size
                ),
                hintText: hintText,
                suffixIcon: suffixIcon,
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.018,
                  horizontal: screenWidth * 0.035,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.015),
                  borderSide: const BorderSide(
                    color: AppColors.tertiaryColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.015),
                  borderSide: BorderSide(
                    color: AppColors.disabledColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.015),
                  borderSide: BorderSide(
                    color: AppColors.tertiaryColor,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  borderSide: const BorderSide(
                    color: AppColors.tertiaryColor,
                    width: 1.1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  borderSide: const BorderSide(
                    color: AppColors.tertiaryColor,
                    width: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (errorText != null && errorText!.isNotEmpty)
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              errorText!,
              style: customBoldText.copyWith(
                color: AppColors.primaryColor1,
                fontSize: screenWidth * 0.03, // responsive error font size
              ),
            ),
          ),
      ],
    );
  }
}
