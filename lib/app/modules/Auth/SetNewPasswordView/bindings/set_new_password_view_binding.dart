import 'package:get/get.dart';

import '../controllers/set_new_password_view_controller.dart';

class SetNewPasswordViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SetNewPasswordViewController>(
      () => SetNewPasswordViewController(),
    );
  }
}
