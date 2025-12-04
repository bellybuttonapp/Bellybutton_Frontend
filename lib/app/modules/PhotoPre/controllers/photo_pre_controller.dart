// ignore_for_file: unnecessary_overrides, curly_braces_in_flow_control_structures

import 'package:bellybutton/app/global_widgets/CustomBottomSheet/CustomBottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../core/constants/app_texts.dart';

/// =================================================
/// 📁 EXTENSION → Converts bytes into KB / MB text
/// Example → 204800 = "200 KB"
/// =================================================
extension FileSize on int {
  String formatBytes() {
    if (this < 1024) return "$this B"; // Bytes
    if (this < 1024 * 1024)
      return "${(this / 1024).toStringAsFixed(1)} KB"; // In KB
    return "${(this / (1024 * 1024)).toStringAsFixed(1)} MB"; // In MB
  }
}

/// =================================================
/// 📌 Photo Preview Controller
/// Handles → Image page navigation, current index tracking,
/// and info bottom sheet details such as resolution, size & date.
/// =================================================
class PhotoPreController extends GetxController {
  late List<AssetEntity> assets; // All selected images (from gallery)
  late int initialIndex; // Starting preview index when opening screen
  var currentIndex = 0.obs; // Tracks the current visible image index

  /// --------------------------------------------------------------------------
  /// 🔥 onInit()
  /// Called immediately when controller is created.
  /// Loads arguments from previous screen → assets + selected starting index.
  /// --------------------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    assets = Get.arguments["assets"]; // Receiving images from previous screen
    initialIndex = Get.arguments["index"]; // Opening image position
    currentIndex.value = initialIndex; // Set current to initial
  }

  /// --------------------------------------------------------------------------
  /// 🔄 updateIndex(int i)
  /// Updates current index when user swipes to next/previous image.
  /// Used by PageView to sync page position with UI indicator.
  /// --------------------------------------------------------------------------
  void updateIndex(int i) {
    currentIndex.value = i;
  }

  /// --------------------------------------------------------------------------
  /// 📄 showImageInfo()
  /// Opens bottom sheet containing:
  /// • Resolution (width × height)
  /// • File size in KB/MB
  /// • Created date/time
  ///
  /// Uses `originBytes` to calculate file size.
  /// --------------------------------------------------------------------------
  Future<void> showImageInfo() async {
    final asset = assets[currentIndex.value]; // Get current image

    final size = await asset.originBytes; // Byte data for size calculation
    final fileSize = size?.length ?? 0; // If null → 0 bytes

    final width = asset.width; // Image width px
    final height = asset.height; // Image height px
    final date = asset.createDateTime; // Taken/created timestamp
    final dateText = DateFormat("dd MMM yyyy, hh:mm a").format(date);

    CustomBottomSheet.show(
      title: AppTexts.PHOTO_DETAILS,
      actions: [
        SheetAction(
          label: AppTexts.RESOLUTION,
          trailing: Text("$width × $height px"),
          onTap: () {},
        ),
        SheetAction(
          label: AppTexts.FILE_SIZE,
          trailing: Text(fileSize.formatBytes()),
          onTap: () {},
        ),
        SheetAction(
          label: AppTexts.CREATED,
          trailing: Text(dateText),
          onTap: () {},
        ),
      ],
    );
  }
}
