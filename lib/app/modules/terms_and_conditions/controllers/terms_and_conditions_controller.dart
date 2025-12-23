import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/PublicApiService.dart';

class TermsAndConditionsController extends GetxController {
  RxBool isLoading = true.obs;
  RxString content = "".obs;
  RxString errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchTermsAndConditions();
  }

  Future<void> fetchTermsAndConditions() async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await PublicApiService().getTermsAndConditions();

      if (response["content"] != null) {
        content.value = response["content"];
      } else if (response["data"] != null && response["data"]["content"] != null) {
        content.value = response["data"]["content"];
      } else {
        errorMessage.value = response["message"] ?? "No content available";
      }
    } catch (e) {
      debugPrint("Error fetching terms: $e");
      errorMessage.value = "Failed to load content. Please try again.";
    } finally {
      isLoading.value = false;
    }
  }
}
