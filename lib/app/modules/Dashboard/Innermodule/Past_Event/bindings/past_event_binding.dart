import 'package:get/get.dart';

import '../controllers/past_event_controller.dart';

class PastEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PastEventController>(
      () => PastEventController(),
      fenix: false, // Don't auto-recreate - let GetBuilder manage lifecycle
    );
  }
}
