import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_images.dart';
import '../loader/global_loader.dart';

/// A cached profile image widget that handles network images with caching,
/// local file images, and shows a placeholder while loading.
class CachedProfileImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? placeholderIconColor;

  const CachedProfileImage({
    super.key,
    this.imageUrl,
    required this.radius,
    this.backgroundColor,
    this.placeholderIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey.shade200;
    final iconColor = placeholderIconColor ?? Colors.grey.shade600;
    final iconSize = radius * 0.7;

    // No image URL provided
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: SvgPicture.asset(
          AppImages.PERSON,
          height: iconSize,
          width: iconSize,
          // ignore: deprecated_member_use
          color: iconColor,
        ),
      );
    }

    final url = imageUrl!.trim();

    // Local file image
    if (!url.startsWith('http')) {
      final file = File(url);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: bgColor,
          backgroundImage: FileImage(file),
        );
      }
      // File doesn't exist, show placeholder
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: SvgPicture.asset(
          AppImages.PERSON,
          height: iconSize,
          width: iconSize,
          // ignore: deprecated_member_use
          color: iconColor,
        ),
      );
    }

    // Network image with caching
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Global_Loader(
          size: iconSize,
          strokeWidth: 2,
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: SvgPicture.asset(
          AppImages.PERSON,
          height: iconSize,
          width: iconSize,
          // ignore: deprecated_member_use
          color: iconColor,
        ),
      ),
    );
  }
}
