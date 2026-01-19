import 'package:get/get.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/services/event_invitations_service.dart';
import '../../../../../database/models/InvitedEventModel.dart';
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../routes/app_pages.dart';

class EventInvitationsController extends GetxController {
  /// Access to global invitations service
  EventInvitationsService get _invitationsService => EventInvitationsService.to;

  /// List of invitation events (from service)
  RxList<InvitedEventModel> get invitedEvents => _invitationsService.invitations;

  /// Shimmer loading state (from service)
  RxBool get isLoading => _invitationsService.isLoading;

  /// Processing state for popups
  RxBool isProcessing = false.obs;
  RxBool isDenyProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInvitedEvents();
  }

  /// ======================= FETCH INVITATIONS =======================
  Future<void> loadInvitedEvents() async {
    try {
      await _invitationsService.fetchInvitations();
    } catch (e) {
      showCustomSnackBar(AppTexts.UNABLE_TO_FETCH_INVITED_SHOOTS, SnackbarState.error);
    }
  }

  /// ======================= ACCEPT INVITATION =======================
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
      final res = await PublicApiService().acceptInvitedEvent(event.eventId, force: force);

      // Check for success using headers.status (preferred) or message fallback
      final status = res['headers']?['status'];
      final message = res['message'] ?? '';
      final isSuccess = status == "success" || message == "Event Accepted Successfully";

      // Check for time conflict
      final isTimeConflict = message.toString().toLowerCase().contains('time conflict') ||
                              message.toString().toLowerCase().contains('already have another event') ||
                              message.toString().toLowerCase().contains('at this time');

      // Extract conflicting event details if present
      final conflictingEvent = res['conflictingEvent'] as Map<String, dynamic>?;

      if (isSuccess) {
        // Update via service (updates badge automatically)
        _invitationsService.markAsAccepted(event.eventId);

        // Set processing to false BEFORE closing dialog
        isProcessing.value = false;

        Get.back(); // Close the popup

        showCustomSnackBar(
          "${AppTexts.SHOOT_ACCEPTED} ${event.title}",
          SnackbarState.success,
        );
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

  /// ======================= DENY INVITATION =======================
  void showDenyConfirmation(InvitedEventModel event) {
    Get.dialog(
      CustomPopup(
        title: AppTexts.DENY_SHOOT_POPUP_TITLE,
        message: AppTexts.DENY_SHOOT_POPUP_SUBTITLE,
        confirmText: AppTexts.DENY,
        cancelText: AppTexts.CANCEL,
        isProcessing: isDenyProcessing,
        onConfirm: () => _denyInvitation(event),
        // 🔥 Same styling pattern as Delete Account
        confirmButtonColor: AppColors.error,
        cancelButtonColor: AppColors.primaryColor,
      ),
    );
  }

  Future<void> _denyInvitation(InvitedEventModel event) async {
    isDenyProcessing.value = true;
    try {
      final res = await PublicApiService().denyInvitedEvent(event.eventId);

      // Check for success using headers.status (preferred) or message fallback
      final status = res['headers']?['status'];
      final isSuccess = status == "success" || res['message'] == "Event Denied Successfully";

      if (isSuccess) {
        // Remove via service (updates badge automatically)
        _invitationsService.removeInvitation(event.eventId);

        // Set processing to false BEFORE closing dialog
        isDenyProcessing.value = false;

        Get.back(); // Close the popup

        showCustomSnackBar("${AppTexts.SHOOT_DENIED} ${event.title}", SnackbarState.error);
      } else {
        isDenyProcessing.value = false;
        showCustomSnackBar(AppTexts.FAILED_TO_DENY_SHOOT, SnackbarState.error);
      }
    } catch (e) {
      isDenyProcessing.value = false;
      showCustomSnackBar(AppTexts.UNABLE_TO_PROCESS_REQUEST, SnackbarState.error);
    }
  }

  /// ======================= NAVIGATE =======================
  void openInvitedGallery(InvitedEventModel event) {
    Get.toNamed(Routes.INVITED_EVENT_GALLERY, arguments: event);
  }
}
