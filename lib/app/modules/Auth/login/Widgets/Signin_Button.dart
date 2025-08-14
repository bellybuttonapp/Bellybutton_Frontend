import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/themes/Font_style.dart';
import '../../../../core/themes/dimensions.dart';
import '../../../../global_widgets/loader/global_loader.dart';

class Signin_Button extends StatelessWidget {
  final Function()? onTap;
  final bool isLoading;

  const Signin_Button({super.key, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final buttonPadding = EdgeInsets.all(screenWidth * 0.04);
    final buttonMargin = EdgeInsets.symmetric(horizontal: screenWidth * 0.01);
    final buttonBorderRadius = BorderRadius.circular(screenWidth * 0.01);

    return GestureDetector(
      onTap: isLoading ? null : onTap,
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
        child: Center(
          child:
              isLoading
                  ? const Global_Loader(
                    size: 20,
                    color: Colors.black,
                    strokeWidth: 2,
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        app_texts.loginWithGoogle,
                        style: customBoldText.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        app_images.googleicon,
                        height: 20,
                        width: 20,
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
