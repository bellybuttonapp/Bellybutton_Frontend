import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../controllers/past_event_controller.dart';

class PastEventView extends GetView<PastEventController> {
  final PastEventController controller = Get.put(PastEventController());
  PastEventView({super.key});
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      body: EmptyJobsPlaceholder(
        imagePath: app_images.upevent,
        description: app_texts.upcommingEmpty,
        isLoading: controller.isLoading, // RxBool
        buttonText: app_texts.Create_event, // String
        onButtonTap: controller.PastEventViewCreate, // VoidCallback
      ),
    );
  }
}
