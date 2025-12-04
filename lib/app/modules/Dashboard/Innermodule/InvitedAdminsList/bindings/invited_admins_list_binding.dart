import 'package:get/get.dart';

import '../controllers/invited_admins_list_controller.dart';

class InvitedAdminsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvitedAdminsListController>(
      () => InvitedAdminsListController(),
    );
  }
}
