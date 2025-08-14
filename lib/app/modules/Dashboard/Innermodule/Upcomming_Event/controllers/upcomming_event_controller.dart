import 'package:get/get.dart';

class UpcommingEventController extends GetxController {
  var isLoading = false.obs;

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
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

  // New: Button tap handler
  void goToNext() async {
    try {
      isLoading.value = true;

      // Simulate some async operation, e.g., API call or navigation delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Add actual navigation or logic here
      print('Button tapped, proceed to next step');
    } finally {
      isLoading.value = false;
    }
  }
}
