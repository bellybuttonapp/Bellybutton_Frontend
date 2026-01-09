// ignore_for_file: unnecessary_overrides, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/services/event_invitations_service.dart';
import '../../../../../database/models/EventModel.dart';
import '../../../../../database/models/InvitedEventModel.dart';
import '../../../../../database/models/UnifiedEventModel.dart';
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../routes/app_pages.dart';

class PastEventController extends GetxController {
  final PublicApiService apiService = PublicApiService();

  final isLoading = false.obs;
  final isProcessing = false.obs;
  final isDenyProcessing = false.obs;
  final pastEvents = <EventModel>[].obs;
  final unifiedEvents = <UnifiedEventModel>[].obs;
  final errorMessage = ''.obs;

  /// Access to global invitations service
  EventInvitationsService get _invitationsService => EventInvitationsService.to;

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

      // Fetch both owned events and invited events
      final events = await apiService.getAllEvents();
      await _invitationsService.fetchInvitations();
      final invitedEvents = _invitationsService.invitations;

      print("📦 All Events Response: ${events.length} items");
      print("📨 Invited Events: ${invitedEvents.length} items");

      final now = DateTime.now();

      // Filter past owned events
      final pastOwned = events
          .where((e) => e.localEndDateTime.isBefore(now))
          .map((e) => UnifiedEventModel.fromOwned(e))
          .toList();

      // Filter past invited events (PENDING + ACCEPTED)
      final pastInvited = invitedEvents
          .where((e) => e.localEndDateTime.isBefore(now))
          .map((e) => UnifiedEventModel.fromInvited(e))
          .toList();

      // Merge and sort by end time (most recent first)
      final allPast = [...pastOwned, ...pastInvited]
        ..sort((a, b) => b.localEndDateTime.compareTo(a.localEndDateTime));

      if (allPast.isEmpty) {
        errorMessage.value = 'No past events found';
      }

      // Update both lists
      pastEvents.assignAll(events.where((e) => e.localEndDateTime.isBefore(now)).toList());
      unifiedEvents.assignAll(allPast);
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
      title: AppTexts.DELETE_SHOOT,
      message: "Are you sure you want to delete '${event.title}'?",
      confirmText: AppTexts.DELETE,
      processingState: isProcessing,          // ✅ FIX
    confirmButtonColor: AppColors.error,    // optional (red)
    cancelButtonColor: AppColors.primaryColor,      // optional
      onConfirm: () async {
        await deleteEvent(event.id!);
      },
  
    );
  }

void _showConfirmationDialog({
  required String title,
  required String message,
  required String confirmText,
  required VoidCallback onConfirm,
 required RxBool processingState, // ✅ FIX
  Color? confirmButtonColor,
  Color? cancelButtonColor,
}) {
  Get.dialog(
    CustomPopup(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: AppTexts.CANCEL,
      isProcessing: processingState,
      confirmButtonColor: confirmButtonColor,
      cancelButtonColor: cancelButtonColor,
      onConfirm: onConfirm,
    ),
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

  // ============================================================
  // 📨 INVITATION METHODS (Accept/Deny)
  // ============================================================

  /// Show accept confirmation popup
  void showAcceptConfirmation(InvitedEventModel event) {
    Get.dialog(
      CustomPopup(
        title: AppTexts.ACCEPT_SHOOT_POPUP_TITLE,
        message: AppTexts.ACCEPT_SHOOT_POPUP_SUBTITLE,
        confirmText: AppTexts.ACCEPT,
        cancelText: AppTexts.CANCEL,
        isProcessing: isProcessing,
        onConfirm: () => _acceptInvitation(event),
      ),
    );
  }

  Future<void> _acceptInvitation(InvitedEventModel event) async {
    isProcessing.value = true;
    try {
      final res = await apiService.acceptInvitedEvent(event.eventId);

      final status = res['headers']?['status'];
      final isSuccess = status == "success" || res['message'] == "Event Accepted Successfully";

      if (isSuccess) {
        _invitationsService.markAsAccepted(event.eventId);
        isProcessing.value = false;
        Get.back();

        showCustomSnackBar(
          "${AppTexts.SHOOT_ACCEPTED} ${event.title}",
          SnackbarState.success,
        );

        // Refresh the list
        await fetchPastEvents();
      } else {
        isProcessing.value = false;
        showCustomSnackBar(AppTexts.FAILED_TO_ACCEPT_SHOOT, SnackbarState.error);
      }
    } catch (e) {
      isProcessing.value = false;
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
    }
  }

  /// Show deny confirmation popup
  void showDenyConfirmation(InvitedEventModel event) {
    Get.dialog(
      CustomPopup(
        title: AppTexts.DENY_SHOOT_POPUP_TITLE,
        message: AppTexts.DENY_SHOOT_POPUP_SUBTITLE,
        confirmText: AppTexts.DENY,
        cancelText: AppTexts.CANCEL,
        isProcessing: isDenyProcessing,
        onConfirm: () => _denyInvitation(event),
        confirmButtonColor: AppColors.error,
        cancelButtonColor: AppColors.primaryColor,
      ),
    );
  }

  Future<void> _denyInvitation(InvitedEventModel event) async {
    isDenyProcessing.value = true;
    try {
      final res = await apiService.denyInvitedEvent(event.eventId);

      final status = res['headers']?['status'];
      final isSuccess = status == "success" || res['message'] == "Event Denied Successfully";

      if (isSuccess) {
        _invitationsService.removeInvitation(event.eventId);
        isDenyProcessing.value = false;
        Get.back();

        showCustomSnackBar("${AppTexts.SHOOT_DENIED} ${event.title}", SnackbarState.error);

        // Refresh the list
        await fetchPastEvents();
      } else {
        isDenyProcessing.value = false;
        showCustomSnackBar(AppTexts.FAILED_TO_DENY_SHOOT, SnackbarState.error);
      }
    } catch (e) {
      isDenyProcessing.value = false;
      showCustomSnackBar(AppTexts.UNABLE_TO_PROCESS_REQUEST, SnackbarState.error);
    }
  }

  /// Navigate to invited event gallery
  void openInvitedGallery(InvitedEventModel event) {
    Get.toNamed(Routes.INVITED_EVENT_GALLERY, arguments: event);
  }
}
