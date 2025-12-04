// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'package:bellybutton/app/core/utils/index.dart';

class GlobalTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String hintText;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final String? errorText;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final int? maxLines;
  final String? tooltip;
  final int? maxLength; // add this in the class properties

  const GlobalTextField({
    super.key,
    this.controller,
    this.initialValue,
    required this.hintText,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.errorText,
    this.onChanged,
    this.onTap,
    this.maxLines,
    // Inside constructor
    this.maxLength,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            TextFormField(
              controller: controller,
              initialValue: controller == null ? initialValue : null,
              enabled: enabled,
              obscureText: obscureText,
              obscuringCharacter: '*',
              readOnly: readOnly,
              keyboardType: keyboardType,
              validator: validator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: onChanged,
              onTap: onTap,
              maxLines: maxLines ?? 1,

              // Inside TextFormField
              maxLength: maxLength,
              //This limits input but hides the counter.
              buildCounter: (
                _, {
                required currentLength,
                maxLength,
                required isFocused,
              }) {
                if (currentLength == maxLength) {
                  return Text(
                    '$currentLength / $maxLength',
                    style: TextStyle(
                      color: AppColors.primaryColor1,
                      fontSize: screenWidth * 0.03,
                    ),
                  );
                } else {
                  return null; // hide counter until max is reached
                }
              },
              style: customBoldText.copyWith(
                fontSize: screenWidth * 0.035,
                color: AppColors.tertiaryColor,
              ),
              decoration: InputDecoration(
                helperText: tooltip,
                hintText: hintText,
                hintStyle: customBoldText.copyWith(
                  color: AppColors.tertiaryColor,
                  fontSize: screenWidth * 0.035,
                ),
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.018,
                  horizontal: screenWidth * 0.035,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.015),
                  borderSide: const BorderSide(
                    color: AppColors.textColor3,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.015),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 241, 240, 240),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.015),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
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
                color: AppColors.primaryColor1,
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
      ],
    );
  }
}
