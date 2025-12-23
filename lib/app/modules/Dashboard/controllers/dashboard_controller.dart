// ignore_for_file: unnecessary_overrides, avoid_print, non_constant_identifier_names

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../../Notifications/views/notifications_view.dart';
import '../Innermodule/EventInvitations/views/event_invitations_view.dart';
import '../Innermodule/create_event/views/create_event_view.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;

  // Timer for periodic notification refresh
  Timer? _notificationRefreshTimer;

  // Access the shared notification service
  NotificationService get _notificationService => NotificationService.to;

  // Expose unread count from the shared service
  int get unreadNotificationCount => _notificationService.unreadCount;

  @override
  void onInit() {
    super.onInit();
    // Fetch notifications when entering Dashboard
    _fetchNotifications();
    // Set up periodic refresh every 30 seconds
    _startPeriodicRefresh();
  }

  @override
  void onClose() {
    _notificationRefreshTimer?.cancel();
    super.onClose();
  }

  void _fetchNotifications() {
    _notificationService.fetchNotifications();
  }

  void _startPeriodicRefresh() {
    _notificationRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _notificationService.fetchNotifications(),
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

  void goToEventInvitationsView() {
    HapticFeedback.mediumImpact();

    Get.to(
      () => EventInvitationsView(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 300),
    );

    // 🔥 Notify GetBuilder widgets (if any part depends on this)
    update();
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