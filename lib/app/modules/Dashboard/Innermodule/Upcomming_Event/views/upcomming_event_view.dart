// ignore_for_file: annotate_overrides

import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../controllers/upcomming_event_controller.dart';

class UpcommingEventView extends GetView<UpcommingEventController> {
  final UpcommingEventController controller = Get.put(
    UpcommingEventController(),
  );
  UpcommingEventView({super.key});

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
        description: AppTexts.upcomingEmpty,
      ),
    );
  }
}
