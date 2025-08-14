import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../controllers/upcomming_event_controller.dart';

class UpcommingEventView extends GetView<UpcommingEventController> {
  final UpcommingEventController controller = Get.put(
    UpcommingEventController(),
  );
  UpcommingEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmptyJobsPlaceholder(
        imagePath: app_images.upevent,
        description: app_texts.upcommingEmpty,
        isLoading: controller.isLoading, // RxBool
        buttonText: app_texts.Create_event, // String
        onButtonTap: controller.goToNext, // VoidCallback
      ),
    );
  }
}
