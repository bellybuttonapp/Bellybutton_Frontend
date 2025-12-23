// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import '../Button/global_button.dart';
import '../GlobalTextField/GlobalTextField.dart';

class AuthActionForm extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  // First text field
  final String hintText;
  final TextEditingController controller;
  final String? errorText;
  final void Function(String)? onChanged;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  // Optional second text field
  final String? hintText2;
  final TextEditingController? controller2;
  final String? errorText2;
  final void Function(String)? onChanged2;
  final bool obscureText2;
  final TextInputType keyboardType2;
  final Widget? suffixIcon2;

  final VoidCallback onTap;
  final String buttonText;
  final bool isLoading;

  const AuthActionForm({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.hintText,
    required this.controller,
    required this.onTap,
    required this.buttonText,
    this.isLoading = false,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.suffixIcon,
    // Second text field params
    this.hintText2,
    this.controller2,
    this.errorText2,
    this.onChanged2,
    this.obscureText2 = false,
    this.keyboardType2 = TextInputType.text,
    this.suffixIcon2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isDark = theme.brightness == Brightness.dark;

    // 🌙 Adaptive Colors
    final textColor = isDark ? Colors.white : AppColors.textColor;
    final subtitleColor =
        isDark
            ? Colors
                .grey
                .shade400 // softer in dark mode
            : AppColors.tertiaryColor;
    final buttonColor =
        isDark
            ? AppColors.primaryColor.withOpacity(0.85)
            : AppColors.primaryColor;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.05),

            /// Illustration
            Center(
              child: Image.asset(
                imagePath,
                height: screenHeight * 0.2,
                color:
                    isDark
                        ? Colors.white.withOpacity(0.9)
                        : null, // 🌙 tint for dark
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            /// Title
            Text(
              title,
              style: customBoldText.copyWith(
                fontSize: screenWidth * 0.06,
                color: textColor,
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            /// Subtitle
            Text(
              subtitle,
              style: customBoldText.copyWith(
                color: subtitleColor,
                fontSize: screenWidth * 0.04,
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            /// First Text Field
            GlobalTextField(
              controller: controller,
              hintText: hintText,
              obscureText: obscureText,
              keyboardType: keyboardType,
              errorText: errorText,
              onChanged: onChanged,
              suffixIcon: suffixIcon,
            ),

            SizedBox(height: screenHeight * 0.025),

            /// Optional Second Text Field
            if (controller2 != null && hintText2 != null)
              GlobalTextField(
                controller: controller2!,
                hintText: hintText2!,
                obscureText: obscureText2,
                keyboardType: keyboardType2,
                errorText: errorText2,
                onChanged: onChanged2,
                suffixIcon: suffixIcon2,
              ),

            SizedBox(height: screenHeight * 0.04),

            /// Button
            global_button(
              loaderWhite: true,
              isLoading: isLoading,
              title: buttonText,
              backgroundColor: buttonColor,
              textColor: Colors.white,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
