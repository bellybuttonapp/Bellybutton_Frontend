// ignore_for_file: annotate_overrides

import 'package:bellybutton/app/global_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_texts.dart';
import '../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  final NotificationsController controller = Get.put(NotificationsController());
  NotificationsView({super.key});
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppTexts.NOTIFICATION),
      body: EmptyJobsPlaceholder(
        imagePath: AppImages.OBJECT,
        title: AppTexts.NO_NOTIFICATION,
        description: AppTexts.NOTIFICATION_SUBTITLE,
        isLoading: controller.isLoading, // RxBool
        buttonText: AppTexts.GO_BACK, // String
        onButtonTap: controller.goToBack, // VoidCallback
      ),
    );
  }
}
