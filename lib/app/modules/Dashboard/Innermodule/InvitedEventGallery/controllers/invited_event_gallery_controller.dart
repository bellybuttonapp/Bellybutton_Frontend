// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print, constant_identifier_names

import 'dart:io';
import 'package:bellybutton/app/database/models/InvitedEventModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/services/local_notification_service.dart';
import '../../../../../core/utils/storage/preference.dart';
import '../../../../../global_widgets/CustomBottomSheet/CustomBottomsheet.dart';
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../routes/app_pages.dart';

class InvitedEventGalleryController extends GetxController {
  InvitedEventModel? event;

  //----------------------------------------------------
  // OBSERVABLES / STATES
  //----------------------------------------------------
  var galleryAssets = <AssetEntity>[].obs;
  var selectedAssets = <AssetEntity>[].obs;

  var isLoading = false.obs;
  var isUploading = false.obs;

  // ------------------------------------------------------
  // 📤 UPLOAD CONTROL VARIABLES
  // ------------------------------------------------------
  RxInt uploadedCount = 0.obs;
  RxInt totalToUpload = 0.obs;
  RxBool uploadDone = false.obs;

  // ======================================================
  //  ⭐ ADD THIS BLOCK HERE ⭐
  // ======================================================

  /// 1️⃣ Event NOT started yet
  bool get eventNotStarted =>
      event != null && DateTime.now().isBefore(event!.eventStartDateTime);

  /// 2️⃣ Event already finished
  bool get eventEnded =>
      event != null && DateTime.now().isAfter(event!.eventEndDateTime);

  /// 3️⃣ All uploaded on this device — nothing left
  bool get allUploaded => galleryAssets.isEmpty && uploadedCount.value > 0;

  /// 4️⃣ No images found inside event time range
  bool get noPhotosFound =>
      galleryAssets.isEmpty && !eventNotStarted && !eventEnded;

  /// 5️⃣ Event ongoing but empty gallery
  bool get eventLiveButEmpty =>
      !eventEnded && !eventNotStarted && galleryAssets.isEmpty;

  //----------------------------------------------------
  // SELECTION LOGIC
  //----------------------------------------------------

  /// Checks if given image asset is selected.
  bool isSelected(AssetEntity a) => selectedAssets.contains(a);

  /// Add/Remove asset from selection list.
  void toggleSelection(AssetEntity a) {
    if (isSelected(a))
      selectedAssets.remove(a);
    else
      selectedAssets.add(a);
  }

  /// Clears selected items list.
  void clearSelection() => selectedAssets.clear();

  /// Removes selected assets (same as clearSelection).
  void removeSelected() => selectedAssets.clear();

  //----------------------------------------------------
  // INIT
  //----------------------------------------------------

  /// Called when controller initializes.
  /// Loads event data & fetches gallery images.
  @override
  void onInit() {
    super.onInit();

    // SAFELY ACCEPT ARGUMENTS (EventModel OR InvitedEventModel)
    final data = Get.arguments;

    if (data is InvitedEventModel) {
      event = data;
    } else {
      try {
        // Assume it's EventModel or any model with toJson()
        event = InvitedEventModel.fromJson(data.toJson());
      } catch (e) {
        throw "❌ Invalid argument passed to InvitedEventGalleryController";
      }
    }

    // Delay gallery load to avoid blocking UI during navigation
    Future.microtask(() => loadGalleryImages());
  }

  // ⬇ ADD THIS INSIDE InvitedEventGalleryController
  Future<void> showImageInfoFromIndex(int index) async {
    final asset = galleryAssets[index];

    final bytes = await asset.originBytes;
    final fileSize = bytes?.length ?? 0;

    String formatSize(int size) {
      if (size < 1024) return "$size B";
      if (size < 1024 * 1024) return "${(size / 1024).toStringAsFixed(1)} KB";
      return "${(size / (1024 * 1024)).toStringAsFixed(1)} MB";
    }

    CustomBottomSheet.show(
      title: AppTexts.PHOTO_DETAILS,
      actions: [
        SheetAction(
          label: AppTexts.RESOLUTION,
          trailing: Text("${asset.width} × ${asset.height}px"),
          onTap: () {},
        ),
        SheetAction(
          label: AppTexts.FILE_SIZE,
          trailing: Text(formatSize(fileSize)),
          onTap: () {},
        ),
        SheetAction(
          label: AppTexts.CREATED,
          trailing: Text(
            DateFormat("dd MMM yyyy • hh:mm a").format(asset.createDateTime),
          ),
          onTap: () {},
        ),
      ],
    );
  }

  // ------------------------------------------------------
  // 🔍 CHECK IF IMAGE ALREADY EXISTS (PREVENT DUPLICATES)
  // ------------------------------------------------------

  /// Returns TRUE if image with same ID already exists.
  bool isDuplicate(AssetEntity asset) {
    return galleryAssets.any((a) => a.id == asset.id);
  }

  //----------------------------------------------------
  // LOAD GALLERY
  //----------------------------------------------------

  /// Loads all device gallery images within event date range.
  /// Filters by event start->end date.
  Future<void> loadGalleryImages() async {
    try {
      isLoading.value = true;

      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        isLoading.value = false;
        PhotoManager.openSetting();
        return;
      }

      /// Load previously uploaded hashes (permanent)
      List storedList = Preference.box.get(
        Preference.EVENT_UPLOADED_HASHES,
        defaultValue: <String>[],
      );
      Set<String> savedHashes = storedList.map((e) => e.toString()).toSet();

      if (event == null) {
        isLoading.value = false;
        return;
      }

      final filter = FilterOptionGroup(
        createTimeCond: DateTimeCond(
          min: event!.eventStartDateTime,
          max: event!.eventEndDateTime,
        ),
        orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
      );

      // Use hasAll: true to include the "All Photos" album (contains front + back camera images)
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
        filterOption: filter,
      );

      List<AssetEntity> temp = [];

      // First, try to load from "All" album (includes ALL camera images - front & back)
      final allAlbum = albums.firstWhereOrNull(
        (a) => a.isAll || a.name.toLowerCase() == "recent" || a.name.toLowerCase() == "all photos",
      );

      if (allAlbum != null) {
        final assets = await allAlbum.getAssetListPaged(page: 0, size: 500);
        temp.addAll(assets);
        print("Loaded ${assets.length} images from '${allAlbum.name}' album");
      } else {
        // Fallback: Load from camera-related albums (expanded list for better coverage)
        final cameraAlbums = albums.where((a) {
          final n = a.name.toLowerCase();
          return n.contains("camera") ||
              n.contains("dcim") ||
              n.contains("100media") ||
              n.contains("100andro") ||
              n.contains("photo") ||
              n.contains("selfie") ||
              n.contains("front");
        }).toList();

        for (final album in cameraAlbums) {
          final assets = await album.getAssetListPaged(page: 0, size: 500);
          temp.addAll(assets);
          print("Loaded ${assets.length} images from '${album.name}' album");
        }
      }

      // Remove duplicates (same image might appear in multiple albums)
      final seen = <String>{};
      temp = temp.where((asset) => seen.add(asset.id)).toList();

      /// 🔥 FILTER — remove previously uploaded using asset ID (fast check)
      final freshItems = temp.where((asset) => !savedHashes.contains(asset.id)).toList();

      /// Only unseen images show in UI
      galleryAssets.assignAll(freshItems);
    } catch (e) {
      print("❌ Error loading gallery: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //----------------------------------------------------
  // REFRESH
  //----------------------------------------------------

  /// Reloads gallery images again.
  Future<void> refreshGallery() async => loadGalleryImages();

  //----------------------------------------------------
  // OLD UPLOAD BUTTON CALLS POPUP FLOW
  //----------------------------------------------------

  /// Called when Upload button is clicked.
  /// Filters unselected images and uploads them.
  Future<void> onUploadTap() async {
    const int MAX_UPLOAD_LIMIT = 20;

    final assetsToUpload =
        galleryAssets.where((a) => !selectedAssets.contains(a)).toList();

    if (assetsToUpload.isEmpty) {
      showCustomSnackBar(AppTexts.NO_PHOTOS_TO_UPLOAD, SnackbarState.warning);
      return;
    }

    /// Read already uploaded permanent IDs
    List storedList = Preference.box.get(
      Preference.EVENT_UPLOADED_HASHES,
      defaultValue: <String>[],
    );

    int alreadyUploaded = storedList.length;
    int remaining = MAX_UPLOAD_LIMIT - alreadyUploaded;

    /// If reached max limit
    if (remaining <= 0) {
      showCustomSnackBar(
        AppTexts.UPLOAD_LIMIT_REACHED,
        SnackbarState.error,
      );
      return;
    }

    /// Allow only remaining photos
    final limitedAssets = assetsToUpload.take(remaining).toList();

    /// Notify if user selected more than limit
    if (limitedAssets.length < assetsToUpload.length) {
      showCustomSnackBar(
        "Only $remaining ${AppTexts.ONLY_PHOTOS_CAN_BE_UPLOADED}",
        SnackbarState.warning,
      );
    }

    uploadPhotosFromAssets(limitedAssets); // Continue with upload flow
  }

  // ------------------------------------------------------
  // ⚡ SHOW UPLOAD POPUP
  // ------------------------------------------------------

  /// Displays upload progress popup with progress bar & completion message.
  void showUploadPopup() {
    Get.dialog(
      Obx(
        () => CustomPopup(
          title: uploadDone.value
              ? AppTexts.UPLOAD_COMPLETE_TITLE
              : AppTexts.UPLOADING_PHOTOS,
          message: uploadDone.value
              ? AppTexts.ALL_IMAGES_UPLOADED_SUCCESSFULLY
              : "",
          confirmText: uploadDone.value ? AppTexts.CLOSE : "",
          onConfirm: uploadDone.value ? () => Get.back() : null,
          isProcessing: RxBool(!uploadDone.value),
          showProgress: true,
          savedCount: uploadedCount,
          totalCount: totalToUpload,
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ------------------------------------------------------
  // 🔥 UPLOAD SINGLE FILE
  // ------------------------------------------------------

  /// Uploads one photo to server.
  /// Increases uploaded count if successful.
  Future<void> uploadOne(File file) async {
    if (event == null) return;

    final res = await PublicApiService().uploadEventImagesPost(
      eventId: event!.eventId,
      files: [file],
    );

    final status = res["headers"]?["status"];
    if (status == "success") uploadedCount.value++;
  }

  // ------------------------------------------------------
  // 🚀 MAIN PARALLEL UPLOAD FUNCTION (OPTIMIZED FOR SPEED)
  // ------------------------------------------------------

  /// Uploads multiple images in parallel (6 at once for faster upload).
  /// Uses asset.id for duplicate tracking (fast, no file I/O).
  Future<void> uploadPhotosFromAssets(List<AssetEntity> assets) async {
    totalToUpload.value = assets.length;
    uploadedCount.value = 0;
    uploadDone.value = false;

    showUploadPopup();

    /// Load previously uploaded IDs
    List storedList = Preference.box.get(
      Preference.EVENT_UPLOADED_HASHES,
      defaultValue: <String>[],
    );
    Set<String> savedIds = storedList.map((e) => e.toString()).toSet();

    /// 🔥 Step 1: Prepare all files in parallel (faster than sequential)
    List<MapEntry<String, File>> filesToUpload = [];

    await Future.wait(
      assets.map((asset) async {
        if (savedIds.contains(asset.id)) return;
        final file = await asset.file;
        if (file != null) {
          filesToUpload.add(MapEntry(asset.id, file));
        }
      }),
    );

    /// 🚀 Step 2: Upload in batches of 6 for faster throughput
    const int batchSize = 6;

    for (int i = 0; i < filesToUpload.length; i += batchSize) {
      final batch = filesToUpload.skip(i).take(batchSize).toList();

      await Future.wait(
        batch.map((entry) async {
          await uploadOne(entry.value);
          savedIds.add(entry.key);
        }),
      );

      /// Save to Hive after each batch (not every file - reduces I/O)
      Preference.box.put(
        Preference.EVENT_UPLOADED_HASHES,
        savedIds.toList(),
      );
    }

    uploadDone.value = true;
    clearSelection();
    refreshGallery();

    LocalNotificationService.show(
      title: AppTexts.UPLOAD_COMPLETE_NOTIFICATION_TITLE,
      body: "${uploadedCount.value} ${AppTexts.PHOTOS_UPLOADED_SUCCESSFULLY}",
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (Get.isDialogOpen!) Get.back();
    });
  }

  //----------------------------------------------------
  // INVITED USERS
  //----------------------------------------------------

  /// Opens invited users list UI (not implemented yet).
  void onInvitedUsersTap() =>
      Get.toNamed(Routes.INVITED_ADMINS_LIST, arguments: event);
}