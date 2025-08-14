import 'package:get/get.dart';

import '../controllers/upcomming_event_controller.dart';

class UpcommingEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpcommingEventController>(
      () => UpcommingEventController(),
    );
  }
}
