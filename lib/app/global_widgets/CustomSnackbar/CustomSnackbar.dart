// ignore_for_file: file_names, deprecated_member_use

import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:bellybutton/app/core/utils/index.dart';

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
  String? subTitle,
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

  Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
    padding: EdgeInsets.zero,
    duration: Duration(seconds: durationSeconds),
    backgroundColor: Colors.transparent,
    barBlur: 0,
    overlayBlur: 0,
    snackStyle: SnackStyle.FLOATING,
    messageText: Container(
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
            width: screenWidth * 0.05,
            height: screenWidth * 0.05,
            colorFilter: ColorFilter.mode(config.textColor, BlendMode.srcIn),
          ),
          SizedBox(width: screenWidth * 0.02),

          // ========== MAIN MESSAGE + Optional Subtitle ==========
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: AppText.headingLg.copyWith(
                    color: config.textColor,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subTitle != null)
                  Text(
                    subTitle,
                    style: AppText.headingLg.copyWith(
                      color: config.textColor.withOpacity(0.8),
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () => Get.closeCurrentSnackbar(),
            child: SvgPicture.asset(
              AppImages.CLOSE,
              width: screenWidth * 0.045,
              height: screenWidth * 0.045,
              colorFilter: ColorFilter.mode(config.textColor, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    ),
    titleText: const SizedBox.shrink(),
  );
}
