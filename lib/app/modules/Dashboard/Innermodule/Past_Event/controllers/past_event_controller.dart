import 'package:bellybutton/app/modules/Dashboard/Innermodule/create_event/views/create_event_view.dart';
import 'package:get/get.dart';

class PastEventController extends GetxController {
  var isLoading = false.obs;

  //TODO: Implement PastEventController

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
  void PastEventViewCreate() async {
    try {
      isLoading.value = true;

      // Simulate some async operation, e.g., API call or navigation delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Add actual navigation or logic here
      Get.to(CreateEventView());
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
