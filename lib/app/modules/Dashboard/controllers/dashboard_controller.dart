// ignore_for_file: unnecessary_overrides, avoid_print, non_constant_identifier_names

import 'package:bellybutton/app/modules/Notifications/views/notifications_view.dart';
import 'package:get/get.dart';

import '../Innermodule/create_event/views/create_event_view.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;

  void onButtonTap() {
    isLoading.value = true;
    print("Bottom button tapped");

    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      print("Action Completed");
    });
  }

  void goToNotificationView() {
    print("Notification button tapped");
    Get.to(
      () => NotificationsView(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 300),
    );
  }

  void CreateEvent() async {
    try {
      isLoading.value = true;
      await Future.delayed(
        const Duration(milliseconds: 200),
      ); // Let UI show loader

      // Simulate some operation
      await Future.delayed(const Duration(seconds: 2));

      // Navigate with custom transition animation
      Get.to(
        () => CreateEventView(),
        transition: Transition.rightToLeft, // Slide from right
        duration: const Duration(
          milliseconds: 500,
        ), // Smooth animation duration
      );

      print('Button tapped, proceed to next step');
    } finally {
      isLoading.value = false;
    }
  }
}
