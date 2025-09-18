// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/themes/Font_style.dart';
import '../Button/global_button.dart';

class EmptyJobsPlaceholder extends StatelessWidget {
  final String? title;
  final String? imagePath; // Made nullable
  final String description;
  final RxBool? isLoading;
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const EmptyJobsPlaceholder({
    super.key,
    this.title,
    this.imagePath, // Now optional
    required this.description,
    this.isLoading,
    this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Only show image if imagePath is provided
            if (imagePath != null) ...[
              Image.asset(
                imagePath!,
                width: size.width * 0.5,
                height: size.height * 0.3,
                fit: BoxFit.contain,
              ),
              SizedBox(height: size.height * 0.025),
            ],

            if (title != null) ...[
              Text(
                title!,
                style: customBoldText.copyWith(
                  color: AppColors.textColor,
                  fontSize: size.width * 0.05,
                ),
              ),
              SizedBox(height: size.height * 0.015),
            ],

            Text(
              description,
              textAlign: TextAlign.center,
              style: customBoldText.copyWith(
                color: AppColors.textColor2,
                fontSize: size.width * 0.04,
              ),
            ),

            if (buttonText != null &&
                onButtonTap != null &&
                isLoading != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: size.height * 0.03,
                ),
                child: Obx(
                  () => global_button(
                    loaderWhite: true,
                    isLoading: isLoading!.value,
                    title: buttonText!,
                    backgroundColor: AppColors.primaryColor,
                    textColor: AppColors.textColor3,
                    onTap: onButtonTap!,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
