// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/themes/Font_style.dart';
import '../Button/global_button.dart';

class EmptyJobsPlaceholder extends StatelessWidget {
  final String? title;
  final String imagePath;
  final String description;
  final RxBool? isLoading;
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const EmptyJobsPlaceholder({
    super.key,
    this.title,
    required this.imagePath,
    required this.description,
    this.isLoading,
    this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Screen size

    return Center(
      child: Transform.translate(
        offset: Offset(0, -size.height * 0.08), // dynamic offset
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              width: size.width * 0.5, // 50% of screen width
              height: size.width * 0.5, // maintain square ratio
            ),

            SizedBox(height: size.height * 0.025),

            if (title != null) ...[
              Text(
                title!,
                style: customBoldText.copyWith(
                  color: AppColors.textColor,
                  fontSize: size.width * 0.05, // responsive text size
                ),
              ),
              SizedBox(height: size.height * 0.015),
            ],

            SizedBox(height: size.height * 0.015),

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
              // SizedBox(
              //   height: size.height * 0.20,
              // ), // only shown if button is shown
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
