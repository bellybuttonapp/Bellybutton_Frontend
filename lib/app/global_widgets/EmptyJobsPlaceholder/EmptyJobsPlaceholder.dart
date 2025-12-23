// ignore_for_file: file_names, unnecessary_underscores

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 👈 ADD THIS
import '../../core/constants/app_colors.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import '../Button/global_button.dart';

class EmptyJobsPlaceholder extends StatelessWidget {
  final String? title;
  final String? imagePath;
  final String description;
  final RxBool? isLoading;
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const EmptyJobsPlaceholder({
    super.key,
    this.title,
    this.imagePath,
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
            if (imagePath != null) ...[
              _buildImage(size),
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

  Widget _buildImage(Size size) {
    // NETWORK
    if (imagePath!.startsWith("http")) {
      return Image.network(
        imagePath!,
        width: size.width * 0.5,
        height: size.height * 0.3,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
      );
    }

    // FILE
    if (File(imagePath!).existsSync()) {
      return Image.file(
        File(imagePath!),
        width: size.width * 0.5,
        height: size.height * 0.3,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
      );
    }

    // SVG ASSET
    if (imagePath!.toLowerCase().endsWith(".svg")) {
      return SvgPicture.asset(
        imagePath!,
        width: size.width * 0.5,
        height: size.height * 0.3,
        fit: BoxFit.contain,
      );
    }

    // NORMAL IMAGE ASSET
    return Image.asset(
      imagePath!,
      width: size.width * 0.5,
      height: size.height * 0.3,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
    );
  }
}
