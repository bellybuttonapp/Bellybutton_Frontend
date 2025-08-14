import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class Global_Loader extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const Global_Loader({
    super.key,
    this.size = 30.0,
    this.color = AppColors.primaryColor, // default color
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    // Background behind spinner
    final bgColor = color.withOpacity(0.15);

    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: SizedBox(
          height: size,
          width: size,
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
