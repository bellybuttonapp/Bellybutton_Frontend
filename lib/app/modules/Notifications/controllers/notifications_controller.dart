import 'package:get/get.dart';

class NotificationsController extends GetxController {
  var isLoading = false.obs;

  //TODO: Implement NotificationsController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  // New: Button tap handler
  void goToBack() async {
    try {
      isLoading.value = true;

      // Simulate some async operation, e.g., API call or navigation delay
      await Future.delayed(const Duration(seconds: 2));
      Get.back();
      // TODO: Add actual navigation or logic here
      print('Button tapped, proceed to next step');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
