// ignore_for_file: avoid_print, unnecessary_overrides

import 'package:get/get.dart';

class UpcommingEventController extends GetxController {
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

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  // New: Button tap handler

}
