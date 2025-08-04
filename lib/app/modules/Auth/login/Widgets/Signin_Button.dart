import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/images.dart';
import '../../../../core/themes/Font_style.dart';
import '../../../../core/themes/dimensions.dart';

class Signin_Button extends StatelessWidget {
  final Function()? onTap;

  const Signin_Button({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final buttonPadding = EdgeInsets.all(screenWidth * 0.04);
    final buttonMargin = EdgeInsets.symmetric(horizontal: screenWidth * 0.01);
    final buttonBorderRadius = BorderRadius.circular(screenWidth * 0.01);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: buttonPadding,
        margin: buttonMargin,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.5,
            color: const Color.fromARGB(255, 6, 29, 60),
          ),
          borderRadius: buttonBorderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max, // Shrinks to fit content
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sign in with Google",
              style: customBoldText.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8), // spacing between text and icon
            SvgPicture.asset(app_images.googleicon, height: 20, width: 20),
          ],
        ),
      ),
    );
  }
}
