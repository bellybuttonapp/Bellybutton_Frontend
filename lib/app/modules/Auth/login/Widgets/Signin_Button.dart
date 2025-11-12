// ignore_for_file: file_names

import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/themes/Font_style.dart';
import '../../../../global_widgets/loader/global_loader.dart';

// ignore: camel_case_types
class Signin_Button extends StatelessWidget {
  final Function()? onTap;
  final bool isLoading;

  const Signin_Button({super.key, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    // ignore: unused_local_variable
    final screenHeight = size.height;

    final buttonPadding = EdgeInsets.all(screenWidth * 0.04);
    final buttonMargin = EdgeInsets.symmetric(horizontal: screenWidth * 0.02);
    final buttonBorderRadius = BorderRadius.circular(screenWidth * 0.02);

    final iconSize = screenWidth * 0.05; // Responsive icon size
    final fontSize = screenWidth * 0.035; // Responsive font size
    final loaderSize = screenWidth * 0.05; // Responsive loader size

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: buttonPadding,
        margin: buttonMargin,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.2,
            color: const Color.fromARGB(255, 6, 29, 60),
          ),
          borderRadius: buttonBorderRadius,
        ),
        child: Center(
          child:
              isLoading
                  ? Global_Loader(
                    size: loaderSize,
                    color: Colors.black,
                    strokeWidth: 2,
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppTexts.LOGIN_WITH_GOOGLE,
                        style: customBoldText.copyWith(
                          fontSize: fontSize,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      SvgPicture.asset(
                        AppImages.GOOGLE_ICON,
                        height: iconSize,
                        width: iconSize,
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
