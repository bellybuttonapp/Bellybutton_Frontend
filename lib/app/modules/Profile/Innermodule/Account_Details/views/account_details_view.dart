import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../../Controllers/oauth.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../Auth/signup/Widgets/Signup_textfield.dart';
import '../controllers/account_details_controller.dart';
import '../../../../../global_widgets/custom_app_bar/custom_app_bar.dart';

class AccountDetailsView extends GetView<AccountDetailsController> {
  // ignore: annotate_overrides
  final AccountDetailsController controller = Get.put(
    AccountDetailsController(),
  );
  final _formKey = GlobalKey<FormState>();

  AccountDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final user = AuthService().currentUser;
    final displayName = user?.displayName ?? '';
    final email = user?.email ?? '';

    // Initialize name controller with current name
    controller.nameController.text = displayName;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppTexts.accountDetails),
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
                            () => CircleAvatar(
                              radius: screenWidth * 0.16,
                              backgroundColor: Colors.grey,
                              backgroundImage:
                                  controller.pickedImage.value != null
                                      ? FileImage(
                                        File(
                                          controller.pickedImage.value!.path,
                                        ),
                                      )
                                      : (user?.photoURL != null
                                              ? NetworkImage(user!.photoURL!)
                                              : null)
                                          as ImageProvider<Object>?,
                              child:
                                  controller.pickedImage.value == null &&
                                          user?.photoURL == null
                                      ? Icon(
                                        Icons.person,
                                        size: screenWidth * 0.13,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          ),

                          // Inside the Stack where the camera icon is
                          Positioned(
                            bottom: screenWidth * 0.015,
                            right: screenWidth * 0.015,
                            child: GestureDetector(
                              onTap: () async {
                                await controller.pickImage();
                              },
                              child: Container(
                                padding: EdgeInsets.all(screenWidth * 0.015),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  app_images.Camera_Add_icon,
                                  // ignore: deprecated_member_use
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
                      () => Signup_textfield(
                        controller: controller.nameController,
                        hintText: AppTexts.signupName,
                        obscureText: false,
                        keyboardType: TextInputType.name,
                        errorText: controller.nameError.value,
                        onChanged: controller.validateName,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Email (Read-only)
                    Signup_textfield(
                      enabled: false,
                      controller: TextEditingController(
                        text: email,
                      ), // <-- Set controller with email
                      hintText: "Email",
                      obscureText: false,
                      suffixIcon: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        child: SvgPicture.asset(
                          app_images.check_icon,
                          width: screenWidth * 0.025,
                          height: screenWidth * 0.025,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    SizedBox(height: screenHeight * 0.35),

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
                        title: AppTexts.saveChanges,
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
