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
  // 4️⃣ Upcoming Events (Sorted Soonest First)
  // ==========================
  List<EventModel> get upcomingEvents {
    final now = DateTime.now();
    final upcoming =
        eventData.where((e) => e.fullEventDateTime.isAfter(now)).toList()
          ..sort((a, b) => a.fullEventDateTime.compareTo(b.fullEventDateTime));

    print("📅 Upcoming: ${upcoming.map((e) => e.fullEventDateTime)}");
    return upcoming;
  }

  // ==========================
  // 5️⃣ Past Events (Sorted Most Recent First)
  // ==========================
  List<EventModel> get pastEvents {
    final now = DateTime.now();
    final past =
        eventData.where((e) => e.fullEventDateTime.isBefore(now)).toList()
          ..sort((a, b) => b.fullEventDateTime.compareTo(a.fullEventDateTime));

    print("🕓 Past: ${past.map((e) => e.fullEventDateTime)}");
    return past;
  }

 

  // ==========================
  // 7️⃣ Retry Fetch Events
  // ==========================
  void retryFetch() => fetchAllEvents();
}
