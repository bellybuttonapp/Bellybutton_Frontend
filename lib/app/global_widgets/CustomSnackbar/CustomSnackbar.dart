// ignore_for_file: file_names

import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../core/themes/Font_style.dart';

enum SnackbarState { error, warning, success, pending, other }

class SnackbarConfig {
  final Color backgroundColor;
  final Color textColor;
  final String iconPath;

  SnackbarConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.iconPath,
  });
}

void showCustomSnackBar(
  String message,
  SnackbarState state, {
  int durationSeconds = 4,
}) {
  final context = Get.context!;
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  final configs = {
    SnackbarState.error: SnackbarConfig(
      backgroundColor: Colors.red.shade100,
      textColor: Colors.red.shade900,
      iconPath: AppImages.ERROR,
    ),
    SnackbarState.warning: SnackbarConfig(
      backgroundColor: Colors.orange.shade100,
      textColor: Colors.orange.shade900,
      iconPath: AppImages.WARNING,
    ),
    SnackbarState.success: SnackbarConfig(
      backgroundColor: Colors.green.shade100,
      textColor: Colors.green.shade900,
      iconPath: AppImages.SUCCESS,
    ),
    SnackbarState.pending: SnackbarConfig(
      backgroundColor: Colors.grey.shade800,
      textColor: Colors.white,
      iconPath: AppImages.WARNING,
    ),
    SnackbarState.other: SnackbarConfig(
      backgroundColor: Colors.blue.shade100,
      textColor: Colors.blue.shade900,
      iconPath: AppImages.SUCCESS,
    ),
  };

  final config = configs[state]!;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      padding: EdgeInsets.zero,
      duration: Duration(seconds: durationSeconds),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      content: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03, // responsive margin
          vertical: screenHeight * 0.008,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenHeight * 0.012,
        ),
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              config.iconPath,
              width: screenWidth * 0.05, // responsive size
              height: screenWidth * 0.05,
              colorFilter: ColorFilter.mode(config.textColor, BlendMode.srcIn),
            ),
            SizedBox(width: screenWidth * 0.02),
            Expanded(
              child: Text(
                message,
                style: customBoldText.copyWith(
                  color: config.textColor,
                  fontSize: screenWidth * 0.035, // responsive font
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: SvgPicture.asset(
                AppImages.CLOSE,
                width: screenWidth * 0.045,
                height: screenWidth * 0.045,
                colorFilter: ColorFilter.mode(
                  config.textColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
