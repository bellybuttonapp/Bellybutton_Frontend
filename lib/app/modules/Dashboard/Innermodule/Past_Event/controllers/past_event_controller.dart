// ignore_for_file: unnecessary_overrides, avoid_print

import 'package:get/get.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../database/models/EventModel.dart';
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../routes/app_pages.dart';

class PastEventController extends GetxController {
  final PublicApiService apiService = PublicApiService();

  final isLoading = false.obs;
  final isProcessing = false.obs;
  final pastEvents = <EventModel>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPastEvents();
  }

  // ============================================================
  // ✅ FIXED: Fetch REAL Past Events (date + time)
  // ============================================================
  Future<void> fetchPastEvents() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      update();

      final events = await apiService.getAllEvents();
      print("📦 All Events Response: ${events.length} items");

      final now = DateTime.now();

      // 🔥 Use fullEventEndDateTime — event is "past" only after end time
      final past =
          events.where((e) => e.fullEventEndDateTime.isBefore(now)).toList()
            ..sort(
              (a, b) => b.fullEventEndDateTime.compareTo(a.fullEventEndDateTime),
            );

      if (past.isEmpty) {
        errorMessage.value = 'No past events found';
      }

      pastEvents.assignAll(past);
    } catch (e) {
      errorMessage.value = 'Error fetching past events: $e';
      print("❌ Fetch Past Events Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ============================================================
  // 🗑️ Delete Event
  // ============================================================
  Future<void> deleteEvent(int eventId) async {
    if (isProcessing.value) return;

    try {
      isProcessing.value = true;

      final response = await apiService.deleteEvent(eventId);

      // Try to extract message from multiple possible shapes
      final String respMessage =
          (response["message"] as String?) ??
          (response["headers"] is Map
              ? (response["headers"]["message"] as String?)
              : null) ??
          "Event deleted successfully";

      final bool success =
          response["success"] == true ||
          (response["headers"] is Map &&
              (response["headers"]["status"] == "success"));

      if (success) {
        // Close any open dialog or bottom sheet safely
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        // GetX exposes isBottomSheetOpen
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }

        // Refresh list before showing message so UI is up-to-date
        await fetchPastEvents();

        showCustomSnackBar(respMessage, SnackbarState.success);
      } else {
        // Extract error message if available
        final String errorMsg =
            (response["message"] as String?) ??
            (response["headers"] is Map
                ? (response["headers"]["message"] as String?)
                : null) ??
            "Failed to delete event";

        showCustomSnackBar(errorMsg, SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar("Unexpected error: $e", SnackbarState.error);
    } finally {
      isProcessing.value = false;
      update();
    }
  }

  // ============================================================
  // 🧾 Delete Confirmation
  // ============================================================
  void confirmDelete(EventModel event) {
    _showConfirmationDialog(
      title: AppTexts.DELETE_EVENT,
      message: "Are you sure you want to delete '${event.title}'?",
      confirmText: AppTexts.DELETE,
      onConfirm: () async {
        await deleteEvent(event.id!);
      },
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Future<void> Function() onConfirm,
  }) {
    Get.dialog(
      CustomPopup(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: AppTexts.CANCEL,
        isProcessing: isProcessing,
        onConfirm: onConfirm,
      ),
      barrierDismissible: false,
    );
  }

  // ============================================================
  // ✏️ Edit Event
  // ============================================================
  void editEvent(EventModel event) {
    print('Editing Event: ${event.title}');
    if (Get.isDialogOpen ?? false) Get.back();

    Future.delayed(const Duration(milliseconds: 150), () {
      Get.toNamed(Routes.CREATE_EVENT, arguments: event);
    });

    update();
  }

  // ============================================================
  // 🔄 Retry Fetch
  // ============================================================
  void retryFetch() {
    fetchPastEvents();
    update();
  }
}
