// ignore_for_file: unnecessary_overrides, deprecated_member_use, unnecessary_set_literal

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../api/PublicApiService.dart';
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
import '../../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../../../../../routes/app_pages.dart';

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

      List<String> all =
          result["data"].map<String>((e) => e["fileUrl"].toString()).toList();

      Preference.box.put(Preference.EVENT_GALLERY_CACHE, all);

      if (!loadMore) {
        /// First load: Only first batch
        photos.assignAll(all.take(batchSize).toList());
        loadedCount = photos.length;
      } else {
        /// Load more when user scrolls
        int next = loadedCount + batchSize;
        if (next > all.length) next = all.length;

        photos.addAll(all.sublist(loadedCount, next));
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
      showCustomSnackBar("No Images Found", SnackbarState.warning);
      return;
    }

    savedCount(0);
    enableOK(false);
    totalToSave(photos.length);

    Get.dialog(
      Obx(
        () => CustomPopup(
          title: enableOK.value ? "Sync Complete 🎉" : "Saving Images...",
          message:
              enableOK.value
                  ? "Download Finished Successfully"
                  : "Downloading images, please wait...",
          confirmText: enableOK.value ? "Close" : "Please wait...",
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
    if (await Permission.storage.request().isGranted) return true;
    if (await Permission.manageExternalStorage.request().isGranted) return true;
    showCustomSnackBar(
      "Storage access needed to save images!",
      SnackbarState.error,
    );
    return false;
  }

  // ------------------------------------------------------
  // 💾 SAVE IMAGES TO GALLERY (PARALLEL FOR SPEED)
  // ------------------------------------------------------
  Future<void> saveImages() async {
    if (!await askPermission()) return;

    Directory dir = Directory("/storage/emulated/0/Pictures/$albumName");
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final dio = Dio();
    const int batchSize = 6; // Download 6 images at once

    for (int i = 0; i < photos.length; i += batchSize) {
      final batch = photos.skip(i).take(batchSize).toList();

      await Future.wait(
        batch.map((url) async {
          String name = url.split("/").last;
          String path = "${dir.path}/$name";

          if (File(path).existsSync()) {
            savedCount.value++;
            return;
          }

          try {
            await dio.download(url, path);
            await GallerySaver.saveImage(path, albumName: albumName);
            savedCount.value++;
          } catch (e) {
            debugPrint("❌ Save Failed $e");
          }
        }),
      );
    }
  }

  // ------------------------------------------------------
  // 🔗 SHARE OPTIONS
  // ------------------------------------------------------
  RxBool viewOnly = true.obs;
  RxBool viewAndSync = false.obs;

  String generateShareLink() =>
      "https://bellybutton.app/invite/${event.id}?permission=${viewOnly.value ? "view-only" : "view-sync"}";

  // ------------------------------------------------------
  // 📤 SHARE BOTTOMSHEET
  // ------------------------------------------------------
  void openShareBottomSheet() {
    CustomBottomSheet.show(
      title: "Share Event Images",
      header: _permissionSelector(),
      footer: _shareButton(),
      actions: [],
    );
  }

  Widget _permissionSelector() => Obx(
    () => Column(
      children: [
        _switchTile(
          AppTexts.VIEW_ONLY,
          AppTexts.VIEW_ONLY_DESC,
          viewOnly.value,
          (_) => {viewOnly(true), viewAndSync(false)},
        ),
        const SizedBox(height: 12),
        _switchTile(
          AppTexts.VIEW_AND_SYNC,
          AppTexts.VIEW_AND_SYNC_DESC,
          viewAndSync.value,
          (_) => {viewOnly(false), viewAndSync(true)},
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

  Widget _linkField() => GlobalTextField(
    hintText: "Share Link",
    initialValue: generateShareLink(),
    readOnly: true,
    suffixIcon: IconButton(
      icon: const Icon(Icons.copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: generateShareLink()));
        showCustomSnackBar("Copied!", SnackbarState.success);
        Get.back();
      },
    ),
  );

  Widget _shareButton() => global_button(
    title: "Share Link",
    backgroundColor: AppColors.primaryColor,
    onTap: () => Share.share(generateShareLink()),
  );

  // ------------------------------------------------------
  // ⚡ FAB ACTIONS
  // ------------------------------------------------------
  void fabOneAction() => openShareBottomSheet();
  void fabTwoAction() => Get.toNamed(Routes.INVITEUSER);
  void onInvitedUsersTap() =>
      Get.toNamed(Routes.INVITED_USERS_LIST, arguments: event);
}
