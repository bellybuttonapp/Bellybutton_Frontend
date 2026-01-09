// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/utils/index.dart';
import '../../../../global_widgets/Button/global_button.dart';
import '../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../controllers/profile_setup_controller.dart';

class ProfileSetupView extends GetView<ProfileSetupController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GetBuilder<ProfileSetupController>(
      builder: (controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFBACCCC),
        body: Stack(
          children: [
            // Background Gradient - Full top area
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.45,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.1399, 0.274],
                    colors: [
                      Color(0xFF070B17),
                      Color(0xFF060F1E),
                      Color(0xFF051938),
                    ],
                  ),
                ),
              ),
            ),

            // Profile Picture 1 - Top Left
            Positioned(
              top: screenHeight * 0.08,
              left: screenWidth * 0.05,
              child: _buildProfileCircle(
                AppImages.PROFILE_1,
                screenWidth * 0.14,
              ),
            ),

            // Profile Picture 2 - Top Right
            Positioned(
              top: screenHeight * 0.06,
              right: screenWidth * 0.08,
              child: _buildProfileCircle(
                AppImages.PROFILE_2,
                screenWidth * 0.12,
              ),
            ),

            // Profile Picture 3 - Middle Left
            Positioned(
              top: screenHeight * 0.22,
              left: screenWidth * 0.12,
              child: _buildProfileCircle(
                AppImages.PROFILE_3,
                screenWidth * 0.11,
              ),
            ),

            // Profile Picture 4 - Middle Right
            Positioned(
              top: screenHeight * 0.18,
              right: screenWidth * 0.05,
              child: _buildProfileCircle(
                AppImages.PROFILE_4,
                screenWidth * 0.15,
              ),
            ),

            // White Form Card - Overlaps background
            Positioned(
              top: screenHeight * 0.35,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.textColor3,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(screenWidth * 0.07),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.035,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        AppTexts.PROFILE_SETUP_TITLE,
                        style: customBoldText.copyWith(
                          fontSize: screenWidth * 0.055,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),

                      // Subtitle
                      Text(
                        AppTexts.PROFILE_SETUP_SUBTITLE,
                        style: customMediumText.copyWith(
                          fontSize: screenWidth * 0.035,
                          color: AppColors.tertiaryColor,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Name Field
                      Obx(
                        () => GlobalTextField(
                          controller: controller.nameController,
                          focusNode: controller.nameFocusNode,
                          hintText: AppTexts.PROFILE_SETUP_NAME_HINT,
                          keyboardType: TextInputType.name,
                          errorText: controller.nameError.value,
                          onChanged: controller.validateName,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Bio Field
                      GlobalTextField(
                        controller: controller.bioController,
                        focusNode: controller.bioFocusNode,
                        hintText: AppTexts.PROFILE_SETUP_BIO_HINT,
                        keyboardType: TextInputType.text,
                        maxLines: 3,
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Continue Button
                      Obx(
                        () => global_button(
                          loaderWhite: true,
                          title: AppTexts.PROFILE_SETUP_CONTINUE,
                          onTap: controller.isLoading.value
                              ? null
                              : controller.saveProfile,
                          isLoading: controller.isLoading.value,
                          backgroundColor: isDarkMode
                              ? AppTheme.darkTheme.scaffoldBackgroundColor
                              : AppTheme.lightTheme.primaryColor,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // User Profile Image - Centered in the visible background area
            Positioned(
              top: screenHeight * 0.12,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: controller.pickImage,
                  child: Obx(() {
                    final pickedImage = controller.pickedImage.value;

                    return Stack(
                      children: [
                        Container(
                          height: screenWidth * 0.26,
                          width: screenWidth * 0.26,
                          decoration: BoxDecoration(
                            color: AppColors.textColor3,
                            borderRadius: BorderRadius.circular(screenWidth * 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: pickedImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(pickedImage.path),
                                    fit: BoxFit.cover,
                                    width: screenWidth * 0.26,
                                    height: screenWidth * 0.26,
                                  ),
                                )
                              : Center(
                                  child: SvgPicture.asset(
                                    AppImages.PERSON,
                                    height: screenWidth * 0.1,
                                    width: screenWidth * 0.1,
                                    color: AppColors.tertiaryColor,
                                  ),
                                ),
                        ),
                        // Camera icon overlay
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: screenWidth * 0.04,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build profile circle images
  Widget _buildProfileCircle(String imagePath, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primaryColor.withOpacity(0.3),
              child: Icon(
                Icons.person,
                size: size * 0.5,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
