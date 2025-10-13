import 'package:get/get.dart';

import '../controllers/event_gallery_controller.dart';

class EventGalleryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventGalleryController>(
      () => EventGalleryController(),
    );
  }
}
