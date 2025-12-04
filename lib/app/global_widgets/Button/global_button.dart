import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:bellybutton/app/core/utils/index.dart';

import '../loader/global_loader.dart';

// ignore: camel_case_types
class global_button extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;
  final bool loaderWhite;

  final bool removeMargin; // NEW → remove button margin when needed

  const global_button({
    super.key,
    required this.onTap,
    required this.title,
    this.backgroundColor = AppColors.primaryColor,
    this.textColor = AppColors.textColor3,
    this.isLoading = false,
    this.loaderWhite = false,
    this.removeMargin = false, // NEW DEFAULT
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.018,
          horizontal: screenWidth * 0.06,
        ),

        // 🔥 margin is removed only when needed
        margin:
            removeMargin
                ? EdgeInsets.zero
                : EdgeInsets.symmetric(horizontal: screenWidth * 0.02),

        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
        ),

        child: Center(
          child:
              isLoading
                  ? SizedBox(
                    height: screenHeight * 0.025,
                    width: screenHeight * 0.025,
                    child: Global_Loader(
                      color:
                          loaderWhite
                              ? AppColors.textColor3
                              : AppColors.primaryColor,
                    ),
                  )
                  : Text(
                    title,
                    style: customBoldText.copyWith(
                      fontSize: screenWidth * 0.038,
                      color: textColor,
                    ),
                  ),
        ),
      ),
    );
  }
}
