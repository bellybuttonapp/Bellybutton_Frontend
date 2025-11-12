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

  // Reactive state variables
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
  // ✅ Fetch All Past Events
  // ============================================================
  Future<void> fetchPastEvents() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final events = await apiService.getAllEvents();
      print("📦 All Events Response: ${events.length} items");

      final now = DateTime.now();
      final past =
          events.where((e) => e.eventDate.isBefore(now)).toList()
            ..sort((a, b) => b.eventDate.compareTo(a.eventDate));

      if (past.isEmpty) {
        errorMessage.value = 'No past events found';
      }

      pastEvents.assignAll(past);
    } catch (e) {
      errorMessage.value = 'Error fetching past events: $e';
      print("❌ Fetch Past Events Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // 🗑️ Delete Event by ID (API + Local)
  // ============================================================
  Future<void> deleteEvent(int eventId) async {
    if (isProcessing.value) return; // Prevent multiple deletions

    try {
      isProcessing.value = true;
      print("🗑️ Deleting event with ID: $eventId ...");

      final response = await apiService.deleteEvent(eventId);

      if (response["success"] == true) {
        // ✅ Close popup if open
        if (Get.isDialogOpen ?? false) Get.back();

        // ✅ Remove from local list
        pastEvents.removeWhere((event) => event.id == eventId);

        showCustomSnackBar(
          response["message"] ?? "Event deleted successfully",
          SnackbarState.success,
        );
      } else {
        showCustomSnackBar(
          response["message"] ?? "Failed to delete event",
          SnackbarState.error,
        );
      }
    } catch (e) {
      print("❌ Delete Event Error: $e");
      showCustomSnackBar("Unexpected error: $e", SnackbarState.error);
    } finally {
      isProcessing.value = false;
    }
  }

  // ============================================================
  // 🧾 Public Wrapper for Delete Confirmation
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

  // ============================================================
  // 💬 Private Confirmation Dialog Helper
  // ============================================================
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
  // ✏️ Edit Event → Navigate to Create Event Page
  // ============================================================
  void editEvent(EventModel event) {
    print('Editing Event: ${event.title}');
    print('Current route: ${Get.currentRoute}');
    if (Get.isDialogOpen ?? false) Get.back();

    Future.delayed(const Duration(milliseconds: 150), () {
      Get.toNamed(Routes.CREATE_EVENT, arguments: event);
    });
  }

  // ============================================================
  // 🔄 Retry Fetch
  // ============================================================
  void retryFetch() => fetchPastEvents();
}
