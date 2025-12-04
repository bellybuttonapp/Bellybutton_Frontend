// ignore_for_file: unnecessary_overrides, avoid_print, non_constant_identifier_names

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../Notifications/views/notifications_view.dart';
import '../Innermodule/EventInvitations/views/event_invitations_view.dart';
import '../Innermodule/create_event/views/create_event_view.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;

  void goToNotificationView() {
    HapticFeedback.mediumImpact();

    Get.to(
      () => NotificationsView(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 300),
    );

    // 🔥 Notify GetBuilder widgets (if any part depends on this)
    update();
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
