// ignore_for_file: avoid_print

import 'package:get/get.dart';
import '../../api/PublicApiService.dart';
import '../../database/models/InvitedEventModel.dart';

/// Global service to manage event invitations state across the app
/// Similar to NotificationService - provides badge count for invitations
class EventInvitationsService extends GetxService {
  static EventInvitationsService get to => Get.find<EventInvitationsService>();

  final PublicApiService _apiService = PublicApiService();

  final invitations = <InvitedEventModel>[].obs;
  final isLoading = false.obs;

  /// Count of pending invitations (for badge)
  int get pendingCount => invitations.where((i) => i.isPending).length;

  /// Check if there are any invitations
  bool get hasInvitations => invitations.isNotEmpty;

  /// Check if there are pending invitations
  bool get hasPendingInvitations => pendingCount > 0;

  Future<EventInvitationsService> init() async {
    await fetchInvitations();
    return this;
  }

  /// Fetch all invited events from API
  Future<void> fetchInvitations() async {
    try {
      isLoading.value = true;
      final result = await _apiService.getInvitedEvents();
      invitations.value = result;
      _sortByDateTime();
      print('📨 Fetched ${result.length} invitations ($pendingCount pending)');
    } catch (e) {
      print('❌ Error fetching invitations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sort invitations: PENDING first, then by date
  void _sortByDateTime() {
    final now = DateTime.now();

    invitations.sort((a, b) {
      // 1️⃣ PENDING events always come first
      if (a.isPending && !b.isPending) return -1;
      if (!a.isPending && b.isPending) return 1;

      // 2️⃣ Parse date+time safely (use local timezone)
      DateTime dateA;
      DateTime dateB;
      try {
        dateA = a.localStartDateTime;
      } catch (_) {
        dateA = DateTime(2099);
      }
      try {
        dateB = b.localStartDateTime;
      } catch (_) {
        dateB = DateTime(2099);
      }

      // 3️⃣ Upcoming events come before past events
      final aIsUpcoming = dateA.isAfter(now);
      final bIsUpcoming = dateB.isAfter(now);

      if (aIsUpcoming && !bIsUpcoming) return -1;
      if (!aIsUpcoming && bIsUpcoming) return 1;

      // 4️⃣ Within same category: nearest date first
      return dateA.compareTo(dateB);
    });

    invitations.refresh();
  }

  /// Mark invitation as accepted (optimistic update)
  void markAsAccepted(int eventId) {
    final index = invitations.indexWhere((i) => i.eventId == eventId);
    if (index != -1) {
      invitations[index].status = "ACCEPTED";
      invitations.refresh();
      print('✅ Invitation $eventId marked as accepted');
    }
  }

  /// Remove invitation from list (after deny)
  void removeInvitation(int eventId) {
    invitations.removeWhere((i) => i.eventId == eventId);
    invitations.refresh();
    print('🗑️ Invitation $eventId removed');
  }

  /// Refresh invitations
  Future<void> refresh() async {
    await fetchInvitations();
  }
}
