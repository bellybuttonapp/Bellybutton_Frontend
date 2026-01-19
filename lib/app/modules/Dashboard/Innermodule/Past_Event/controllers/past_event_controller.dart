// ignore_for_file: unnecessary_overrides, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
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

  // Start with true to show shimmer while initializing
  final isLoading = true.obs;
  final isProcessing = false.obs;
  final isDenyProcessing = false.obs;
  final pastEvents = <EventModel>[].obs;
  final unifiedEvents = <UnifiedEventModel>[].obs;
  final errorMessage = ''.obs;

  // Pagination state
  static const int _pageSize = 10;
  final displayedEvents = <UnifiedEventModel>[].obs;
  final isLoadingMore = false.obs;
  final hasMoreEvents = true.obs;

  // NOTE: RefreshController is now owned by the View, not the Controller.
  // This prevents "Don't use one refreshController to multiple SmartRefresher" errors.

  /// Access to global invitations service
  EventInvitationsService get _invitationsService => EventInvitationsService.to;

  @override
  void onInit() {
    super.onInit();
    fetchPastEvents();
  }

  // ============================================================
  // ✅ Fetch REAL Past Events (date + time)
  // ============================================================
  Future<void> fetchPastEvents() async {
    // Allow fetch even if isLoading is true (for initial load)
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

      // Reset pagination
      _resetPagination();
    } catch (e) {
      errorMessage.value = 'Error fetching past events: $e';
      print("❌ Fetch Past Events Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ============================================================
  // 📄 PAGINATION
  // ============================================================
  void _resetPagination() {
    final initialCount = _pageSize.clamp(0, unifiedEvents.length);
    displayedEvents.assignAll(unifiedEvents.take(initialCount).toList());
    hasMoreEvents.value = unifiedEvents.length > initialCount;
  }

  /// Load more events for pagination
  /// [refreshController] is passed from the View to avoid lifecycle issues
  Future<void> loadMoreEvents(RefreshController refreshController) async {
    if (isLoadingMore.value || !hasMoreEvents.value) {
      refreshController.loadComplete();
      return;
    }

    isLoadingMore.value = true;

    // Simulate slight delay for smooth UX
    await Future.delayed(const Duration(milliseconds: 300));

    // Check if still active after delay
    if (isClosed) return;

    final currentCount = displayedEvents.length;
    final nextBatch = unifiedEvents
        .skip(currentCount)
        .take(_pageSize)
        .toList();

    displayedEvents.addAll(nextBatch);
    hasMoreEvents.value = displayedEvents.length < unifiedEvents.length;

    isLoadingMore.value = false;

    if (hasMoreEvents.value) {
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
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
      processingState: isProcessing,
      confirmButtonColor: AppColors.error,
      cancelButtonColor: AppColors.primaryColor,
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
    required RxBool processingState,
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

  Future<void> _acceptInvitation(InvitedEventModel event, {bool force = false}) async {
    isProcessing.value = true;
    try {
      final res = await apiService.acceptInvitedEvent(event.eventId, force: force);

      final status = res['headers']?['status'];
      final message = res['message'] ?? '';
      final isSuccess = status == "success" || message == "Event Accepted Successfully";

      // Check for time conflict
      final isTimeConflict = message.toString().toLowerCase().contains('time conflict');

      // Extract conflicting event details if present
      final conflictingEvent = res['conflictingEvent'] as Map<String, dynamic>?;

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
      } else if (isTimeConflict && !force) {
        // Only show conflict dialog if not already forcing
        isProcessing.value = false;
        Get.back(); // Close the accept confirmation dialog
        _showTimeConflictDialog(event, conflictingEvent: conflictingEvent);
      } else {
        isProcessing.value = false;
        showCustomSnackBar(AppTexts.FAILED_TO_ACCEPT_SHOOT, SnackbarState.error);
      }
    } catch (e) {
      isProcessing.value = false;
      // Check if error message contains time conflict
      if (e.toString().toLowerCase().contains('time conflict') && !force) {
        Get.back();
        _showTimeConflictDialog(event);
      } else {
        showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
      }
    }
  }

  /// Build conflict message with event details
  String _buildConflictMessage(Map<String, dynamic>? conflictingEvent) {
    if (conflictingEvent == null) {
      return AppTexts.TIME_CONFLICT_MESSAGE;
    }

    final title = conflictingEvent['title'] ?? 'Unknown Shoot';
    final date = conflictingEvent['date'] ?? '';
    final startTime = conflictingEvent['startTime'] ?? '';
    final endTime = conflictingEvent['endTime'] ?? '';

    String timeRange = '';
    if (startTime.toString().isNotEmpty && endTime.toString().isNotEmpty) {
      timeRange = '$startTime - $endTime';
    } else if (startTime.toString().isNotEmpty) {
      timeRange = startTime.toString();
    }

    return "${AppTexts.TIME_CONFLICT_WITH_EVENT}\n\n"
        "$title\n"
        "${date.toString().isNotEmpty ? '$date\n' : ''}"
        "${timeRange.isNotEmpty ? timeRange : ''}";
  }

  /// Show time conflict dialog with Accept Anyway option
  void _showTimeConflictDialog(InvitedEventModel event, {Map<String, dynamic>? conflictingEvent}) {
    Get.dialog(
      CustomPopup(
        title: AppTexts.TIME_CONFLICT_TITLE,
        message: _buildConflictMessage(conflictingEvent),
        confirmText: AppTexts.ACCEPT_ANYWAY,
        cancelText: AppTexts.CANCEL,
        onConfirm: () {
          Get.back(); // Close conflict dialog
          _acceptInvitation(event, force: true); // Force accept
        },
        isProcessing: isProcessing,
      ),
    );
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
