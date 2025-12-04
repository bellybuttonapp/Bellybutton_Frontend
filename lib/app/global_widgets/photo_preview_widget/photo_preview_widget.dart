// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:screen_protector/screen_protector.dart'; // ⬅️ added
import '../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../../core/utils/themes/font_style.dart';
import '../../core/constants/app_images.dart';
import '../loader/global_loader.dart';

// 🔥 Converted to StatefulWidget for screenshot control
class ReusablePhotoPreview extends StatefulWidget {
  final List images;
  final bool isAsset;
  final bool isNetwork;
  final int initialIndex;
  final List<Uint8List>? preloadedBytes;
  final VoidCallback? onInfoTap;
  final bool enableInfoButton;

  const ReusablePhotoPreview({
    required this.images,
    this.isAsset = false,
    this.isNetwork = false,
    this.initialIndex = 0,
    this.onInfoTap,
    this.enableInfoButton = false,
    this.preloadedBytes,
  });

  @override
  State<ReusablePhotoPreview> createState() => _ReusablePhotoPreviewState();
}

class _ReusablePhotoPreviewState extends State<ReusablePhotoPreview> {
  RxInt index = 0.obs;

  @override
  void initState() {
    super.initState();
    index.value = widget.initialIndex;

    /// ⛔ Disable screenshot only inside this screen
    ScreenProtector.preventScreenshotOn();
  }

  @override
  void dispose() {
    /// 🔓 Enable screenshot again when exiting
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final controller = PageController(initialPage: widget.initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        showBackButton: true,
        showProfileSection: false,
        titleWidget: Obx(
          () => Text(
            "${index.value + 1}/${widget.images.length}",
            style: customBoldText.copyWith(
              color: Colors.black,
              fontSize: width * 0.045,
            ),
          ),
        ),
        actions:
            widget.enableInfoButton && widget.onInfoTap != null
                ? [
                  IconButton(
                    icon: SvgPicture.asset(
                      AppImages.PHOTO_INFO_ICON,
                      color: Colors.white,
                      width: width * 0.06,
                      height: width * 0.06,
                    ),
                    onPressed: widget.onInfoTap,
                  ),
                ]
                : [],
      ),

      body: PageView.builder(
        controller: controller,
        onPageChanged: (i) => index(i),
        itemCount: widget.images.length,
        itemBuilder: (_, i) => _buildViewer(i, context),
      ),
    );
  }

  Widget _buildViewer(int i, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final tag = "img-$i";

    if (widget.preloadedBytes != null) {
      return _viewer(MemoryImage(widget.preloadedBytes![i]), tag);
    }

    if (widget.isNetwork) {
      return _viewer(CachedNetworkImageProvider(widget.images[i]), tag);
    }

    if (widget.isAsset) {
      return FutureBuilder(
        future: (widget.images[i] as AssetEntity).originBytes,
        builder: (_, snap) {
          if (!snap.hasData) {
            return Center(
              child: Global_Loader(size: width * 0.10, color: Colors.white),
            );
          }
          return _viewer(MemoryImage(snap.data!), tag);
        },
      );
    }

    return _viewer(MemoryImage(widget.images[i]), tag);
  }

  Widget _viewer(ImageProvider img, String tag) => PhotoView(
    imageProvider: img,
    heroAttributes: PhotoViewHeroAttributes(tag: tag),
    minScale: PhotoViewComputedScale.contained,
    maxScale: PhotoViewComputedScale.covered * 3,
    backgroundDecoration: const BoxDecoration(color: Colors.black),
    enableRotation: true,
    tightMode: true,
  );
}
