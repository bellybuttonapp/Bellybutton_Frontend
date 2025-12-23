// ignore_for_file: unnecessary_overrides, deprecated_member_use, unnecessary_set_literal, depend_on_referenced_packages

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../core/constants/app_constant.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/services/local_notification_service.dart';
import '../../../../../core/utils/storage/preference.dart';
import '../../../../../core/utils/themes/font_style.dart';
import '../../../../../database/models/EventModel.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../global_widgets/CustomBottomSheet/CustomBottomsheet.dart';
import '../../../../../routes/app_pages.dart';
import '../../../../../global_widgets/Shimmers/MediaInfoShimmer.dart';

class EventGalleryController extends GetxController {
  late EventModel event;

  // ------------------------------------------------------
  // 📌 GALLERY CONTROL VARIABLES
  // ------------------------------------------------------
  RxBool enableOK = false.obs;
  RxInt savedCount = 0.obs;
  RxInt totalToSave = 0.obs;
  RxBool isLoading = true.obs;

  // ------------------------------------------------------
  // 👤 ADMIN & INVITATION MANAGEMENT
  // ------------------------------------------------------
  RxInt invitedCount = 0.obs;
  RxInt totalCapacity = 5.obs; // if max is 5, you can change from API

  late String albumName;
  RxList<String> photos = <String>[].obs;
  RxList<Map<String, dynamic>> photoData = <Map<String, dynamic>>[].obs;

  // ------------------------------------------------------
  // 📷 MEDIA INFO VARIABLES
  // ------------------------------------------------------
  RxBool isMediaInfoLoading = false.obs;
  Rx<Map<String, dynamic>> currentMediaInfo = Rx<Map<String, dynamic>>({});

  // ======================================================
  //  ⭐ EVENT STATE GETTERS (EMPTY PLACEHOLDER CONDITIONS)
  // ======================================================

  /// 1️⃣ Event NOT started yet
  bool get eventNotStarted => DateTime.now().isBefore(event.fullEventDateTime);

  /// 2️⃣ Event already finished
  bool get eventEnded => DateTime.now().isAfter(event.fullEventEndDateTime);

  /// 3️⃣ Event is currently live (ongoing)
  bool get eventLive => !eventNotStarted && !eventEnded;

  /// 4️⃣ All synced on this device
  bool get allSynced => Preference.box.get(Preference.EVENT_SYNC_DONE) == true;

  /// 5️⃣ No photos uploaded to this event yet (from server)
  bool get noPhotosUploaded => photos.isEmpty && !isLoading.value;

  /// 6️⃣ Event live but no photos yet
  bool get eventLiveButEmpty => eventLive && noPhotosUploaded;

  @override
  void onInit() {
    super.onInit();

    // ------------------------------------------------------
    // 🚀 INITIAL SETUP
    // ------------------------------------------------------
    event = Get.arguments as EventModel;
    albumName = "EventGallery_${event.title.replaceAll(" ", "_")}";
    fetchPhotos();
    fetchInvitedUsersCount();
  }

  // ------------------------------------------------------
  // 🧾 FETCH INVITED USERS COUNT
  // ------------------------------------------------------
  Future<void> fetchInvitedUsersCount() async {
    final response = await PublicApiService().getJoinedUsers(event.id!);

    int admin = response["admin"] != null ? 1 : 0;
    int members = (response["joinedPeople"] ?? []).length;

    invitedCount.value = admin + members;
    invitedCount.refresh();
  }

  /// ------------------------------------------------------
  /// 🖼 FETCH EVENT PHOTOS with INTERNAL PAGINATION (No API pagination required)
  /// ------------------------------------------------------
  int batchSize = 100; // how many images per load
  int loadedCount = 0; // how many loaded till now

  Future<void> fetchPhotos({bool loadMore = false}) async {
    // Set loading state on first load
    if (!loadMore) {
      isLoading.value = true;
    }

    try {
      // Load cache only on first run
      if (!loadMore) {
        List<String>? cached =
            Preference.box.get(Preference.EVENT_GALLERY_CACHE)?.cast<String>();

        if (cached != null && cached.isNotEmpty) {
          photos.assignAll(cached.take(batchSize).toList());
          loadedCount = photos.length;
        }
      }

      // 🔥 Fetch all images once (full list heavy only first time)
      final result = await PublicApiService().fetchEventPhotos(event.id);
      if (result["data"] == null) {
        isLoading.value = false;
        return;
      }

      List<Map<String, dynamic>> allData =
          (result["data"] as List).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();

      List<String> all =
          allData.map<String>((e) => e["fileUrl"].toString()).toList();

      Preference.box.put(Preference.EVENT_GALLERY_CACHE, all);

      if (!loadMore) {
        /// First load: Only first batch
        photos.assignAll(all.take(batchSize).toList());
        photoData.assignAll(allData.take(batchSize).toList());
        loadedCount = photos.length;
      } else {
        /// Load more when user scrolls
        int next = loadedCount + batchSize;
        if (next > all.length) next = all.length;

        photos.addAll(all.sublist(loadedCount, next));
        photoData.addAll(allData.sublist(loadedCount, next));
        loadedCount = next;
      }

      debugPrint(
        "🔼 Loaded: $loadedCount / ${Preference.box.get(Preference.EVENT_GALLERY_CACHE).length}",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------
  // 🔄 SYNC IMAGES
  // ------------------------------------------------------
  Future<void> syncNow() async {
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
          title: enableOK.value ? "${AppTexts.SYNC_COMPLETE} 🎉" : AppTexts.SAVING_IMAGES,
          message:
              enableOK.value
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

    // 🔥 store permanently so UI shows Completed always next time
    Preference.box.put(Preference.EVENT_SYNC_DONE, true);

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
  // 💾 SAVE IMAGES TO GALLERY (PARALLEL FOR SPEED)
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
    const int batchSize = 6; // Download 6 images at once

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
  // 🔗 SHARE OPTIONS
  // ------------------------------------------------------
  RxBool viewOnly = true.obs;
  RxBool viewAndSync = false.obs;
  RxBool isShareLoading = false.obs;
  RxString shareLink = "".obs;
  final shareLinkController = TextEditingController();

  /// Get current permission type based on selection
  String get currentPermission => viewOnly.value ? "view-only" : "view-sync";

  // ------------------------------------------------------
  // 📤 SHARE BOTTOMSHEET
  // ------------------------------------------------------
  void openShareBottomSheet() {
    // Reset states
    viewOnly.value = true;
    viewAndSync.value = false;
    shareLink.value = "";
    shareLinkController.text = AppTexts.LOADING;

    // Fetch initial link with default permission
    _fetchShareLink();

    CustomBottomSheet.show(
      title: AppTexts.SHARE_GROUP_TITLE,
      header: _permissionSelector(),
      footer: _shareButton(),
      actions: [],
    );
  }

  /// Fetch share link from API
  Future<void> _fetchShareLink() async {
    isShareLoading.value = true;
    shareLinkController.text = AppTexts.LOADING;

    try {
      final response = await PublicApiService().shareEvent(
        event.id!,
        permission: currentPermission,
      );

      debugPrint("📦 Share Response: $response");

      // Response format: { "shareLink": "...", "message": "...", "status": "success" }
      if (response["status"] == "success" && response["shareLink"] != null) {
        shareLink.value = response["shareLink"];
        shareLinkController.text = response["shareLink"];
      } else if (response["success"] == true && response["shareLink"] != null) {
        shareLink.value = response["shareLink"];
        shareLinkController.text = response["shareLink"];
      } else {
        // Fallback to generated link if API fails
        final fallback =
            "${AppConstants.UNIVERSAL_LINK_PREFIX}/invite/${event.id}?permission=$currentPermission";
        shareLink.value = fallback;
        shareLinkController.text = fallback;
      }
    } catch (e) {
      debugPrint("❌ Share link fetch error: $e");
      // Fallback link
      final fallback =
          "${AppConstants.UNIVERSAL_LINK_PREFIX}/invite/${event.id}?permission=$currentPermission";
      shareLink.value = fallback;
      shareLinkController.text = fallback;
    } finally {
      isShareLoading.value = false;
    }
  }

  Widget _permissionSelector() => Obx(
    () => Column(
      children: [
        _switchTile(
          AppTexts.VIEW_ONLY,
          AppTexts.VIEW_ONLY_DESC,
          viewOnly.value,
          (_) {
            viewOnly.value = true;
            viewAndSync.value = false;
            _fetchShareLink();
          },
        ),
        const SizedBox(height: 12),
        _switchTile(
          AppTexts.VIEW_AND_SYNC,
          AppTexts.VIEW_AND_SYNC_DESC,
          viewAndSync.value,
          (_) {
            viewOnly.value = false;
            viewAndSync.value = true;
            _fetchShareLink();
          },
        ),
        const SizedBox(height: 18),
        _linkField(),
      ],
    ),
  );

  Widget _switchTile(String title, desc, bool val, Function(bool) onChanged) {
    final isDark = Get.isDarkMode;

    return SwitchListTile(
      value: val,
      onChanged: onChanged,
      contentPadding: EdgeInsets.symmetric(horizontal: Get.width * 0.02),
      activeColor: AppColors.success,
      activeTrackColor:
          isDark ? Colors.white70 : AppColors.success.withOpacity(0.6),
      inactiveThumbColor:
          isDark
              ? Colors.grey.shade300
              : AppColors.primaryColor.withOpacity(0.5),
      inactiveTrackColor:
          isDark ? Colors.grey.withOpacity(0.4) : Colors.grey.withOpacity(0.3),
      title: Text(
        title,
        style: customBoldText.copyWith(fontSize: Get.width * 0.035),
      ),
      subtitle: Text(desc),
    );
  }

  Widget _linkField() => Obx(
    () => Container(
      width: Get.width,
      padding: EdgeInsets.symmetric(
        horizontal: Get.width * 0.04,
        vertical: Get.height * 0.015,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade600),
        borderRadius: BorderRadius.circular(Get.width * 0.02),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isShareLoading.value ? AppTexts.LOADING : shareLinkController.text,
              style: TextStyle(
                fontSize: Get.width * 0.035,
                color: Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: Get.width * 0.02),
          GestureDetector(
            onTap:
                isShareLoading.value
                    ? null
                    : () {
                      Clipboard.setData(ClipboardData(text: shareLink.value));
                      showCustomSnackBar(AppTexts.COPIED, SnackbarState.success);
                    },
            child: Icon(
              isShareLoading.value
                  ? Icons.hourglass_empty
                  : Icons.copy_outlined,
              size: Get.width * 0.055,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    ),
  );

  /// Generate formatted share message with event details
  String get _shareMessage {
    final permissionText =
        viewOnly.value ? AppTexts.VIEW_PHOTOS : AppTexts.VIEW_AND_DOWNLOAD_PHOTOS;

    return '''
📸 *${event.title}*

$permissionText from this event:
${shareLink.value}

📲 ${AppTexts.DOWNLOAD_APP_MESSAGE}
${AppConstants.APP_STORE_URL}
''';
  }

  Widget _shareButton() => Obx(
    () => global_button(
      title: isShareLoading.value ? AppTexts.LOADING : AppTexts.SHARE_LINK,
      backgroundColor: AppColors.primaryColor,
      onTap:
          isShareLoading.value
              ? null
              : () {
                Get.back(); // Close bottomsheet first
                Share.share(
                  _shareMessage,
                  subject: "${AppTexts.EVENT_PHOTOS_SUBJECT} ${event.title}",
                );
              },
    ),
  );

  // ------------------------------------------------------
  // ⚡ FAB ACTIONS
  // ------------------------------------------------------
  void fabOneAction() => openShareBottomSheet();
  void fabTwoAction() => Get.toNamed(Routes.INVITEUSER, arguments: event);
  void onInvitedUsersTap() =>
      Get.toNamed(Routes.INVITED_USERS_LIST, arguments: event);

  // ------------------------------------------------------
  // 📷 MEDIA INFO BOTTOM SHEET
  // ------------------------------------------------------

  /// Open media info bottom sheet for a specific photo index
  void showMediaInfoBottomSheet(int photoIndex) {
    if (photoIndex < 0 || photoIndex >= photoData.length) return;

    final data = photoData[photoIndex];
    final mediaId = data["id"];

    if (mediaId == null) {
      showCustomSnackBar(AppTexts.MEDIA_INFO_NOT_AVAILABLE, SnackbarState.warning);
      return;
    }

    // Show bottom sheet with loading state first
    isMediaInfoLoading.value = true;
    currentMediaInfo.value = {};

    CustomBottomSheet.show(
      title: AppTexts.PHOTO_DETAILS,
      showCloseButton: true,
      header: _mediaInfoContent(),
      actions: [],
    );

    // Fetch detailed info from API
    _fetchMediaInfo(mediaId);
  }

  /// Fetch media info from API
  Future<void> _fetchMediaInfo(int mediaId) async {
    try {
      isMediaInfoLoading.value = true;
      final response = await PublicApiService().getMediaInfo(mediaId);

      debugPrint("📷 Media Info Response: $response");

      if (response["data"] != null) {
        currentMediaInfo.value = Map<String, dynamic>.from(response["data"]);
      } else if (response["headers"]?["status"] == "success" && response["data"] != null) {
        currentMediaInfo.value = Map<String, dynamic>.from(response["data"]);
      } else {
        showCustomSnackBar(AppTexts.MEDIA_INFO_LOAD_FAILED, SnackbarState.error);
      }
    } catch (e) {
      debugPrint("❌ Media info fetch error: $e");
      showCustomSnackBar(AppTexts.MEDIA_INFO_LOAD_ERROR, SnackbarState.error);
    } finally {
      isMediaInfoLoading.value = false;
    }
  }

  /// Build media info content widget
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

    // Extract info from response
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
        _infoRow(AppTexts.MEDIA_INFO_FILE_TYPE, fileType.toString().toUpperCase(), isDark, width),
        _infoRow(AppTexts.MEDIA_INFO_DIMENSIONS, "$imgWidth × $imgHeight", isDark, width),
        _infoRow(AppTexts.MEDIA_INFO_UPLOADED_BY, uploaderName, isDark, width),
        if (uploadedAt.isNotEmpty)
          _infoRow(AppTexts.MEDIA_INFO_UPLOADED_AT, _formatDateTime(uploadedAt), isDark, width),
      ],
    );
  });

  /// Build empty state for media info
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

  /// Build a single info row
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

  /// Format datetime string
  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateTimeStr;
    }
  }
}