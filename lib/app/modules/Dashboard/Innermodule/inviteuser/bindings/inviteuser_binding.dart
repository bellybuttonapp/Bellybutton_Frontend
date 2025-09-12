import 'package:get/get.dart';

import '../controllers/inviteuser_controller.dart';

class InviteuserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InviteuserController>(
      () => InviteuserController(),
    );
  }
}
