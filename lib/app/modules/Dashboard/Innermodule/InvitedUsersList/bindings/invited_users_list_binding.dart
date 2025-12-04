import 'package:get/get.dart';

import '../controllers/invited_users_list_controller.dart';

class InvitedUsersListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvitedUsersListController>(
      () => InvitedUsersListController(),
    );
  }
}
