// ignore_for_file: unnecessary_string_interpolations

import 'package:get/get.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/services/local_notification_service.dart';
import '../../../../../database/models/InvitedEventModel.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../routes/app_pages.dart';

class EventInvitationsController extends GetxController {
  /// List of invitation events
  RxList<InvitedEventModel> invitedEvents = <InvitedEventModel>[].obs;

  /// Shimmer loading state
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadInvitedEvents();
  }

  // 📅 TIME + DATE SORT FUNCTION
  void _sortByDateTime() {
    invitedEvents.sort((a, b) {
      DateTime dateA = DateTime.parse(
        a.eventDate,
      ); // ← Replace if field differs
      DateTime dateB = DateTime.parse(b.eventDate);

      return dateA.compareTo(dateB); // oldest → latest
    });

    invitedEvents.refresh();
  }

  /// ======================= FETCH INVITATIONS =======================
  Future<void> loadInvitedEvents() async {
    try {
      isLoading(true);

      int oldCount = invitedEvents.length; // 🔥 store before fetching
      invitedEvents.clear();

      final events = await PublicApiService().getInvitedEvents();
      invitedEvents.assignAll(events);
      _sortByDateTime(); // 🔥 Sort after load

      // 📩 New Invitation Notification Logic
      if (events.length > oldCount) {
        LocalNotificationService.show(
          title: AppTexts.NOTIFY_NEW_INVITE_TITLE,
          body: "${AppTexts.NOTIFY_NEW_INVITE_BODY}",
        );
      }
    } catch (e) {
      showCustomSnackBar("Unable to fetch invited events", SnackbarState.error);
    } finally {
      isLoading(false);
    }
  }

  /// ======================= ACCEPT INVITATION =======================
  Future<void> acceptInvitation(InvitedEventModel event) async {
    try {
      final res = await PublicApiService().acceptInvitedEvent(event.eventId);

      if (res['message'] == "Event Accepted Successfully") {
        event.status = "ACCEPTED"; // Instant UI change
        invitedEvents.refresh(); // Notify GetX UI

        showCustomSnackBar(
          "You accepted ${event.title}",
          SnackbarState.success,
        );
      } else {
        showCustomSnackBar("Failed to accept event", SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong", SnackbarState.error);
    }
  }

  /// ======================= DENY INVITATION =======================
  Future<void> denyInvitation(InvitedEventModel event) async {
    try {
      final res = await PublicApiService().denyInvitedEvent(event.eventId);

      if (res['message'] == "Event Denied") {
        invitedEvents.remove(event); // Instant removal

        showCustomSnackBar("You denied ${event.title}", SnackbarState.error);
      } else {
        showCustomSnackBar("Failed to deny event", SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar("Unable to process request", SnackbarState.error);
    }
  }

  /// ======================= NAVIGATE =======================
  void openInvitedGallery(InvitedEventModel event) {
    Get.toNamed(Routes.INVITED_EVENT_GALLERY, arguments: event);
  }
}
