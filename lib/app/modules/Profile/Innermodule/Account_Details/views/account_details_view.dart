// ignore_for_file: annotate_overrides, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../Controllers/oauth.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../../../../../utils/preference.dart';
import '../controllers/account_details_controller.dart';
import '../../../../../global_widgets/custom_app_bar/custom_app_bar.dart';

class AccountDetailsView extends GetView<AccountDetailsController> {
  final AccountDetailsController controller = Get.put(
    AccountDetailsController(),
    permanent: true,
  );
  final _formKey = GlobalKey<FormState>();

  AccountDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final user = AuthService().currentUser;

    final initialName =
        user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : (Preference.userName.isNotEmpty
                ? Preference.userName
                : "example User");

    controller.nameController.text = initialName;
    controller.bioController.text =
        Preference.bio.isNotEmpty ? Preference.bio : "";

    ImageProvider<Object>? profileImage() {
      final picked = controller.pickedImage.value;
      final savedImage = Preference.profileImage ?? '';
      final photoUrl = user?.photoURL;

      if (picked != null) return FileImage(File(picked.path));
      if (savedImage.isNotEmpty) {
        return savedImage.startsWith('http')
            ? NetworkImage(savedImage)
            : FileImage(File(savedImage));
      }
      if (photoUrl != null && photoUrl.isNotEmpty)
        return NetworkImage(photoUrl);
      return null;
    }

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppTexts.ACCOUNT_DETAILS),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.04,
            ),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Image
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Obx(
                            () => Hero(
                              tag: 'profile-photo',
                              child: CircleAvatar(
                                radius: screenWidth * 0.16,
                                backgroundColor: AppColors.other,
                                backgroundImage: profileImage(),
                                child:
                                    profileImage() == null
                                        ? Padding(
                                          padding: EdgeInsets.all(
                                            screenWidth * 0.03,
                                          ),
                                          child: SvgPicture.asset(
                                            AppImages.PERSON,
                                            height: screenWidth * 0.08,
                                            width: screenWidth * 0.08,
                                            color: AppColors.textColor
                                                .withOpacity(0.7),
                                          ),
                                        )
                                        : null,
                              ),
                            ),
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

                    // Name Field
                    Obx(
                      () => GlobalTextField(
                        controller: controller.nameController,
                        hintText: AppTexts.SIGNUP_NAME,
                        obscureText: false,
                        keyboardType: TextInputType.name,
                        errorText: controller.nameError.value,
                        onChanged: controller.validateName,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Bio Field
                    GlobalTextField(
                      controller: controller.bioController,
                      hintText: AppTexts.BIO,
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      maxLines: 3,
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Email Field (Read-only)
                    GlobalTextField(
                      enabled: false,
                      controller: TextEditingController(
                        text:
                            Preference.email.isNotEmpty
                                ? Preference.email
                                : (user?.email ?? "example@email.com"),
                      ),
                      hintText: AppTexts.EMAIL,
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

                    SizedBox(height: screenHeight * 0.25),

                    // Save Button
                    Obx(
                      () => global_button(
                        loaderWhite: true,
                        isLoading: controller.isLoading.value,
                        onTap: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            controller.saveChanges();
                          }
                        },
                        title: AppTexts.SAVE_CHANGES,
                        backgroundColor: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
