import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/themes/Font_style.dart';
import '../Button/global_button.dart';
import '../GlobalTextField/GlobalTextField.dart';

class AuthActionForm extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String hintText;
  final TextEditingController controller;
  final String? errorText;
  final void Function(String)? onChanged;
  final VoidCallback onTap;
  final String buttonText;
  final bool isLoading;
  final TextInputType keyboardType;
  final bool obscureText;

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
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.05),

            /// Illustration
            Center(child: Image.asset(imagePath, height: screenHeight * 0.2)),

            SizedBox(height: screenHeight * 0.04),

            /// Title
            Text(
              title,
              style: customBoldText.copyWith(fontSize: screenWidth * 0.06),
            ),

            SizedBox(height: screenHeight * 0.015),

            /// Subtitle
            Text(
              subtitle,
              style: customBoldText.copyWith(
                color: AppColors.tertiaryColor,
                fontSize: screenWidth * 0.04,
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            /// Text Field
            GlobalTextField(
              controller: controller,
              hintText: hintText,
              obscureText: obscureText,
              keyboardType: keyboardType,
              errorText: errorText,
              onChanged: onChanged,
            ),

            SizedBox(height: screenHeight * 0.04),

            /// Button
            global_button(
              loaderWhite: true,
              isLoading: isLoading,
              title: buttonText,
              backgroundColor: AppColors.primaryColor,
              textColor: Colors.white,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
