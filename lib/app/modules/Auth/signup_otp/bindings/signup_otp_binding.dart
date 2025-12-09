import 'package:get/get.dart';

import '../controllers/signup_otp_controller.dart';

class SignupOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupOtpController>(
      () => SignupOtpController(),
    );
  }
}
