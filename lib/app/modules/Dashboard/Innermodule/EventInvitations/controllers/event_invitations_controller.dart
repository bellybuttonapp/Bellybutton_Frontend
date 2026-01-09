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

  Future<void> _acceptInvitation(InvitedEventModel event) async {
    isProcessing.value = true;
    try {
      final res = await PublicApiService().acceptInvitedEvent(event.eventId);

      // Check for success using headers.status (preferred) or message fallback
      final status = res['headers']?['status'];
      final isSuccess = status == "success" || res['message'] == "Event Accepted Successfully";

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
      } else {
        isProcessing.value = false;
        showCustomSnackBar(AppTexts.FAILED_TO_ACCEPT_SHOOT, SnackbarState.error);
      }
    } catch (e) {
      isProcessing.value = false;
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
    }
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
