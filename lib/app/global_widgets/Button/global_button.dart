import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';

import '../../core/themes/Font_style.dart';
import '../../core/themes/dimensions.dart';

class global_button extends StatelessWidget {
  final Function()? onTap;

  const global_button({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding
    final buttonPadding = EdgeInsets.all(
      screenWidth * 0.04,
    ); // 4% of screen width

    // Responsive margin
    final buttonMargin = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.01,
    ); // 6% of screen width

    // Responsive font size
    final buttonTextSize = screenWidth * 0.045; // 4.5% of screen width

    // Responsive border radius
    final buttonBorderRadius = BorderRadius.circular(
      screenWidth * 0.01,
    ); // 2% of screen width

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: buttonPadding,
        margin: buttonMargin,
        decoration: BoxDecoration(
          color:const Color.fromARGB(255, 17, 48, 88),
          borderRadius: buttonBorderRadius,
        ),
        child: Center(
          child: Text(
           app_texts.loginTitle,
            style: customBoldText.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
