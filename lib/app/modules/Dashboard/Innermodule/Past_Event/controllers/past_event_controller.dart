// ignore_for_file: unnecessary_overrides, non_constant_identifier_names

import 'package:get/get.dart';

class PastEventController extends GetxController {
  var isLoading = false.obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  // New: Button tap handler


  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
