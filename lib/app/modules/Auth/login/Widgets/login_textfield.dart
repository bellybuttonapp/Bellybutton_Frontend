import 'package:bellybutton/app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/Font_style.dart';
import '../../../../core/themes/dimensions.dart';

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
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 18), // Reserve space for error
            TextFormField(
              style: customBoldText.copyWith(
                color: AppColors.textColor,
                fontSize: Dimensions.fontSizeSmall,
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
                  fontSize: Dimensions.fontSizeSmall,
                ),
                hintText: hintText,
                suffixIcon: suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(
                    color: AppColors.tertiaryColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: AppColors.disabledColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: AppColors.tertiaryColor,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.tertiaryColor,
                    width: 1.1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
                fontSize: Dimensions.fontSizeExtraSmall,
              ),
            ),
          ),
      ],
    );
  }
}
