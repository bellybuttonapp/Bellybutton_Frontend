// ignore_for_file: avoid_print

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

class UpcommingEventController extends GetxController {
  final PublicApiService apiService = PublicApiService();

  final isLoading = false.obs;
  final isProcessing = false.obs;
  final isDenyProcessing = false.obs;
  final eventData = <EventModel>[].obs;
  final unifiedEvents = <UnifiedEventModel>[].obs;
  final errorMessage = ''.obs;

  /// Access to global invitations service
  EventInvitationsService get _invitationsService => EventInvitationsService.to;

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

      // Fetch both owned events and invited events
      final events = await apiService.getAllEvents();
      await _invitationsService.fetchInvitations();
      final invitedEvents = _invitationsService.invitations;

      print("📦 All Events Response: ${events.length} items");
      print("📨 Invited Events: ${invitedEvents.length} items");

      final now = DateTime.now();

      // Filter upcoming owned events
      final upcomingOwned = events
          .where((e) => e.localEndDateTime.isAfter(now))
          .map((e) => UnifiedEventModel.fromOwned(e))
          .toList();

      // Filter upcoming invited events (PENDING + ACCEPTED)
      final upcomingInvited = invitedEvents
          .where((e) => e.localEndDateTime.isAfter(now))
          .map((e) => UnifiedEventModel.fromInvited(e))
          .toList();

      // Merge and sort by start time (nearest first)
      final allUpcoming = [...upcomingOwned, ...upcomingInvited]
        ..sort((a, b) => a.localStartDateTime.compareTo(b.localStartDateTime));

      if (allUpcoming.isEmpty) {
        errorMessage.value = 'No upcoming events found';
      }

      // Update both lists
      eventData.assignAll(events.where((e) => e.localEndDateTime.isAfter(now)).toList());
      unifiedEvents.assignAll(allUpcoming);
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
      title: AppTexts.DELETE_SHOOT,
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
        await fetchUpcomingEvents();
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
        await fetchUpcomingEvents();
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
