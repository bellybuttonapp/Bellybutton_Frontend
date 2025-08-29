// ignore_for_file: file_names

import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../core/themes/dimensions.dart';

class ImageLoader extends StatelessWidget {
  const ImageLoader({
    super.key,
    required this.imageurl,
    this.width = 50,
    this.height = 50,
  });
  final String imageurl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return imageurl.toString().trim().isNotEmpty
        ? CachedNetworkImage(
          imageUrl:
              imageurl.contains('//')
                  ? imageurl
                  : imageurl.replaceFirst(':', ':/'),
          width: width,
          height: height,
          imageBuilder:
              (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Dimensions.RADIUS_DEFAULT,
                  ),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          errorWidget:
              (context, url, error) => ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
                child: SvgPicture.asset(app_images.check_icon),
              ),
          placeholder:
              (context, url) => const SizedBox(
                height: 15,
                width: 15,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              ),
        )
        : const SizedBox();
  }
}
