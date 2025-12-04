// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print

import 'dart:io';
import 'dart:ui' as ui;
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
import 'package:crypto/crypto.dart';

class InvitedEventGalleryController extends GetxController {
  late InvitedEventModel event;

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

    loadGalleryImages();
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

    final filter = FilterOptionGroup(
      createTimeCond: DateTimeCond(
        min: event.eventStartDateTime,
        max: event.eventEndDateTime,
      ),
      orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
    );

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: false,
      filterOption: filter,
    );

    final cameraAlbums =
        albums.where((a) {
          final n = a.name.toLowerCase();
          return n.contains("camera") ||
              n.contains("dcim") ||
              n.contains("100media") ||
              n.contains("100andro");
        }).toList();

    List<AssetEntity> temp = [];
    for (final a in cameraAlbums) {
      temp.addAll(await a.getAssetListPaged(page: 0, size: 800));
    }
    
    /// 🔥 FILTER — remove previously uploaded permanently
    List<AssetEntity> freshItems = [];
    for (final asset in temp) {
      final file = await asset.file;
      if (file == null) continue;

      final hash = md5.convert(await file.readAsBytes()).toString();
      if (!savedHashes.contains(hash)) {
        freshItems.add(asset);
      }
    }

    /// NEW — Only unseen images show in UI
    galleryAssets.assignAll(freshItems);

    isLoading.value = false;
    update();
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
    final assetsToUpload =
        galleryAssets.where((a) => !selectedAssets.contains(a)).toList();

    if (assetsToUpload.isEmpty) {
      showCustomSnackBar("No photos to upload", SnackbarState.warning);
      return;
    }

    final files = <File>[];
    for (final a in assetsToUpload) {
      final f = await a.file;
      if (f != null) files.add(f);
    }

    if (files.isEmpty) {
      showCustomSnackBar("Files empty", SnackbarState.error);
      return;
    }

    uploadPhotos(files); // 🔥 NEW — triggers popup upload
  }

  // ------------------------------------------------------
  // ⚡ SHOW UPLOAD POPUP
  // ------------------------------------------------------

  /// Displays upload progress popup with progress bar & completion message.
  void showUploadPopup() {
    Get.dialog(
      Obx(
        () => CustomPopup(
          title:
              uploadDone.value ? "Upload Complete 🎉" : "Uploading Photos...",
          message:
              uploadDone.value
                  ? "All images uploaded successfully!"
                  : "Uploading to server, please wait...",
          confirmText: uploadDone.value ? "Close" : "Processing...",
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
    final res = await PublicApiService().uploadEventImagesPost(
      eventId: event.eventId,
      files: [file],
    );

    final status = res["headers"]?["status"];
    if (status == "success") uploadedCount.value++;
  }

  // ------------------------------------------------------
  // 🚀 MAIN PARALLEL UPLOAD FUNCTION  (LOCAL DUPLICATE SKIP)
  // ------------------------------------------------------

  Future<ui.Image> getImageInfo(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Uploads multiple images in parallel (4 at once).
  /// Prevents duplicate uploads by filename.
  Future<String> getFileHash(File file) async {
    final bytes = await file.readAsBytes(); // Read full image bytes
    return md5.convert(bytes).toString(); // Hash = completely unique signature
  }

  Future<void> uploadPhotos(List<File> files) async {
    totalToUpload.value = files.length;
    uploadedCount.value = 0;
    uploadDone.value = false;

    showUploadPopup();

    List<Future> queue = [];

    /// 🔥 Load previously uploaded hashes safely (convert dynamic→String)
    List storedList = Preference.box.get(
      Preference.EVENT_UPLOADED_HASHES,
      defaultValue: <String>[],
    );

    Set<String> savedHashes =
        storedList.map((e) => e.toString()).toSet(); // FIXED ✔

    for (final file in files) {
      String hash = await getFileHash(file); // Generate MD5 signature

      /// 🛑 Already uploaded before → Skip permanently
      if (savedHashes.contains(hash)) {
        print("⛔ SKIPPED — Image already uploaded earlier");
        continue;
      }

      /// 🟢 First time upload → Save hash permanently in Hive
      savedHashes.add(hash);
      Preference.box.put(
        Preference.EVENT_UPLOADED_HASHES,
        savedHashes.toList(),
      );

      queue.add(uploadOne(file));

      if (queue.length == 4) {
        await Future.wait(queue);
        queue.clear();
      }
    }

    if (queue.isNotEmpty) await Future.wait(queue);

    uploadDone.value = true;
    clearSelection();
    refreshGallery();

    LocalNotificationService.show(
      title: "Upload Complete",
      body:
          "Uploaded ${uploadedCount.value} NEW photos ✔ (Duplicates skipped permanently)",
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
