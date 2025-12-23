// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppFloatingButton extends StatelessWidget {
  final String? heroTag; // <-- now optional
  final String iconPath;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;
  final double size;
  final double elevation;

  const AppFloatingButton({
    super.key,
    this.heroTag, // <-- optional
    required this.iconPath,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.iconSize = 24,
    this.size = 56,
    this.elevation = 6,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: FloatingActionButton(
        // ⭐ If heroTag is null → disable Hero animation safely
        heroTag: heroTag ?? UniqueKey().toString(),

        elevation: elevation,
        shape: const CircleBorder(),
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        onPressed: onTap,
        child: SvgPicture.asset(
          iconPath,
          width: iconSize,
          height: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
