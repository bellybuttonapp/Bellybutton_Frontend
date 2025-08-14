import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  var isLoading = false.obs;

  void goToNext() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 2));
    isLoading.value = false;
    Get.offNamed(Routes.LOGIN); // ✅ Cannot go back to onboarding
  }
}
