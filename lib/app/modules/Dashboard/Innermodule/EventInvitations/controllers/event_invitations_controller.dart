import 'package:get/get.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../core/constants/app_texts.dart';
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

  // 📅 SORT: PENDING first, then by date+time (upcoming first)
  void _sortByDateTime() {
    final now = DateTime.now();

    invitedEvents.sort((a, b) {
      // 1️⃣ PENDING events always come first
      if (a.isPending && !b.isPending) return -1;
      if (!a.isPending && b.isPending) return 1;

      // 2️⃣ Parse date+time safely
      DateTime dateA;
      DateTime dateB;
      try {
        dateA = a.eventStartDateTime;
      } catch (_) {
        dateA = DateTime(2099); // fallback to far future
      }
      try {
        dateB = b.eventStartDateTime;
      } catch (_) {
        dateB = DateTime(2099);
      }

      // 3️⃣ Upcoming events (future) come before past events
      final aIsUpcoming = dateA.isAfter(now);
      final bIsUpcoming = dateB.isAfter(now);

      if (aIsUpcoming && !bIsUpcoming) return -1;
      if (!aIsUpcoming && bIsUpcoming) return 1;

      // 4️⃣ Within same category: nearest date first (ascending)
      return dateA.compareTo(dateB);
    });

    invitedEvents.refresh();
  }

  /// ======================= FETCH INVITATIONS =======================
  Future<void> loadInvitedEvents() async {
    try {
      isLoading(true);
      invitedEvents.clear();

      final events = await PublicApiService().getInvitedEvents();
      invitedEvents.assignAll(events);
      _sortByDateTime();
    } catch (e) {
      showCustomSnackBar(AppTexts.UNABLE_TO_FETCH_INVITED_EVENTS, SnackbarState.error);
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
          "${AppTexts.EVENT_ACCEPTED} ${event.title}",
          SnackbarState.success,
        );
      } else {
        showCustomSnackBar(AppTexts.FAILED_TO_ACCEPT_EVENT, SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
    }
  }

  /// ======================= DENY INVITATION =======================
  Future<void> denyInvitation(InvitedEventModel event) async {
    try {
      final res = await PublicApiService().denyInvitedEvent(event.eventId);

      if (res['message'] == "Event Denied") {
        invitedEvents.remove(event); // Instant removal

        showCustomSnackBar("${AppTexts.EVENT_DENIED} ${event.title}", SnackbarState.error);
      } else {
        showCustomSnackBar(AppTexts.FAILED_TO_DENY_EVENT, SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar(AppTexts.UNABLE_TO_PROCESS_REQUEST, SnackbarState.error);
    }
  }

  /// ======================= NAVIGATE =======================
  void openInvitedGallery(InvitedEventModel event) {
    Get.toNamed(Routes.INVITED_EVENT_GALLERY, arguments: event);
  }
}
