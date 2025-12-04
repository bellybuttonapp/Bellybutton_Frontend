// ignore_for_file: use_key_in_widget_constructors, annotate_overrides, deprecated_member_use

import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // <-- REQUIRED FOR SCREENSHOT BLOCK
import 'package:photo_view/photo_view.dart';
import '../../../core/utils/themes/font_style.dart';
import '../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../global_widgets/loader/global_loader.dart';
import '../controllers/photo_pre_controller.dart';

class PhotoPreView extends GetView<PhotoPreController> {
  final PhotoPreController controller = Get.put(PhotoPreController());

  PhotoPreView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final width = MediaQuery.of(context).size.width;

    final assets = c.assets;
    final startPage = c.initialIndex;

    final PageController pageController = PageController(
      initialPage: startPage,
    );

    /// ===============================================================
    /// 🔐 Screenshot & Screen Recorder Restriction
    /// ENABLES SAFE MODE ON PAGE OPEN
    /// ===============================================================
    Future.delayed(Duration(milliseconds: 100), () {
      var platform = const MethodChannel("flutter.view_protection");
      platform.invokeMethod("secureModeOn"); // Prevents Screenshot/Recording
    });

    return WillPopScope(
      onWillPop: () async {
        /// Turn OFF restriction when closing
        var platform = const MethodChannel("flutter.view_protection");
        platform.invokeMethod("secureModeOff");
        return true;
      },

      child: Scaffold(
        backgroundColor: Colors.black,

        /// ====================== APP BAR ======================
        appBar: CustomAppBar(
          showBackButton: true,
          showProfileSection: false,
          titleWidget: Obx(
            () => Text(
              "${c.currentIndex.value + 1}/${assets.length}",
              style: customBoldText.copyWith(
                color: Colors.black,
                fontSize: width * 0.05,
              ),
            ),
          ),

          actions: [
            GestureDetector(
              onTap: c.showImageInfo,
              child: Padding(
                padding: EdgeInsets.only(right: width * 0.03),
                child: SvgPicture.asset(
                  AppImages.PHOTO_INFO_ICON,
                  width: width * 0.065,
                  height: width * 0.065,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),

        /// =================== IMAGE VIEWER PAGE ===================
        body: PageView.builder(
          controller: pageController,
          itemCount: assets.length,
          onPageChanged: c.updateIndex,

          itemBuilder: (_, index) {
            final asset = assets[index];

            return FutureBuilder<Uint8List?>(
              future: asset.originBytes,
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Global_Loader(
                      size: 40,
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  );
                }

                return PhotoView(
                  imageProvider: MemoryImage(snapshot.data!),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  heroAttributes: PhotoViewHeroAttributes(tag: asset.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
