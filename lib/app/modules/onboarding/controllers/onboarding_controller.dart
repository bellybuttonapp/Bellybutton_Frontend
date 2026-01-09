import 'package:get/get.dart';
import '../../../core/utils/storage/preference.dart';
import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final isLoading = false.obs;

  /// Navigate to Phone Login and mark onboarding as complete
  Future<void> goToNext() async {
    isLoading.value = true;

    // Small delay for button animation
    await Future.delayed(const Duration(milliseconds: 300));

    // Mark onboarding as complete
    Preference.onboardingComplete = true;

    // Navigate to Phone Login
    Get.offAllNamed(Routes.PHONE_LOGIN);
  }
}
