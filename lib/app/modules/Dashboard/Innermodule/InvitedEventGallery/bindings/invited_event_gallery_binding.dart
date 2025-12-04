import 'package:get/get.dart';

import '../controllers/invited_event_gallery_controller.dart';

class InvitedEventGalleryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvitedEventGalleryController>(
      () => InvitedEventGalleryController(),
    );
  }
}
