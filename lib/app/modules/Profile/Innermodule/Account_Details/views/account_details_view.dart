// ignore_for_file: annotate_overrides, deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../../../global_widgets/loader/global_loader.dart';
import '../controllers/account_details_controller.dart';
import 'package:bellybutton/app/core/utils/index.dart';

class AccountDetailsView extends GetView<AccountDetailsController> {
  final AccountDetailsController controller = Get.put(
    AccountDetailsController(),
  );

  final _formKey = GlobalKey<FormState>();

  AccountDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Get the image URL to use
    String? getImageUrl() {
      final picked = controller.pickedImage.value;
      final savedImage = Preference.profileImage ?? '';

      if (picked != null) return picked.path;
      if (savedImage.isNotEmpty) return savedImage;
      return null;
    }

    bool isLocalFile(String? url) {
      if (url == null || url.isEmpty) return false;
      return !url.startsWith('http');
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.discardChanges();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor:
            isDarkMode
                ? AppTheme.darkTheme.scaffoldBackgroundColor
                : AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: AppTexts.ACCOUNT_DETAILS,
          onBackPressed: controller.discardChanges,
        ),
        body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: screenWidth * 0.05,
          right: screenWidth * 0.05,
          top: screenHeight * 0.04,
          bottom: bottomInset + screenHeight * 0.04,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// PROFILE IMAGE
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Obx(
                      () {
                        final imageUrl = getImageUrl();
                        final isLocal = isLocalFile(imageUrl);
                        final radius = screenWidth * 0.16;
                        final iconSize = screenWidth * 0.08;
                        final bgColor = const Color.fromARGB(255, 166, 216, 233).withOpacity(0.15);

                        Widget buildImage() {
                          // No image
                          if (imageUrl == null || imageUrl.isEmpty) {
                            return CircleAvatar(
                              radius: radius,
                              backgroundColor: bgColor,
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: SvgPicture.asset(
                                  AppImages.PERSON,
                                  height: iconSize,
                                  width: iconSize,
                                  color: AppColors.textColor.withOpacity(0.7),
                                ),
                              ),
                            );
                          }

                          // Local file
                          if (isLocal) {
                            final file = File(imageUrl);
                            if (file.existsSync()) {
                              return CircleAvatar(
                                radius: radius,
                                backgroundColor: bgColor,
                                backgroundImage: FileImage(file),
                              );
                            }
                            return CircleAvatar(
                              radius: radius,
                              backgroundColor: bgColor,
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: SvgPicture.asset(
                                  AppImages.PERSON,
                                  height: iconSize,
                                  width: iconSize,
                                  color: AppColors.textColor.withOpacity(0.7),
                                ),
                              ),
                            );
                          }

                          // Network image with caching
                          return CachedNetworkImage(
                            imageUrl: imageUrl,
                            imageBuilder: (context, imageProvider) => CircleAvatar(
                              radius: radius,
                              backgroundColor: bgColor,
                              backgroundImage: imageProvider,
                            ),
                            placeholder: (context, url) => CircleAvatar(
                              radius: radius,
                              backgroundColor: bgColor,
                              child: Global_Loader(
                                size: iconSize * 0.6,
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (context, url, error) => CircleAvatar(
                              radius: radius,
                              backgroundColor: bgColor,
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: SvgPicture.asset(
                                  AppImages.PERSON,
                                  height: iconSize,
                                  width: iconSize,
                                  color: AppColors.textColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                          );
                        }

                        return Hero(
                          tag: 'profile-photo',
                          child: buildImage(),
                        );
                      },
                    ),
                    Positioned(
                      bottom: screenWidth * 0.015,
                      right: screenWidth * 0.015,
                      child: GestureDetector(
                        onTap: controller.pickImage,
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.015),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppImages.CAMERA_ADD_ICON,
                            color: AppColors.textColor3,
                            width: screenWidth * 0.045,
                            height: screenWidth * 0.045,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              /// NAME FIELD
              Obx(
                () => GlobalTextField(
                  controller: controller.nameController,
                  focusNode: controller.nameFocusNode,
                  hintText: AppTexts.SIGNUP_NAME,
                  obscureText: false,
                  readOnly: !controller.isNameEditing.value,
                  keyboardType: TextInputType.name,
                  errorText: controller.nameError.value,
                  onChanged: controller.validateName,
                  suffixIcon: GestureDetector(
                    onTap: controller.toggleNameEdit,
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      child: SvgPicture.asset(
                        AppImages.EDIT_PENCIL,
                        width: screenWidth * 0.04,
                        height: screenWidth * 0.04,
                        color: controller.isNameEditing.value
                            ? AppColors.primaryColor
                            : AppColors.textColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.015),

              /// BIO FIELD
              Obx(() {
                // Access both observables to ensure Obx tracks them
                final isEmpty = controller.isBioEmpty.value;
                final suggestion = controller.currentBioSuggestion;
                final isEditing = controller.isBioEditing.value;
                return GlobalTextField(
                  controller: controller.bioController,
                  focusNode: controller.bioFocusNode,
                  hintText: AppTexts.BIO_HINT,
                  labelText: isEmpty ? suggestion : null,
                  obscureText: false,
                  readOnly: !isEditing,
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  suffixIcon: GestureDetector(
                    onTap: controller.toggleBioEdit,
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      child: SvgPicture.asset(
                        AppImages.EDIT_PENCIL,
                        width: screenWidth * 0.04,
                        height: screenWidth * 0.04,
                        color: isEditing
                            ? AppColors.primaryColor
                            : AppColors.textColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              }),

              SizedBox(height: screenHeight * 0.015),

              /// PHONE NUMBER FIELD (READ ONLY)
              GlobalTextField(
                enabled: false,
                controller: TextEditingController(
                  text: Preference.phone.isNotEmpty
                      ? Preference.phone
                      : "-",
                ),
                hintText: AppTexts.PHONE_LOGIN_HINT,
                obscureText: false,
                suffixIcon: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: SvgPicture.asset(
                    AppImages.CHECK_ICON,
                    width: screenWidth * 0.025,
                    height: screenWidth * 0.025,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.1),

              /// SAVE BUTTON
              Obx(
                () => global_button(
                  loaderWhite: true,
                  isLoading: controller.isLoading.value,
                  onTap:
                      controller.hasChanges.value
                          ? () {
                            if (_formKey.currentState?.validate() ?? false) {
                              controller.saveChanges();
                            }
                          }
                          : null,
                  title: AppTexts.SAVE_CHANGES,
                  backgroundColor:
                      controller.hasChanges.value
                          ? AppColors.primaryColor
                          : AppColors.primaryColor.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}