// ignore_for_file: avoid_print, deprecated_member_use, depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../../api/PublicApiService.dart';
import '../../../core/constants/app_texts.dart';
import '../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';

class SharedEventGalleryController extends GetxController {
  // ------------------------------------------------------
  // 📌 STATIC: For initial route (when app opens directly to this screen)
  // ------------------------------------------------------
  static String? pendingToken;

  // ------------------------------------------------------
  // 📌 EVENT DATA (from public API)
  // ------------------------------------------------------
  RxString galleryToken = "".obs; // Token or eventId used to fetch gallery
  RxString eventTitle = "".obs;
  RxString eventDescription = "".obs;

  // ------------------------------------------------------
  // 📌 GALLERY CONTROL VARIABLES
  // ------------------------------------------------------
  RxBool isLoading = true.obs;

  // ------------------------------------------------------
  // 📷 PHOTOS DATA
  // ------------------------------------------------------
  RxList<String> photos = <String>[].obs;

  // ------------------------------------------------------
  // 🖼 PAGINATION
  // ------------------------------------------------------
  int batchSize = 100;
  int loadedCount = 0;
  List<String> _allPhotos = [];

  @override
  void onInit() {
    super.onInit();

    // Enable screenshot protection
    _enableScreenshotProtection();

    // Get token from arguments OR static pendingToken (for initial route)
    final args = Get.arguments;

    if (args is String) {
      // Direct token passed via navigation
      galleryToken.value = args;
    } else if (args is int) {
      // Legacy: event ID passed as int (convert to string)
      galleryToken.value = args.toString();
    } else if (args is Map<String, dynamic>) {
      // Map with token or eventId
      galleryToken.value = (args["token"] ?? args["eventId"] ?? "").toString();
      eventTitle.value = args["title"] ?? "";
      eventDescription.value = args["description"] ?? "";
    } else if (pendingToken != null) {
      // From initial route (app opened directly to this screen)
      galleryToken.value = pendingToken!;
      pendingToken = null; // Clear after use
    }

    if (galleryToken.value.isEmpty) {
      print("❌ No token provided to SharedEventGalleryController");
      showCustomSnackBar(AppTexts.DEEPLINK_INVALID_LINK, SnackbarState.error);
      return;
    }

    print("📌 SharedEventGallery opened for token: ${galleryToken.value}");

    fetchPhotos();
  }

  @override
  void onClose() {
    // Disable screenshot protection when leaving
    _disableScreenshotProtection();
    super.onClose();
  }

  // ------------------------------------------------------
  // 🖼 FETCH PUBLIC EVENT PHOTOS
  // ------------------------------------------------------
  Future<void> fetchPhotos({bool loadMore = false}) async {
    if (!loadMore) {
      isLoading.value = true;
      _allPhotos = [];
      loadedCount = 0;
    }

    try {
      final result = await PublicApiService().fetchPublicEventGallery(galleryToken.value);

      print("📦 API Response: $result");

      if (result["data"] == null && result["photos"] == null) {
        isLoading.value = false;
        return;
      }

      // Handle different response formats
      List<dynamic> rawData = result["data"] ?? result["photos"] ?? [];

      // Extract photo URLs from response
      List<String> allUrls = [];
      for (var item in rawData) {
        if (item is String) {
          allUrls.add(item);
        } else if (item is Map) {
          // Handle object format: {fileUrl: "...", id: ...}
          final url = item["fileUrl"] ?? item["url"] ?? item["photo"];
          if (url != null) {
            allUrls.add(url.toString());
          }
        }
      }

      _allPhotos = allUrls;

      // Extract event info if available
      if (result["event"] != null) {
        final event = result["event"];
        eventTitle.value = event["title"] ?? "";
        eventDescription.value = event["description"] ?? "";
      } else if (result["title"] != null) {
        eventTitle.value = result["title"] ?? "";
        eventDescription.value = result["description"] ?? "";
      }

      if (!loadMore) {
        photos.assignAll(_allPhotos.take(batchSize).toList());
        loadedCount = photos.length;
      } else {
        int next = loadedCount + batchSize;
        if (next > _allPhotos.length) next = _allPhotos.length;

        photos.addAll(_allPhotos.sublist(loadedCount, next));
        loadedCount = next;
      }

      print("🔼 Loaded: $loadedCount / ${_allPhotos.length}");
    } catch (e) {
      print("❌ Error fetching photos: $e");
      showCustomSnackBar(AppTexts.FAILED_TO_LOAD_PHOTOS, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if there are more photos to load
  bool get hasMorePhotos => loadedCount < _allPhotos.length;

  // ------------------------------------------------------
  // 🔒 SCREENSHOT PROTECTION
  // ------------------------------------------------------

  /// Enable screenshot and screen recording protection
  void _enableScreenshotProtection() async {
    try {
      // Use only preventScreenshotOn() which is safer for Android
      // protectDataLeakageOn() can cause white screen on Android
      await ScreenProtector.preventScreenshotOn();

      print("🔒 Screenshot protection enabled");
    } catch (e) {
      // Silently fail if protection is not available on the platform
      print('⚠️ Screenshot protection error: $e');
    }
  }

  /// Disable screenshot protection when leaving this page
  void _disableScreenshotProtection() async {
    try {
      await ScreenProtector.preventScreenshotOff();

      print("🔓 Screenshot protection disabled");
    } catch (e) {
      print('⚠️ Error disabling screenshot protection: $e');
    }
  }
}
