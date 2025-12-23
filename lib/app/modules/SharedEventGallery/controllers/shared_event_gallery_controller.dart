// ignore_for_file: avoid_print, deprecated_member_use, depend_on_referenced_packages

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../api/PublicApiService.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../core/utils/storage/preference.dart';
import '../../../database/models/InvitedEventModel.dart';
import '../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../global_widgets/Shimmers/MediaInfoShimmer.dart';
import '../../../global_widgets/CustomBottomSheet/CustomBottomsheet.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/themes/font_style.dart';

class SharedEventGalleryController extends GetxController {
  // ------------------------------------------------------
  // 📌 EVENT & PERMISSION DATA
  // ------------------------------------------------------
  late InvitedEventModel event;
  RxString permission = "view-only".obs;

  /// Can user sync/download photos?
  bool get canSync => permission.value == "view-sync";

  /// Permission display text
  String get permissionText =>
      canSync ? AppTexts.VIEW_AND_SYNC : AppTexts.VIEW_ONLY;

  // ------------------------------------------------------
  // 📌 GALLERY CONTROL VARIABLES
  // ------------------------------------------------------
  RxBool isLoading = true.obs;
  RxBool enableOK = false.obs;
  RxInt savedCount = 0.obs;
  RxInt totalToSave = 0.obs;

  // ------------------------------------------------------
  // 📷 PHOTOS DATA
  // ------------------------------------------------------
  late String albumName;
  RxList<String> photos = <String>[].obs;
  RxList<Map<String, dynamic>> photoData = <Map<String, dynamic>>[].obs;

  // ------------------------------------------------------
  // 📷 MEDIA INFO VARIABLES
  // ------------------------------------------------------
  RxBool isMediaInfoLoading = false.obs;
  Rx<Map<String, dynamic>> currentMediaInfo = Rx<Map<String, dynamic>>({});

  // ------------------------------------------------------
  // 🖼 PAGINATION
  // ------------------------------------------------------
  int batchSize = 100;
  int loadedCount = 0;

  @override
  void onInit() {
    super.onInit();

    // Get arguments: { event: InvitedEventModel, permission: String }
    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      event = args["event"] as InvitedEventModel;
      permission.value = args["permission"] ?? "view-only";
    } else {
      throw "Invalid arguments passed to SharedEventGalleryController";
    }

    albumName = "SharedGallery_${event.title.replaceAll(" ", "_")}";

    print("📌 SharedEventGallery opened");
    print("📌 Event: ${event.title}");
    print("📌 Permission: ${permission.value}");

    fetchPhotos();
  }

  // ------------------------------------------------------
  // 🖼 FETCH EVENT PHOTOS
  // ------------------------------------------------------
  Future<void> fetchPhotos({bool loadMore = false}) async {
    if (!loadMore) {
      isLoading.value = true;
    }

    try {
      final result = await PublicApiService().fetchEventPhotos(event.eventId);

      if (result["data"] == null) {
        isLoading.value = false;
        return;
      }

      List<Map<String, dynamic>> allData = (result["data"] as List)
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      List<String> all =
          allData.map<String>((e) => e["fileUrl"].toString()).toList();

      if (!loadMore) {
        photos.assignAll(all.take(batchSize).toList());
        photoData.assignAll(allData.take(batchSize).toList());
        loadedCount = photos.length;
      } else {
        int next = loadedCount + batchSize;
        if (next > all.length) next = all.length;

        photos.addAll(all.sublist(loadedCount, next));
        photoData.addAll(allData.sublist(loadedCount, next));
        loadedCount = next;
      }

      print("🔼 Loaded: $loadedCount / ${all.length}");
    } catch (e) {
      print("❌ Error fetching photos: $e");
      showCustomSnackBar(AppTexts.FAILED_TO_LOAD_PHOTOS, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------
  // 🔄 SYNC IMAGES (Only if permission == view-sync)
  // ------------------------------------------------------
  Future<void> syncNow() async {
    if (!canSync) {
      showCustomSnackBar(AppTexts.VIEW_ONLY_ACCESS, SnackbarState.warning);
      return;
    }

    await fetchPhotos();
    if (photos.isEmpty) {
      showCustomSnackBar(AppTexts.NO_IMAGES_FOUND, SnackbarState.warning);
      return;
    }

    savedCount(0);
    enableOK(false);
    totalToSave(photos.length);

    Get.dialog(
      Obx(
        () => CustomPopup(
          title: enableOK.value
              ? "${AppTexts.SYNC_COMPLETE} 🎉"
              : AppTexts.SAVING_IMAGES,
          message: enableOK.value
              ? AppTexts.DOWNLOAD_FINISHED
              : AppTexts.DOWNLOADING_IMAGES,
          confirmText: enableOK.value ? AppTexts.CLOSE : AppTexts.PLEASE_WAIT,
          onConfirm: enableOK.value ? () => Get.back() : null,
          isProcessing: enableOK,
          showProgress: true,
          savedCount: savedCount,
          totalCount: totalToSave,
        ),
      ),
      barrierDismissible: false,
    );

    await saveImages();
    enableOK(true);

    LocalNotificationService.show(
      title: AppTexts.NOTIFY_SYNC_COMPLETE_TITLE,
      body:
          "All photos from '${event.title}' have been saved to your gallery successfully.",
    );

    // Store sync status
    Preference.box.put("${Preference.EVENT_SYNC_DONE}_${event.eventId}", true);

    Future.delayed(const Duration(seconds: 1), () {
      if (Get.isDialogOpen == true) Get.back();
    });
  }

  // ------------------------------------------------------
  // 🔐 STORAGE PERMISSION
  // ------------------------------------------------------
  Future<bool> askPermission() async {
    try {
      if (Platform.isIOS) {
        // iOS uses Photos permission (addOnly for saving to gallery)
        var status = await Permission.photosAddOnly.request();
        if (status.isGranted || status.isLimited) return true;

        // Fallback to full photos permission
        status = await Permission.photos.request();
        if (status.isGranted || status.isLimited) return true;

        showCustomSnackBar(
          AppTexts.STORAGE_PERMISSION_NEEDED,
          SnackbarState.error,
        );
        return false;
      }

      // Android handling
      if (Platform.isAndroid) {
        // Android 13+ (API 33+) uses granular media permissions
        if (await Permission.photos.request().isGranted) return true;

        // Android 10-12 (API 29-32)
        if (await Permission.storage.request().isGranted) return true;

        // Fallback for older Android versions
        if (await Permission.manageExternalStorage.request().isGranted) return true;
      }

      showCustomSnackBar(
        AppTexts.STORAGE_PERMISSION_NEEDED,
        SnackbarState.error,
      );
      return false;
    } catch (e) {
      debugPrint("❌ Permission error: $e");
      showCustomSnackBar(
        AppTexts.STORAGE_PERMISSION_NEEDED,
        SnackbarState.error,
      );
      return false;
    }
  }

  // ------------------------------------------------------
  // 💾 SAVE IMAGES TO GALLERY
  // ------------------------------------------------------
  Future<void> saveImages() async {
    if (!await askPermission()) return;

    // Use temporary directory for downloading (works on all platforms)
    final tempDir = await getTemporaryDirectory();
    final downloadDir = Directory("${tempDir.path}/$albumName");
    if (!downloadDir.existsSync()) {
      downloadDir.createSync(recursive: true);
    }

    final dio = Dio();
    const int batchSize = 6;

    for (int i = 0; i < photos.length; i += batchSize) {
      final batch = photos.skip(i).take(batchSize).toList();

      await Future.wait(
        batch.map((url) async {
          String name = url.split("/").last;
          String tempPath = "${downloadDir.path}/$name";

          try {
            // Download to temp directory first
            await dio.download(url, tempPath);

            // Save to gallery using GallerySaver (handles platform differences)
            final saved = await GallerySaver.saveImage(
              tempPath,
              albumName: albumName,
            );

            if (saved == true) {
              savedCount.value++;
              // Clean up temp file after saving to gallery
              try {
                File(tempPath).deleteSync();
              } catch (_) {}
            } else {
              debugPrint("❌ GallerySaver failed for: $name");
              savedCount.value++; // Still count as processed
            }
          } catch (e) {
            debugPrint("❌ Save Failed: $e");
            savedCount.value++; // Count as processed to avoid infinite loop
          }
        }),
      );
    }

    // Clean up temp directory after all downloads
    try {
      if (downloadDir.existsSync()) {
        downloadDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  }

  // ------------------------------------------------------
  // 📷 MEDIA INFO BOTTOM SHEET
  // ------------------------------------------------------
  void showMediaInfoBottomSheet(int photoIndex) {
    if (photoIndex < 0 || photoIndex >= photoData.length) return;

    final data = photoData[photoIndex];
    final mediaId = data["id"];

    if (mediaId == null) {
      showCustomSnackBar(
          AppTexts.MEDIA_INFO_NOT_AVAILABLE, SnackbarState.warning);
      return;
    }

    isMediaInfoLoading.value = true;
    currentMediaInfo.value = {};

    CustomBottomSheet.show(
      title: AppTexts.PHOTO_DETAILS,
      showCloseButton: true,
      header: _mediaInfoContent(),
      actions: [],
    );

    _fetchMediaInfo(mediaId);
  }

  Future<void> _fetchMediaInfo(int mediaId) async {
    try {
      isMediaInfoLoading.value = true;
      final response = await PublicApiService().getMediaInfo(mediaId);

      if (response["data"] != null) {
        currentMediaInfo.value = Map<String, dynamic>.from(response["data"]);
      } else {
        showCustomSnackBar(AppTexts.MEDIA_INFO_LOAD_FAILED, SnackbarState.error);
      }
    } catch (e) {
      print("❌ Media info fetch error: $e");
      showCustomSnackBar(AppTexts.MEDIA_INFO_LOAD_ERROR, SnackbarState.error);
    } finally {
      isMediaInfoLoading.value = false;
    }
  }

  Widget _mediaInfoContent() => Obx(() {
        final isDark = Get.isDarkMode;
        final width = Get.width;

        if (isMediaInfoLoading.value) {
          return const MediaInfoShimmer();
        }

        final info = currentMediaInfo.value;
        if (info.isEmpty) {
          return _buildMediaInfoEmptyState(isDark, width);
        }

        final fileName = info["fileName"] ?? AppTexts.MEDIA_INFO_UNKNOWN;
        final fileSize = info["fileSize"] ?? AppTexts.MEDIA_INFO_UNKNOWN;
        final fileType = info["fileType"] ?? AppTexts.MEDIA_INFO_UNKNOWN;
        final imgWidth = info["width"]?.toString() ?? "-";
        final imgHeight = info["height"]?.toString() ?? "-";
        final uploadedAt = info["uploadedAt"] ?? "";
        final uploadedBy = info["uploadedBy"];
        final uploaderName = uploadedBy?["name"] ?? AppTexts.MEDIA_INFO_UNKNOWN;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(AppTexts.MEDIA_INFO_FILE_NAME, fileName, isDark, width),
            _infoRow(AppTexts.FILE_SIZE, fileSize, isDark, width),
            _infoRow(AppTexts.MEDIA_INFO_FILE_TYPE,
                fileType.toString().toUpperCase(), isDark, width),
            _infoRow(AppTexts.MEDIA_INFO_DIMENSIONS, "$imgWidth × $imgHeight",
                isDark, width),
            _infoRow(
                AppTexts.MEDIA_INFO_UPLOADED_BY, uploaderName, isDark, width),
            if (uploadedAt.isNotEmpty)
              _infoRow(AppTexts.MEDIA_INFO_UPLOADED_AT,
                  _formatDateTime(uploadedAt), isDark, width),
          ],
        );
      });

  Widget _buildMediaInfoEmptyState(bool isDark, double width) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Get.height * 0.04),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: width * 0.15,
            color: isDark ? Colors.white38 : AppColors.textColor2,
          ),
          SizedBox(height: Get.height * 0.02),
          Text(
            AppTexts.MEDIA_INFO_EMPTY_TITLE,
            style: customBoldText.copyWith(
              color: isDark ? Colors.white70 : AppColors.textColor,
              fontSize: width * 0.045,
            ),
          ),
          SizedBox(height: Get.height * 0.01),
          Text(
            AppTexts.MEDIA_INFO_EMPTY_DESC,
            textAlign: TextAlign.center,
            style: customTextNormal.copyWith(
              color: isDark ? Colors.white54 : AppColors.textColor2,
              fontSize: width * 0.035,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Get.height * 0.008),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.3,
            child: Text(
              label,
              style: customMediumText.copyWith(
                fontSize: width * 0.035,
                color: isDark ? Colors.white70 : AppColors.textColor2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: customSemiBoldText.copyWith(
                fontSize: width * 0.035,
                color: isDark ? Colors.white : AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateTimeStr;
    }
  }

  /// Check if already synced for this event
  bool get alreadySynced =>
      Preference.box.get("${Preference.EVENT_SYNC_DONE}_${event.eventId}") ==
      true;
}