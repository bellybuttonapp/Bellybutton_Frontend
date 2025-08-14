import 'package:get/get.dart';

import '../controllers/account_details_controller.dart';

class AccountDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountDetailsController>(
      () => AccountDetailsController(),
    );
  }
}
