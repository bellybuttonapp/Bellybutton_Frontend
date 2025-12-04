import 'package:get/get.dart';

import '../controllers/photo_pre_controller.dart';

class PhotoPreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhotoPreController>(
      () => PhotoPreController(),
    );
  }
}
