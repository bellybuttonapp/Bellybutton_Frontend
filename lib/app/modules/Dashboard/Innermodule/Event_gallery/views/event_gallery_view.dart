// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:bellybutton/app/global_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../../../../../global_widgets/Shimmers/EventGalleryShimmer.dart';
import '../controllers/event_gallery_controller.dart';

class EventGalleryView extends GetView<EventGalleryController> {
  @override
  Widget build(BuildContext context) {
    // ✅ Initialize controller with event data passed from previous screen
    final controller = Get.put(EventGalleryController());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: AppTexts.EVENT),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.01),
            _buildTitleField(screenWidth, controller),
            _buildDescriptionField(controller),
            const SizedBox(height: 12),
            Expanded(child: _buildSkeletonGrid(screenWidth)),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(
    double screenWidth,
    EventGalleryController controller,
  ) {
    return GlobalTextField(
      hintText: AppTexts.EVENT_TITLE,
      initialValue: controller.event.title ?? '',
      obscureText: false,
      keyboardType: TextInputType.text,
      suffixIcon: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.01,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(40, 166, 216, 233),
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppImages.USERS_COUNT,
                width: screenWidth * 0.045,
                height: screenWidth * 0.045,
              ),
              SizedBox(width: screenWidth * 0.015),
              const Text(
                "01/05",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(EventGalleryController controller) {
    return GlobalTextField(
      hintText: AppTexts.DESCRIPTION,
      initialValue: controller.event.description ?? '',
      obscureText: false,
      keyboardType: TextInputType.multiline,
      maxLines: 2,
    );
  }

  Widget _buildSkeletonGrid(double screenWidth) {
    return const EventGalleryShimmer(itemCount: 100, crossAxisCount: 4);
  }
}
