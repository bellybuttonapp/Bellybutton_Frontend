import 'package:get/get.dart';

import '../controllers/shared_event_gallery_controller.dart';

class SharedEventGalleryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SharedEventGalleryController>(
      () => SharedEventGalleryController(),
    );
  }
}