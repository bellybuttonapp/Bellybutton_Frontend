// ignore_for_file: unnecessary_overrides, avoid_print, non_constant_identifier_names

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../../Notifications/views/notifications_view.dart';
import '../Innermodule/create_event/views/create_event_view.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;

  // Timer for periodic refresh
  Timer? _refreshTimer;

  // Tab index for navigation (0 = Upcoming, 1 = Past)
  final initialTabIndex = 0.obs;

  // Access the shared services (use Get.find with null safety for race conditions)
  NotificationService get _notificationService => NotificationService.to;

  // Expose unread count from the shared service
  int get unreadNotificationCount => _notificationService.unreadCount;

  @override
  void onInit() {
    super.onInit();
    // Check if initial tab index was passed via arguments
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      initialTabIndex.value = args['initialTabIndex'] ?? 0;
    }
    // Defer data fetching to avoid setState during build
    Future.microtask(() {
      // Fetch notifications when entering Dashboard
      _fetchData();
      // Set up periodic refresh every 30 seconds
      _startPeriodicRefresh();
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    // Note: Child controllers (UpcommingEventController, PastEventController)
    // are managed by GetBuilder in their respective views.
    // Do NOT delete them here - let GetX handle their lifecycle automatically.
    super.onClose();
  }

  void _fetchData() {
    _notificationService.fetchNotifications();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        _notificationService.fetchNotifications();
      },
    );
  }

  void goToNotificationView() {
    HapticFeedback.mediumImpact();

    Get.to(
      () =>  NotificationsView(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> CreateEvent() async {
    isLoading.value = true;
    print("➡ Navigating to Create Event");

    // 🔥 optional update for GetBuilder UI (not required for Obx)
    update();

    await Future.delayed(const Duration(milliseconds: 300));

    Get.to(
      () => CreateEventView(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 450),
    );

    isLoading.value = false;

    // 🔥 Refresh GetBuilder after turning off loader (again optional)
    update();
  }
}