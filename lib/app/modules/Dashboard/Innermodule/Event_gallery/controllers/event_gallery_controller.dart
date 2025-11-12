// ignore_for_file: unnecessary_overrides

import 'package:get/get.dart';
import '../../../../../database/models/EventModel.dart';

class EventGalleryController extends GetxController {
  late final EventModel event;

  @override
  void onInit() {
    super.onInit();
    event = Get.arguments as EventModel;
  }
}
