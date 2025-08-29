import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/themes/Font_style.dart';
import '../loader/global_loader.dart';

// ignore: camel_case_types
class global_button extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;
  final bool loaderWhite; // Flag to switch loader color

  const global_button({
    super.key,
    required this.onTap,
    required this.title,
    this.backgroundColor = AppColors.primaryColor,
    this.textColor = AppColors.textColor3,
    this.isLoading = false,
    this.loaderWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.018, // ✅ responsive vertical padding
          horizontal: screenWidth * 0.06, // ✅ responsive horizontal padding
        ),
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            screenWidth * 0.02,
          ), // ✅ responsive radius
        ),
        child: Center(
          child:
              isLoading
                  ? SizedBox(
                    height: screenHeight * 0.025, // ✅ responsive loader size
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
                      fontSize: screenWidth * 0.038, // ✅ responsive font size
                      color: textColor,
                    ),
                  ),
        ),
      ),
    );
  }
}
