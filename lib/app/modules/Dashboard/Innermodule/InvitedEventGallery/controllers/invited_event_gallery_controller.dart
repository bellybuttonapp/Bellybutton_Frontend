// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print, constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:bellybutton/app/database/models/InvitedEventModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:connectivity_plus/connectivity_plus.dart';

class InvitedEventGalleryController extends GetxController with WidgetsBindingObserver {
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
  RxInt failedCount = 0.obs;
  RxList<AssetEntity> failedAssets = <AssetEntity>[].obs;

  // ------------------------------------------------------
  // 👤 USER COUNT MANAGEMENT (Real-time member tracking)
  // ------------------------------------------------------
  RxInt invitedCount = 0.obs;
  RxInt totalCapacity = 1.obs; // 🎬 Always 1 director per event

  // ------------------------------------------------------
  // 📸 REAL-TIME PHOTO DETECTION
  // ------------------------------------------------------
  Timer? _photoPollingTimer;
  int _lastKnownPhotoCount = 0;
  bool _isListeningForChanges = false;
  bool _isCheckingForPhotos = false; // Prevent concurrent checks
  Set<String> _knownAssetIds = {}; // Track known asset IDs for efficient comparison

  // ------------------------------------------------------
  // 📊 EVENT STATE GETTERS
  // ------------------------------------------------------

  /// 1️⃣ Event NOT started yet
  /// Uses local timezone for accurate comparison
  bool get eventNotStarted =>
      event != null && DateTime.now().isBefore(event!.localStartDateTime);

  /// 2️⃣ Event already finished
  /// Uses local timezone for accurate comparison
  bool get eventEnded =>
      event != null && DateTime.now().isAfter(event!.localEndDateTime);

  /// 3️⃣ All uploaded on this device — nothing left
  bool get allUploaded => galleryAssets.isEmpty && uploadedCount.value > 0;

  /// 4️⃣ Event ongoing but empty gallery (no camera photos in time range)
  bool get eventLiveButEmpty =>
      !eventEnded && !eventNotStarted && galleryAssets.isEmpty && !allUploaded;

  /// 5️⃣ No photos found (event ended with no uploads)
  bool get noPhotosFound => eventEnded && galleryAssets.isEmpty;

  /// 6️⃣ Per-event storage key for uploaded photo IDs
  String get _eventUploadKey =>
      "${Preference.EVENT_UPLOADED_HASHES}_${event?.eventId ?? 0}";

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

    // Register lifecycle observer for app resume detection
    WidgetsBinding.instance.addObserver(this);

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
    Future.microtask(() async {
      await loadGalleryImages();
      fetchInvitedUsersCount(); // Fetch member count
      _startPhotoChangeListener(); // Start real-time photo detection
    });
  }

  //----------------------------------------------------
  // 📸 REAL-TIME PHOTO CHANGE DETECTION
  //----------------------------------------------------

  /// Start listening for photo library changes
  void _startPhotoChangeListener() {
    if (_isListeningForChanges) return;
    _isListeningForChanges = true;

    // Store initial photo count and IDs
    _lastKnownPhotoCount = galleryAssets.length;
    _knownAssetIds = galleryAssets.map((a) => a.id).toSet();

    // Method 1: PhotoManager change callback (works on most devices)
    PhotoManager.addChangeCallback(_onPhotoLibraryChanged);
    PhotoManager.startChangeNotify();
    print("📸 Started PhotoManager change listener");

    // Method 2: Polling fallback (every 5 seconds) - lightweight quick check
    _photoPollingTimer?.cancel();
    _photoPollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkForNewPhotos();
    });
    print("📸 Started photo polling timer (5s interval)");
  }

  /// Stop listening for photo changes
  void _stopPhotoChangeListener() {
    _isListeningForChanges = false;
    PhotoManager.removeChangeCallback(_onPhotoLibraryChanged);
    PhotoManager.stopChangeNotify();
    _photoPollingTimer?.cancel();
    _photoPollingTimer = null;
    print("📸 Stopped photo change listeners");
  }

  /// Callback when PhotoManager detects library change
  void _onPhotoLibraryChanged(MethodCall call) {
    print("📸 Photo library changed detected via callback");
    _checkForNewPhotos();
  }

  /// Check for new photos and update gallery if found (optimized - silent check)
  Future<void> _checkForNewPhotos() async {
    // Skip if event not active or upload in progress
    if (event == null || eventNotStarted || eventEnded || isUploading.value) {
      return;
    }

    // Skip if already checking or loading
    if (_isCheckingForPhotos || isLoading.value) return;

    _isCheckingForPhotos = true;

    try {
      // Quick check: Get asset count without full reload
      final hasNewPhotos = await _hasNewPhotosQuickCheck();

      if (hasNewPhotos) {
        print("📸 New photos detected - updating gallery");
        await loadGalleryImages();
        _lastKnownPhotoCount = galleryAssets.length;
        // Update known IDs
        _knownAssetIds = galleryAssets.map((a) => a.id).toSet();
      }
    } catch (e) {
      print("📸 Error checking for new photos: $e");
    } finally {
      _isCheckingForPhotos = false;
    }
  }

  /// Quick check if there are new photos without full gallery reload
  Future<bool> _hasNewPhotosQuickCheck() async {
    if (event == null) return false;

    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) return false;

      // Quick count check using PhotoManager
      final filter = FilterOptionGroup(
        createTimeCond: DateTimeCond(
          min: event!.localStartDateTime,
          max: event!.localEndDateTime,
        ),
      );

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
        filterOption: filter,
      );

      // Get count from all photos album
      for (final album in albums) {
        if (album.isAll) {
          final count = await album.assetCountAsync;
          if (count != _lastKnownPhotoCount) {
            print("📸 Quick check: count changed from $_lastKnownPhotoCount to $count");
            return true;
          }
          break;
        }
      }

      return false;
    } catch (e) {
      print("📸 Quick check error: $e");
      return false;
    }
  }

  /// Called when app lifecycle changes (resume/pause)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // App came back to foreground - check for new photos immediately
      print("📸 App resumed - checking for new photos");
      _checkForNewPhotos();
    }
  }

  // ------------------------------------------------------
  // 🎬 FETCH EVENT DIRECTOR COUNT (Admin only for Invited Gallery)
  // ------------------------------------------------------
  Future<void> fetchInvitedUsersCount() async {
    if (event?.eventId == null) return;

    try {
      // ✅ Use getJoinedAdmins for invited event participants
      // Endpoint: /eventresource/event/userview/{eventId}
      // Returns: { "admin": {...}, "you": {...}, "event": "...", "status": "success" }
      final response = await PublicApiService().getJoinedAdmins(event!.eventId);

      // 🎬 For Invited Event Gallery: Show only Event Director (Admin) count
      // This is the event creator/owner count
      invitedCount.value = response["admin"] != null ? 1 : 0;

      print("🎬 Event Directors: ${invitedCount.value}/${totalCapacity.value}");
    } catch (e) {
      print("❌ Failed to fetch event director count: $e");
      // Default to 1 (assume admin exists)
      invitedCount.value = 1;
      print("🎬 Using default director count: ${invitedCount.value}");
    }
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

  //----------------------------------------------------
  // LOAD GALLERY
  //----------------------------------------------------

  /// Loads all device gallery images within event date range.
  /// Filters by event start->end date.
  Future<void> loadGalleryImages() async {
    try {
      isLoading.value = true;

      if (event == null) {
        isLoading.value = false;
        return;
      }

      // Skip loading if event hasn't started yet - no photos to show
      if (eventNotStarted) {
        isLoading.value = false;
        return;
      }

      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        isLoading.value = false;
        PhotoManager.openSetting();
        return;
      }

      /// Load previously uploaded hashes (per-event)
      /// 🔥 FIX: Ensure proper type casting for iOS compatibility
      final dynamic rawStoredList = Preference.box.get(_eventUploadKey);
      final Set<String> savedHashes = rawStoredList != null
          ? Set<String>.from(rawStoredList.map((e) => e.toString()))
          : <String>{};

      // Use local timezone for filtering photos
      // This ensures photos taken during the event (in user's timezone) are captured
      final filter = FilterOptionGroup(
        createTimeCond: DateTimeCond(
          min: event!.localStartDateTime,
          max: event!.localEndDateTime,
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

      // 📸 PLATFORM-SPECIFIC CAMERA FILTERING
      if (Platform.isIOS) {
        // ═══════════════════════════════════════════════════════════════
        // 🍎 iOS: Filter by asset metadata to get ONLY camera photos
        // On iOS, we use multiple strict checks to ensure only camera photos:
        // 1. Filename pattern (IMG_XXXX format from iOS camera)
        // 2. Exclude known app patterns (WhatsApp, Telegram, etc.)
        // 3. Exclude screenshots by filename and aspect ratio
        // ═══════════════════════════════════════════════════════════════

        // Get all photos from the "Recent" or "All Photos" album
        AssetPathEntity? allPhotosAlbum;
        for (final album in albums) {
          if (album.isAll) {
            allPhotosAlbum = album;
            break;
          }
        }

        if (allPhotosAlbum != null) {
          final allAssets = await allPhotosAlbum.getAssetListPaged(page: 0, size: 500);

          // Filter: Keep only photos that are from the device camera
          for (final asset in allAssets) {
            // Get asset title (filename) - primary filter on iOS
            final String title = (asset.title ?? '').toLowerCase();
            final String relativePath = (asset.relativePath ?? '').toLowerCase();

            // ═══════════════════════════════════════════════════════════════
            // ❌ STRICT EXCLUSION LIST - Skip these immediately
            // ═══════════════════════════════════════════════════════════════

            // 1️⃣ Screenshots
            if (title.contains('screenshot') || title.contains('screen shot')) {
              print("📸 iOS: Skipping screenshot: $title");
              continue;
            }

            // 2️⃣ WhatsApp images (various patterns)
            // WhatsApp filenames: IMG-YYYYMMDD-WAXXXX, WhatsApp Image YYYY-MM-DD
            if (title.contains('wa0') ||
                title.contains('wa1') ||
                title.contains('wa2') ||
                title.contains('-wa') ||
                title.contains('whatsapp') ||
                title.startsWith('img-') && title.contains('-wa')) {
              print("📸 iOS: Skipping WhatsApp image: $title");
              continue;
            }

            // 3️⃣ Telegram images
            if (title.contains('telegram') || title.startsWith('tg_')) {
              print("📸 iOS: Skipping Telegram image: $title");
              continue;
            }

            // 4️⃣ Instagram images
            if (title.contains('instagram') || title.contains('insta')) {
              print("📸 iOS: Skipping Instagram image: $title");
              continue;
            }

            // 5️⃣ Downloaded/Saved images
            if (title.contains('download') ||
                title.contains('saved') ||
                title.contains('import') ||
                title.contains('received')) {
              print("📸 iOS: Skipping downloaded image: $title");
              continue;
            }

            // 6️⃣ Other messaging apps
            if (title.contains('signal') ||
                title.contains('viber') ||
                title.contains('messenger') ||
                title.contains('wechat') ||
                title.contains('snapchat')) {
              print("📸 iOS: Skipping messaging app image: $title");
              continue;
            }

            // 7️⃣ Check relativePath for app folders (when available)
            if (relativePath.isNotEmpty) {
              if (relativePath.contains('whatsapp') ||
                  relativePath.contains('telegram') ||
                  relativePath.contains('instagram') ||
                  relativePath.contains('facebook') ||
                  relativePath.contains('messenger') ||
                  relativePath.contains('download') ||
                  relativePath.contains('import')) {
                print("📸 iOS: Skipping app folder image: $title ($relativePath)");
                continue;
              }
            }

            // ═══════════════════════════════════════════════════════════════
            // ✅ INCLUSION CRITERIA - Include photos that passed exclusion checks
            // Using BLACKLIST approach: Include everything except known non-camera sources
            // ═══════════════════════════════════════════════════════════════

            // Check aspect ratio for screenshot detection
            final double aspectRatio = asset.width > 0 && asset.height > 0
                ? (asset.width > asset.height
                    ? asset.width / asset.height
                    : asset.height / asset.width)
                : 0;

            // Screenshot aspect ratio (modern iPhones): ~2.16-2.17
            final bool isScreenshotAspectRatio = aspectRatio > 2.1 && aspectRatio < 2.25;

            // Skip if screenshot aspect ratio (additional screenshot check)
            if (isScreenshotAspectRatio) {
              print("📸 iOS: Skipping screenshot by aspect ratio: $title (ratio: $aspectRatio)");
              continue;
            }

            // ═══════════════════════════════════════════════════════════════
            // 🎯 FINAL DECISION - Include photo (passed all exclusion checks)
            // ═══════════════════════════════════════════════════════════════
            print("📸 iOS: Including camera photo: $title");
            temp.add(asset);
          }
          print("📸 iOS: Loaded ${temp.length} camera images (filtered from ${allAssets.length} total)");
        }
      } else {
        // ═══════════════════════════════════════════════════════════════
        // 🤖 ANDROID: Filter by album name (works reliably)
        // ═══════════════════════════════════════════════════════════════
        List<AssetPathEntity> cameraAlbums = albums.where((a) {
          final n = a.name.toLowerCase();
          return n == "camera" ||
              n == "dcim" ||
              n.contains("100media") ||
              n.contains("100andro") ||
              n.contains("100apple");
        }).toList();

        if (cameraAlbums.isEmpty) {
          // Fallback: Try broader camera-related patterns if no exact match
          cameraAlbums = albums.where((a) {
            final n = a.name.toLowerCase();
            return n.contains("camera") || n.contains("dcim");
          }).toList();
        }

        for (final album in cameraAlbums) {
          final assets = await album.getAssetListPaged(page: 0, size: 500);
          temp.addAll(assets);
          print("📸 Android: Loaded ${assets.length} camera images from '${album.name}' album");
        }
      }

      // Remove duplicates (same image might appear in multiple albums)
      final seen = <String>{};
      temp = temp.where((asset) => seen.add(asset.id)).toList();

      /// 🔥 FILTER — remove previously uploaded using asset ID (fast check)
      final freshItems = temp.where((asset) => !savedHashes.contains(asset.id)).toList();

      /// Only unseen images show in UI
      galleryAssets.assignAll(freshItems);
    } catch (e, stackTrace) {
      print("❌ Error loading gallery: $e");
      print("📍 Stack trace: $stackTrace");
    } finally {
      isLoading.value = false;
    }
  }

  //----------------------------------------------------
  // REFRESH
  //----------------------------------------------------

  /// Reloads gallery images and refreshes member count
  Future<void> refreshGallery() async {
    // ⚡ Run both operations in parallel for faster refresh
    await Future.wait([
      loadGalleryImages(),
      fetchInvitedUsersCount().catchError((e) {
        debugPrint("⚠️ Failed to refresh member count: $e");
        // Don't block gallery refresh if count fetch fails
      }),
    ]);
  }

  // ------------------------------------------------------
  // 🌐 NETWORK CONNECTIVITY CHECK
  // ------------------------------------------------------
  Future<bool> _hasNetworkConnection() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  //----------------------------------------------------
  // OLD UPLOAD BUTTON CALLS POPUP FLOW
  //----------------------------------------------------

  /// Called when Upload button is clicked.
  /// Filters unselected images and uploads them.
  Future<void> onUploadTap() async {
    // Check network connectivity first
    if (!await _hasNetworkConnection()) {
      showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
      return;
    }

    const int MAX_UPLOAD_LIMIT = 20;

    final assetsToUpload =
        galleryAssets.where((a) => !selectedAssets.contains(a)).toList();

    if (assetsToUpload.isEmpty) {
      showCustomSnackBar(AppTexts.NO_PHOTOS_TO_UPLOAD, SnackbarState.warning);
      return;
    }

    /// Read already uploaded permanent IDs (per-event)
    /// 🔥 FIX: Ensure proper type casting for iOS compatibility
    final dynamic rawList = Preference.box.get(_eventUploadKey);
    final List<String> storedList = rawList != null
        ? List<String>.from(rawList.map((e) => e.toString()))
        : <String>[];

    int alreadyUploaded = storedList.length;
    int remaining = MAX_UPLOAD_LIMIT - alreadyUploaded;

    print("📊 Upload limit check: $alreadyUploaded already uploaded, $remaining remaining (max: $MAX_UPLOAD_LIMIT)");

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

    print("📤 Uploading ${limitedAssets.length} photos (limit enforced)");
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
          barrierDismissible: false,
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ------------------------------------------------------
  // 🔥 UPLOAD SINGLE FILE
  // ------------------------------------------------------

  /// Uploads one photo to server.
  /// Returns true if successful, false otherwise.
  Future<bool> uploadOne(File file) async {
    if (event == null) return false;

    try {
      final res = await PublicApiService().uploadEventImagesPost(
        eventId: event!.eventId,
        files: [file],
      );

      final status = res["headers"]?["status"];
      if (status == "success") {
        uploadedCount.value++;
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Upload failed: $e");
      return false;
    }
  }

  // ------------------------------------------------------
  // 🚀 MAIN PARALLEL UPLOAD FUNCTION (OPTIMIZED FOR SPEED)
  // ------------------------------------------------------

  /// Uploads multiple images in parallel (6 at once for faster upload).
  /// Uses asset.id for duplicate tracking (fast, no file I/O).
  Future<void> uploadPhotosFromAssets(List<AssetEntity> assets) async {
    isUploading.value = true;
    totalToUpload.value = assets.length;
    uploadedCount.value = 0;
    uploadDone.value = false;
    failedCount.value = 0;
    failedAssets.clear();

    showUploadPopup();

    /// Load previously uploaded IDs (per-event)
    /// 🔥 FIX: Ensure proper type casting for iOS compatibility
    final dynamic rawUploadedList = Preference.box.get(_eventUploadKey);
    Set<String> savedIds = rawUploadedList != null
        ? Set<String>.from(rawUploadedList.map((e) => e.toString()))
        : <String>{};

    /// 🔥 Step 1: Prepare all files in parallel (faster than sequential)
    List<MapEntry<AssetEntity, File>> filesToUpload = [];

    await Future.wait(
      assets.map((asset) async {
        if (savedIds.contains(asset.id)) return;
        final file = await asset.file;
        if (file != null) {
          filesToUpload.add(MapEntry(asset, file));
        }
      }),
    );

    /// 🚀 Step 2: Upload in batches of 6 for faster throughput
    const int batchSize = 6;

    for (int i = 0; i < filesToUpload.length; i += batchSize) {
      final batch = filesToUpload.skip(i).take(batchSize).toList();

      await Future.wait(
        batch.map((entry) async {
          final success = await uploadOne(entry.value);
          if (success) {
            savedIds.add(entry.key.id);
          } else {
            failedCount.value++;
            failedAssets.add(entry.key);
          }
        }),
      );

      /// Save to Hive after each batch (not every file - reduces I/O)
      Preference.box.put(
        _eventUploadKey,
        savedIds.toList(),
      );
    }

    uploadDone.value = true;
    isUploading.value = false;
    clearSelection();
    refreshGallery();

    // Show appropriate notification based on results
    if (failedCount.value > 0) {
      LocalNotificationService.show(
        title: AppTexts.UPLOAD_COMPLETE_NOTIFICATION_TITLE,
        body: "${uploadedCount.value} uploaded, ${failedCount.value} failed",
      );
    } else {
      LocalNotificationService.show(
        title: AppTexts.UPLOAD_COMPLETE_NOTIFICATION_TITLE,
        body: "${uploadedCount.value} ${AppTexts.PHOTOS_UPLOADED_SUCCESSFULLY}",
      );
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (Get.isDialogOpen!) Get.back();
      // Show retry option if there are failed uploads
      if (failedAssets.isNotEmpty) {
        _showRetryDialog();
      }
    });
  }

  // ------------------------------------------------------
  // 🔄 RETRY FAILED UPLOADS
  // ------------------------------------------------------
  void _showRetryDialog() {
    Get.dialog(
      CustomPopup(
        title: AppTexts.UPLOAD_FAILED_TITLE,
        message: "${failedCount.value} ${AppTexts.PHOTOS_FAILED_TO_UPLOAD}",
        confirmText: AppTexts.ERROR_RETRY,
        cancelText: AppTexts.CANCEL,
        isProcessing: false.obs,
        barrierDismissible: true,
        onConfirm: () {
          Get.back();
          retryFailedUploads();
        },
      ),
      barrierDismissible: true,
    );
  }

  /// Retry uploading failed assets
  Future<void> retryFailedUploads() async {
    if (failedAssets.isEmpty) return;

    // Check network before retry
    if (!await _hasNetworkConnection()) {
      showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
      return;
    }

    final assetsToRetry = List<AssetEntity>.from(failedAssets);
    uploadPhotosFromAssets(assetsToRetry);
  }

  //----------------------------------------------------
  // INVITED USERS
  //----------------------------------------------------

  /// Opens invited users list UI (not implemented yet).
  void onInvitedUsersTap() =>
      Get.toNamed(Routes.INVITED_ADMINS_LIST, arguments: event);

  // ------------------------------------------------------
  // 🔙 HANDLE BACK NAVIGATION
  // ------------------------------------------------------
  void handleBackNavigation() {
    // If upload is in progress, show confirmation dialog
    if (!uploadDone.value && totalToUpload.value > 0) {
      Get.dialog(
        CustomPopup(
          title: AppTexts.DISCARD_CHANGES_TITLE,
          message: AppTexts.UPLOADING_PHOTOS,
          confirmText: AppTexts.DISCARD,
          cancelText: AppTexts.CANCEL,
          isProcessing: false.obs,
          onConfirm: () {
            Get.back(); // Close dialog
            Get.back(); // Go back to previous screen
          },
        ),
      );
      return;
    }

    // No upload in progress, navigate back normally
    Get.back();
  }

  //----------------------------------------------------
  // CLEANUP
  //----------------------------------------------------
  @override
  void onClose() {
    // Stop photo change listeners
    _stopPhotoChangeListener();

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    super.onClose();
  }
}