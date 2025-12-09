// ignore_for_file: avoid_print, unnecessary_overrides, file_names

import 'package:get/get.dart';
import '../api/PublicApiService.dart';
import '../database/models/EventModel.dart';

class EventController extends GetxController {
  // ==========================
  // 1️⃣ Dependencies & Observables
  // ==========================
  final PublicApiService apiService = PublicApiService();

  var isLoading = false.obs;
  var eventData = <EventModel>[].obs;
  var errorMessage = ''.obs;

  // ==========================
  // 2️⃣ Lifecycle Method - onInit
  // ==========================
  @override
  void onInit() {
    super.onInit();
    fetchAllEvents();
  }

  // ==========================
  // 3️⃣ Fetch All Events
  // ==========================
  Future<void> fetchAllEvents() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final events = await apiService.getAllEvents();
      print("📦 All Events Response: ${events.length} items");

      if (events.isNotEmpty) {
        eventData.assignAll(events);
      } else {
        errorMessage.value = 'No events found';
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        errorMessage.value = 'No internet connection';
      } else {
        errorMessage.value = 'Error loading events: $e';
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================
  // 4️⃣ Upcoming Events (Event hasn't ended yet - sorted soonest first)
  // ==========================
  List<EventModel> get upcomingEvents {
    final now = DateTime.now();
    // Event is upcoming if end time hasn't passed yet
    final upcoming =
        eventData.where((e) => e.fullEventEndDateTime.isAfter(now)).toList()
          ..sort((a, b) => a.fullEventDateTime.compareTo(b.fullEventDateTime));

    print("📅 Upcoming: ${upcoming.map((e) => '${e.title}: ${e.fullEventDateTime} - ${e.fullEventEndDateTime}')}");
    return upcoming;
  }

  // ==========================
  // 5️⃣ Past Events (Event has ended - sorted most recent first)
  // ==========================
  List<EventModel> get pastEvents {
    final now = DateTime.now();
    // Event is past only after end time has passed
    final past =
        eventData.where((e) => e.fullEventEndDateTime.isBefore(now)).toList()
          ..sort((a, b) => b.fullEventEndDateTime.compareTo(a.fullEventEndDateTime));

    print("🕓 Past: ${past.map((e) => '${e.title}: ended ${e.fullEventEndDateTime}')}");
    return past;
  }

  // ==========================
  // 7️⃣ Retry Fetch Events
  // ==========================
  void retryFetch() => fetchAllEvents();
}
