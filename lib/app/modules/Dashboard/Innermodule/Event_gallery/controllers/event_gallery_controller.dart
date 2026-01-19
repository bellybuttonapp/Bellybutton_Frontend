// ignore_for_file: unnecessary_overrides, deprecated_member_use, unnecessary_set_literal, depend_on_referenced_packages, avoid_print

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import '../../inviteuser/controllers/inviteuser_controller.dart';
import '../../inviteuser/models/invite_user_arguments.dart';
import '../../inviteuser/views/inviteuser_view.dart';

class EventGalleryController extends GetxController with WidgetsBindingObserver {
  late EventModel event;

  // ------------------------------------------------------
  // 📌 GALLERY CONTROL VARIABLES
  // ------------------------------------------------------
  RxBool enableOK = false.obs;
  RxInt savedCount = 0.obs;
  RxInt totalToSave = 0.obs;
  RxBool isLoading = true.obs;
  RxBool isAutoSyncEnabled = false.obs; // Tracks auto-sync preference
  RxBool isAutoSyncing = false.obs; // True while auto-sync is in progress
  RxBool isDownloading = false.obs; // True while manual sync is in progress

  // ------------------------------------------------------
  // 🔄 RETRY LOGIC VARIABLES
  // ------------------------------------------------------
  RxList<String> failedUrls = <String>[].obs; // Track failed download URLs
  RxInt failedCount = 0.obs; // Count of failed downloads

  /// Get event-specific sync key
  String get _eventSyncKey => "${Preference.EVENT_SYNC_DONE}_${event.id}";

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

  // ------------------------------------------------------
  // 📸 REAL-TIME PHOTO DETECTION (Server polling)
  // ------------------------------------------------------
  Timer? _photoPollingTimer;
  int _lastKnownPhotoCount = 0;
  bool _isCheckingForPhotos = false;

  // ======================================================
  //  ⭐ EVENT STATE GETTERS (EMPTY PLACEHOLDER CONDITIONS)
  //  🌍 Uses LOCAL timezone conversion for accurate comparisons
  // ======================================================

  /// 1️⃣ Event NOT started yet
  /// Compares current time with event start time in LOCAL timezone
  bool get eventNotStarted => DateTime.now().isBefore(event.localStartDateTime);

  /// 2️⃣ Event already finished
  /// Compares current time with event end time in LOCAL timezone
  bool get eventEnded => DateTime.now().isAfter(event.localEndDateTime);

  /// 3️⃣ Event is currently live (ongoing)
  bool get eventLive => !eventNotStarted && !eventEnded;

  /// 4️⃣ All synced on this device (event-specific)
  bool get allSynced => Preference.box.get(_eventSyncKey) == true;

  /// 5️⃣ No photos uploaded to this event yet (from server)
  bool get noPhotosUploaded => photos.isEmpty && !isLoading.value;

  /// 6️⃣ Event live but no photos yet
  bool get eventLiveButEmpty => eventLive && noPhotosUploaded;

  @override
  void onInit() {
    super.onInit();

    // Register lifecycle observer for app resume detection
    WidgetsBinding.instance.addObserver(this);

    // ------------------------------------------------------
    // 🚀 INITIAL SETUP
    // ------------------------------------------------------
    event = Get.arguments as EventModel;
    albumName = "EventGallery_${event.title.replaceAll(" ", "_")}";

    // Load auto-sync preference
    isAutoSyncEnabled.value = Preference.autoSync;

    fetchPhotos().then((_) {
      // Store initial count for change detection
      _lastKnownPhotoCount = photos.length;

      // Start real-time polling for new photos
      _startPhotoPolling();

      // Auto-sync only if:
      // 1. Auto-sync is enabled
      // 2. Photos exist
      // 3. Not already synced
      // 4. Event has ended (to prevent photo duplication during live event)
      if (isAutoSyncEnabled.value && photos.isNotEmpty && !allSynced && eventEnded) {
        _autoSyncPhotos();
      }
    });
    fetchInvitedUsersCount();
  }

  //----------------------------------------------------
  // 📸 REAL-TIME PHOTO POLLING (Server-side detection)
  //----------------------------------------------------

  /// Start polling server for new photos
  void _startPhotoPolling() {
    // Only poll during live events
    if (eventEnded || eventNotStarted) {
      print("📸 Server polling skipped - event not live");
      return;
    }

    _photoPollingTimer?.cancel();
    _photoPollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkForNewPhotos();
    });
    print("📸 Started server photo polling (10s interval)");
  }

  /// Stop polling for photos
  void _stopPhotoPolling() {
    _photoPollingTimer?.cancel();
    _photoPollingTimer = null;
    print("📸 Stopped server photo polling");
  }

  /// Check server for new photos (optimized - silent check)
  Future<void> _checkForNewPhotos() async {
    // Skip if event not live or download in progress
    if (eventEnded || eventNotStarted || isDownloading.value || isAutoSyncing.value) {
      return;
    }

    // Skip if already checking or loading
    if (_isCheckingForPhotos || isLoading.value) return;

    _isCheckingForPhotos = true;

    try {
      // Quick count check from server
      final hasNewPhotos = await _hasNewPhotosQuickCheck();

      if (hasNewPhotos) {
        print("📸 New photos detected on server - updating gallery");
        await _silentFetchPhotos();
        _lastKnownPhotoCount = photos.length;
      }
    } catch (e) {
      print("📸 Error checking for new photos: $e");
    } finally {
      _isCheckingForPhotos = false;
    }
  }

  /// Quick check if there are new photos on server
  Future<bool> _hasNewPhotosQuickCheck() async {
    try {
      // Check network first
      if (!await _hasNetworkConnection()) return false;

      final result = await PublicApiService().fetchEventPhotos(event.id);
      if (result["data"] == null) return false;

      final serverCount = (result["data"] as List).length;

      if (serverCount != _lastKnownPhotoCount) {
        print("📸 Quick check: count changed from $_lastKnownPhotoCount to $serverCount");
        return true;
      }

      return false;
    } catch (e) {
      print("📸 Quick check error: $e");
      return false;
    }
  }

  /// Silently fetch photos without showing loading state
  Future<void> _silentFetchPhotos() async {
    try {
      final result = await PublicApiService().fetchEventPhotos(event.id);
      if (result["data"] == null) return;

      List<Map<String, dynamic>> allData =
          (result["data"] as List).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();

      List<String> all =
          allData.map<String>((e) => e["fileUrl"].toString()).toList();

      Preference.box.put(Preference.EVENT_GALLERY_CACHE, all);

      // Update UI with new photos
      photos.assignAll(all.take(batchSize).toList());
      photoData.assignAll(allData.take(batchSize).toList());
      loadedCount = photos.length;

      print("📸 Silent fetch complete: ${photos.length} photos loaded");
    } catch (e) {
      print("📸 Silent fetch error: $e");
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
  // 🔄 AUTO SYNC (triggered automatically when enabled - silent download)
  // ------------------------------------------------------
  Future<void> _autoSyncPhotos() async {
    // Skip if already synced for this event
    if (allSynced) return;

    debugPrint("📲 Auto-sync enabled, starting silent background download...");

    // Silent sync - no dialog, just download in background
    if (photos.isEmpty) return;

    // Check permission first before starting
    if (!await askPermission()) {
      debugPrint("❌ Auto-sync cancelled: Permission denied");
      return;
    }

    isAutoSyncing.value = true;
    savedCount(0);
    enableOK(false);
    totalToSave(photos.length);

    // Save images silently (no dialog) - skip permission check since already done
    await _saveImagesWithoutPermissionCheck();
    enableOK(true);
    isAutoSyncing.value = false;

    // Show notification when complete
    LocalNotificationService.show(
      title: AppTexts.NOTIFY_SYNC_COMPLETE_TITLE,
      body: "All photos from '${event.title}' have been saved to your gallery.",
    );

    // Mark as synced (event-specific key)
    Preference.box.put(_eventSyncKey, true);

    debugPrint("✅ Auto-sync complete: ${savedCount.value}/${totalToSave.value} photos saved");
  }

  // ------------------------------------------------------
  // 🧾 FETCH INVITED USERS COUNT
  // ------------------------------------------------------
  Future<void> fetchInvitedUsersCount() async {
    final response = await PublicApiService().getJoinedUsers(event.id!);

    // 📸 Count admin + joined people
    int joinedCount = (response["joinedPeople"] ?? []).length;
    int adminCount = response["admin"] != null ? 1 : 0;
    int totalMembers = adminCount + joinedCount;

    invitedCount.value = totalMembers;
    invitedCount.refresh();

    print("📸 Camera Crew: ${invitedCount.value}/${totalCapacity.value} (Admin: $adminCount, Joined: $joinedCount)");
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

      // 🔄 Refresh member count in parallel (non-blocking)
      // Runs in background so it doesn't delay photo loading
      fetchInvitedUsersCount().catchError((e) {
        debugPrint("⚠️ Failed to refresh member count: $e");
        // Don't block photo loading if count fetch fails
      });
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
  // 🌐 NETWORK CONNECTIVITY CHECK
  // ------------------------------------------------------
  Future<bool> _hasNetworkConnection() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  // ------------------------------------------------------
  // 🔄 SYNC IMAGES
  // ------------------------------------------------------
  Future<void> syncNow() async {
    // Check network connectivity first
    if (!await _hasNetworkConnection()) {
      showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
      return;
    }

    await fetchPhotos();
    if (photos.isEmpty) {
      showCustomSnackBar(AppTexts.NO_IMAGES_FOUND, SnackbarState.warning);
      return;
    }

    // Reset counters
    savedCount(0);
    failedCount(0);
    failedUrls.clear();
    enableOK(false);
    totalToSave(photos.length);
    isDownloading.value = true;

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
          barrierDismissible: false,
        ),
      ),
      barrierDismissible: false,
    );

    await saveImages();
    enableOK(true);
    isDownloading.value = false;

    // Close progress dialog
    Future.delayed(const Duration(seconds: 1), () {
      if (Get.isDialogOpen == true) Get.back();

      // Check if there were failures and show retry dialog
      if (failedUrls.isNotEmpty) {
        _showRetryDialog();
      } else {
        // All photos synced successfully
        LocalNotificationService.show(
          title: AppTexts.NOTIFY_SYNC_COMPLETE_TITLE,
          body: "All photos from '${event.title}' have been saved to your gallery successfully.",
        );
        // Mark as synced (event-specific)
        Preference.box.put(_eventSyncKey, true);
      }
    });
  }

  // ------------------------------------------------------
  // 🔄 RETRY FAILED DOWNLOADS
  // ------------------------------------------------------
  void _showRetryDialog() {
    Get.dialog(
      CustomPopup(
        title: AppTexts.SYNC_FAILED_TITLE,
        message: "${failedCount.value} ${AppTexts.PHOTOS_FAILED_TO_DOWNLOAD}",
        confirmText: AppTexts.ERROR_RETRY,
        cancelText: AppTexts.CANCEL,
        isProcessing: false.obs,
        barrierDismissible: true,
        onConfirm: () {
          Get.back();
          retryFailedDownloads();
        },
      ),
      barrierDismissible: true,
    );
  }

  /// Retry downloading failed photos
  Future<void> retryFailedDownloads() async {
    if (failedUrls.isEmpty) return;

    // Check network before retry
    if (!await _hasNetworkConnection()) {
      showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
      return;
    }

    final urlsToRetry = List<String>.from(failedUrls);

    // Reset counters for retry
    savedCount(0);
    failedCount(0);
    failedUrls.clear();
    enableOK(false);
    totalToSave(urlsToRetry.length);
    isDownloading.value = true;

    Get.dialog(
      Obx(
        () => CustomPopup(
          title: enableOK.value ? "${AppTexts.SYNC_COMPLETE} 🎉" : AppTexts.RETRYING_DOWNLOAD,
          message: enableOK.value
              ? AppTexts.DOWNLOAD_FINISHED
              : AppTexts.DOWNLOADING_IMAGES,
          confirmText: enableOK.value ? AppTexts.CLOSE : AppTexts.PLEASE_WAIT,
          onConfirm: enableOK.value ? () => Get.back() : null,
          isProcessing: enableOK,
          showProgress: true,
          savedCount: savedCount,
          totalCount: totalToSave,
          barrierDismissible: false,
        ),
      ),
      barrierDismissible: false,
    );

    await _saveImagesFromUrls(urlsToRetry);
    enableOK(true);
    isDownloading.value = false;

    Future.delayed(const Duration(seconds: 1), () {
      if (Get.isDialogOpen == true) Get.back();

      // Check if there are still failures
      if (failedUrls.isNotEmpty) {
        _showRetryDialog();
      } else {
        // All photos synced successfully
        LocalNotificationService.show(
          title: AppTexts.NOTIFY_SYNC_COMPLETE_TITLE,
          body: "All photos from '${event.title}' have been saved to your gallery successfully.",
        );
        // Mark as synced (event-specific)
        Preference.box.put(_eventSyncKey, true);
      }
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
    await _saveImagesFromUrls(photos.toList());
  }

  /// Save images from a list of URLs (used by both initial sync and retry)
  Future<void> _saveImagesFromUrls(List<String> urls) async {
    // Use temporary directory for downloading (works on all platforms)
    final tempDir = await getTemporaryDirectory();
    final downloadDir = Directory("${tempDir.path}/$albumName");
    if (!downloadDir.existsSync()) {
      downloadDir.createSync(recursive: true);
    }

    final dio = Dio();
    const int batchSize = 6; // Download 6 images at once

    for (int i = 0; i < urls.length; i += batchSize) {
      final batch = urls.skip(i).take(batchSize).toList();

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
              // Track as failed for retry
              failedUrls.add(url);
              failedCount.value++;
            }
          } catch (e) {
            debugPrint("❌ Save Failed: $e");
            // Track as failed for retry
            failedUrls.add(url);
            failedCount.value++;
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
  // 💾 SAVE IMAGES WITHOUT PERMISSION CHECK (for auto-sync)
  // ------------------------------------------------------
  Future<void> _saveImagesWithoutPermissionCheck() async {
    // Reuse the shared method for consistency
    await _saveImagesFromUrls(photos.toList());
  }

  // ------------------------------------------------------
  // 🔗 SHARE OPTIONS
  // ------------------------------------------------------
  RxString shareLink = "".obs;
  RxBool isGeneratingLink = false.obs;
  final shareLinkController = TextEditingController();

  // ------------------------------------------------------
  // 📤 SHARE BOTTOMSHEET
  // ------------------------------------------------------
  void openShareBottomSheet() {
    // Show bottomsheet first with loading state
    CustomBottomSheet.show(
      title: AppTexts.SHARE_GROUP_TITLE,
      header: _permissionSelector(),
      footer: _shareButton(),
      actions: [],
    );

    // Generate share link with token from API
    _generateShareToken();
  }

  /// Generate share token from API and create share URL
  Future<void> _generateShareToken() async {
    isGeneratingLink.value = true;
    shareLink.value = "";
    shareLinkController.text = "Generating link...";

    try {
      final response = await PublicApiService().shareEvent(event.id!);
      debugPrint("🔗 Share API Response: $response");

      // Check for success (backend returns "status": "success" not "success": true)
      final isSuccess = response["success"] == true ||
                        response["status"] == "success" ||
                        response["shareLink"] != null;

      if (isSuccess) {
        // Extract token from response
        String? token = response["token"] ?? response["shareToken"] ?? response["data"]?["token"];

        // If no direct token, extract from shareLink URL
        if (token == null || token.toString().isEmpty) {
          final link = response["shareLink"] ?? response["link"] ?? response["data"]?["shareLink"] ?? response["data"]?["link"];
          if (link != null && link.toString().isNotEmpty) {
            // Extract token from URL like: /eventresource/share/event/open/{token}
            final uri = Uri.tryParse(link.toString());
            if (uri != null && uri.pathSegments.isNotEmpty) {
              token = uri.pathSegments.last;
              debugPrint("🔗 Extracted token from shareLink: $token");
            }
          }
        }

        if (token != null && token.toString().isNotEmpty) {
          // Construct PUBLIC_EVENT_GALLERY URL with token
          final galleryUrl = "${AppConstants.publicGalleryBaseUrl}/$token";
          shareLink.value = galleryUrl;
          debugPrint("🔗 Constructed PUBLIC_EVENT_GALLERY URL: ${shareLink.value}");
        } else {
          // Fallback: use eventId if no token returned
          debugPrint("⚠️ No token in response, using eventId fallback");
          final galleryUrl = "${AppConstants.publicGalleryBaseUrl}/${event.id}";
          shareLink.value = galleryUrl;
        }

        shareLinkController.text = shareLink.value;
        debugPrint("🔗 Final Share Gallery URL: ${shareLink.value}");
      } else {
        // API failed, show error
        debugPrint("❌ Share API failed: ${response["message"]}");
        showCustomSnackBar(response["message"] ?? "Failed to generate share link", SnackbarState.error);
        shareLink.value = "";
        shareLinkController.text = "Failed to generate link";
      }
    } catch (e) {
      debugPrint("❌ Share API error: $e");
      showCustomSnackBar("Failed to generate share link", SnackbarState.error);
      shareLink.value = "";
      shareLinkController.text = "Failed to generate link";
    } finally {
      isGeneratingLink.value = false;
    }
  }

  Widget _permissionSelector() => Column(
    children: [
      _linkField(),
    ],
  );

  Widget _linkField() => Obx(() => Container(
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
        if (isGeneratingLink.value)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey.shade600,
            ),
          ),
        if (isGeneratingLink.value) SizedBox(width: Get.width * 0.02),
        Expanded(
          child: Text(
            isGeneratingLink.value ? "Generating link..." : shareLink.value.isEmpty ? "Failed to generate link" : shareLink.value,
            style: TextStyle(
              fontSize: Get.width * 0.035,
              color: Colors.grey.shade700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: Get.width * 0.02),
        GestureDetector(
          onTap: shareLink.value.isEmpty ? null : () {
            Clipboard.setData(ClipboardData(text: shareLink.value));
            showCustomSnackBar(AppTexts.COPIED, SnackbarState.success);
          },
          child: Icon(
            Icons.copy_outlined,
            size: Get.width * 0.055,
            color: shareLink.value.isEmpty ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    ),
  ));

  /// Generate formatted share message with event details
  String get _shareMessage {
    return "📸 You're invited to view photos from \"${event.title}\"\n\n"
        "🔗 View Gallery:\n${shareLink.value}\n\n"
        "Shared via BellyButton";
  }

  Widget _shareButton() => Obx(() => global_button(
    title: AppTexts.SHARE_LINK,
    backgroundColor: AppColors.primaryColor,
    isLoading: isGeneratingLink.value,
    onTap: shareLink.value.isEmpty ? null : () {
      Get.back(); // Close bottomsheet first
      Share.share(
        _shareMessage,
        subject: event.title,
      );
    },
  ));

  // ------------------------------------------------------
  // ⚡ FAB ACTIONS
  // ------------------------------------------------------
  void fabOneAction() => openShareBottomSheet();

  /// Navigate to reinvite flow with existing event
  Future<void> fabTwoAction() async {
    try {
      // 🔥 Fetch event data and all invitations (PENDING + ACCEPTED) in parallel
      final results = await Future.wait([
        PublicApiService().getEventById(event.id!),
        PublicApiService().getAllInvitations(event.id!),
      ]);

      final eventData = results[0] as EventModel?;
      final invitations = results[1] as List<Map<String, dynamic>>;

      if (eventData == null) {
        showCustomSnackBar(
          "Failed to load event details. Please try again.",
          SnackbarState.error,
        );
        return;
      }

      // 🔥 Merge invitations into event data
      final eventWithInvitations = EventModel(
        id: eventData.id,
        title: eventData.title,
        description: eventData.description,
        eventDate: eventData.eventDate,
        startTime: eventData.startTime,
        endTime: eventData.endTime,
        timezone: eventData.timezone,
        timezoneOffset: eventData.timezoneOffset,
        creatorId: eventData.creatorId,
        status: eventData.status,
        imagePath: eventData.imagePath,
        shareToken: eventData.shareToken,
        invitedPeople: invitations, // Use invitations from new endpoint
      );

      print("📋 Reinvite: Loaded event with ${invitations.length} invitations (PENDING + ACCEPTED)");

      // Navigate to invite screen with reinvite arguments
      Get.to(
        () {
          // Initialize controller with fresh instance
          Get.delete<InviteuserController>();
          Get.put(InviteuserController());
          return InviteuserView();
        },
        arguments: InviteUserArguments.reinvite(eventWithInvitations),
      );
    } catch (e) {
      debugPrint("❌ Failed to fetch event details: $e");
      showCustomSnackBar(
        "Failed to load event details. Please try again.",
        SnackbarState.error,
      );
    }
  }

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
            style: AppText.headingLg.copyWith(
              color: isDark ? Colors.white70 : AppColors.textColor,
              fontSize: width * 0.045,
            ),
          ),
          SizedBox(height: Get.height * 0.01),
          Text(
            AppTexts.MEDIA_INFO_EMPTY_DESC,
            textAlign: TextAlign.center,
            style: AppText.bodyMd.copyWith(
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
              style: AppText.labelLg.copyWith(
                fontSize: width * 0.035,
                color: isDark ? Colors.white70 : AppColors.textColor2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppText.titleMd.copyWith(
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

  // ------------------------------------------------------
  // 🔙 HANDLE BACK NAVIGATION
  // ------------------------------------------------------
  void handleBackNavigation() {
    // If download is in progress, show confirmation dialog
    if (isDownloading.value || isAutoSyncing.value) {
      Get.dialog(
        CustomPopup(
          title: AppTexts.DISCARD_CHANGES_TITLE,
          message: AppTexts.DOWNLOADING_IMAGES,
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

    // No download in progress, navigate back normally
    Get.back();
  }

  //----------------------------------------------------
  // CLEANUP
  //----------------------------------------------------
  @override
  void onClose() {
    // Stop photo polling
    _stopPhotoPolling();

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    shareLinkController.dispose();
    super.onClose();
  }
}
