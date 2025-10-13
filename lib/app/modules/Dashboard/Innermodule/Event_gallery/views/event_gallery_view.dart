import 'package:bellybutton/app/global_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../controllers/event_gallery_controller.dart';
import 'package:shimmer/shimmer.dart';

class EventGalleryView extends GetView<EventGalleryController> {
  const EventGalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: AppTexts.Event),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.01), // reduced space
            _buildTitleField(screenWidth),
            _buildDescriptionField(),
            const SizedBox(height: 12),
            // Skeleton grid placeholder
            Expanded(child: _buildSkeletonGrid(screenWidth)),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(double screenWidth) {
    return GlobalTextField(
      hintText: AppTexts.EventTitle,
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
                // color: Colors.black,
                app_images.userscount,
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

  Widget _buildDescriptionField() {
    return GlobalTextField(
      hintText: AppTexts.Description,
      obscureText: false,
      keyboardType: TextInputType.multiline,
      maxLines: 2,
    );
  }

  // Skeleton grid loader widget with shimmer
  Widget _buildSkeletonGrid(double screenWidth) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Number of columns
          mainAxisSpacing: 08,
          crossAxisSpacing: 08,
          childAspectRatio: 1, // Make items square
        ),
        itemCount: 100, // Number of skeleton items
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
          );
        },
      ),
    );
  }
}
