import 'package:bellybutton/app/modules/Notifications/views/notifications_view.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  //TODO: Implement DashboardController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  void goToNotificationView() {
    print("Notification button tapped");
    Get.to(
      () => NotificationsView(),
      transition: Transition.fade, // You can use slide, rightToLeft, etc.
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
