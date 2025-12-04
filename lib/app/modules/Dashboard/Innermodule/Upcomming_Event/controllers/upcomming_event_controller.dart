// ignore_for_file: avoid_print

import 'package:get/get.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../database/models/EventModel.dart';
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../routes/app_pages.dart';

class UpcommingEventController extends GetxController {
  final PublicApiService apiService = PublicApiService();

  final isLoading = false.obs;
  final isProcessing = false.obs;
  final eventData = <EventModel>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUpcomingEvents();
  }

  // ============================================================
  // ✅ FIXED: Fetch Upcoming Events (Sort by real date + time)
  // ============================================================
  Future<void> fetchUpcomingEvents() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final events = await apiService.getAllEvents();
      print("📦 All Events Response: ${events.length} items");

      final now = DateTime.now();

      // 🎯 Correct upcoming logic
      final upcoming =
          events.where((e) => e.fullEventDateTime.isAfter(now)).toList()..sort(
            (a, b) => a.fullEventDateTime.compareTo(b.fullEventDateTime),
          );

      if (upcoming.isEmpty) {
        errorMessage.value = 'No upcoming events found';
      }

      eventData.assignAll(upcoming);
    } catch (e) {
      errorMessage.value = 'Something went wrong: $e';
      print("❌ Fetch Events Error: $e");
    } finally {
      isLoading.value = false;
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

      if (response["headers"]["status"] == "success") {
        if (Get.isDialogOpen ?? false) Get.back();

        await fetchUpcomingEvents();

        showCustomSnackBar(
          response["headers"]["message"],
          SnackbarState.success,
        );
      } else {
        showCustomSnackBar(response["headers"]["message"], SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar("Unexpected error: $e", SnackbarState.error);
    } finally {
      isProcessing.value = false;
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
  }

  // ============================================================
  // 🔄 Retry Fetch
  // ============================================================
  void retryFetch() => fetchUpcomingEvents();
}
