import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/themes/Font_style.dart';
import '../../core/themes/dimensions.dart';
import '../loader/global_loader.dart';

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

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.04,
          horizontal: screenWidth * 0.06,
        ),
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.01),
        ),
        child: Center(
          child:
              isLoading
                  ? SizedBox(
                    height: Dimensions.fontSizeSmall + 4,
                    width: Dimensions.fontSizeSmall + 4,
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
                      fontSize: Dimensions.fontSizeSmall,
                      color: textColor,
                    ),
                  ),
        ),
      ),
    );
  }
}
