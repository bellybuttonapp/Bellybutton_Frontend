import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// ignore: camel_case_types
class Global_Loader extends StatelessWidget {
  final double? size; // make nullable
  final Color color;
  final double strokeWidth;

  const Global_Loader({
    super.key,
    this.size, // will calculate from MediaQuery if null
    this.color = AppColors.primaryColor,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    // Background behind spinner
    // ignore: deprecated_member_use
    final bgColor = color.withOpacity(0.15);

    // Responsive size → fallback to 8% of screen width if size not passed
    final loaderSize = size ?? MediaQuery.of(context).size.width * 0.08;

    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: SizedBox(
          height: loaderSize,
          width: loaderSize,
          child: CircularProgressIndicator.adaptive(
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }
}
