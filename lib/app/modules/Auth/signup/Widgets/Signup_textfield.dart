import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/themes/Font_style.dart';
import '../../../../core/themes/dimensions.dart';

class Signup_textfield extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String hintText;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final String? errorText;
  final void Function(String)? onChanged;

  const Signup_textfield({
    super.key,
    this.controller,
    this.initialValue,
    required this.hintText,
    required this.obscureText,
    this.enabled = true,
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
              controller: controller,
              initialValue: controller == null ? initialValue : null,
              enabled: enabled,
              obscureText: obscureText,
              obscuringCharacter: '*',
              keyboardType: keyboardType,
              validator: validator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: onChanged,
              style: customBoldText.copyWith(
                // This styles the initialValue text too
                fontSize: Dimensions.fontSizeSmall,
                color: AppColors.tertiaryColor,
              ),
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
                    color: AppColors.textColor3,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 241, 240, 240),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.1),
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
                color: Colors.red,
                fontSize: Dimensions.fontSizeExtraSmall,
              ),
            ),
          ),
      ],
    );
  }
}
