// ignore_for_file: deprecated_member_use, prefer_const_constructors_in_immutables

import 'dart:io';
import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/utils/themes/font_style.dart';
import '../../../core/utils/themes/dimensions.dart';
import '../../../core/utils/storage/preference.dart';
import '../../../global_widgets/Button/global_button.dart';
import '../../../global_widgets/Shimmers/ProfileHeaderShimmer.dart';
import '../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../global_widgets/loader/global_loader.dart';
import '../controllers/profile_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ProfileView extends GetView<ProfileController> {
  
  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppTexts.PROFILE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top section with all menu items
                  Column(
                    children: [
                      // Profile Header
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                          horizontal: screenWidth * 0.04,
                        ),
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(child: ProfileHeaderShimmer());
                          }

                          final profile = controller.userProfile;

                          // Get name with proper fallback (handle empty strings)
                          final profileName =
                              profile['fullName']?.toString().trim();
                          final prefName = Preference.userName;
                          final displayName =
                              (profileName?.isNotEmpty == true)
                                  ? profileName!
                                  : (prefName.isNotEmpty ? prefName : "-");

                          // Get phone with proper fallback
                          final profilePhone =
                              profile['phone']?.toString().trim();
                          final prefPhone = Preference.phone;
                          final phone =
                              (profilePhone?.isNotEmpty == true)
                                  ? profilePhone!
                                  : (prefPhone.isNotEmpty ? prefPhone : "-");

                          final networkImage =
                              profile['profileImageUrl']
                                  ?.toString()
                                  .replaceAll('\n', '')
                                  .trim();

                          final localImage = controller.pickedImage.value?.path;
                          final preferenceImage = Preference.profileImage;

                          // Determine the image URL to use (priority: Network > Preference > Local)
                          String? imageUrl;
                          bool isLocalFile = false;

                          if (networkImage != null && networkImage.isNotEmpty) {
                            imageUrl = networkImage;
                          } else if (preferenceImage != null && preferenceImage.isNotEmpty) {
                            imageUrl = preferenceImage;
                            isLocalFile = !preferenceImage.startsWith('http');
                          } else if (localImage != null && localImage.isNotEmpty) {
                            imageUrl = localImage;
                            isLocalFile = true;
                          }

                          // Build profile image widget with caching
                          Widget buildProfileImage() {
                            final radius = screenWidth * 0.075;
                            final iconSize = screenWidth * 0.055;
                            final bgColor = const Color.fromARGB(255, 166, 216, 233).withOpacity(0.15);

                            if (imageUrl == null || imageUrl.isEmpty) {
                              return CircleAvatar(
                                radius: radius,
                                backgroundColor: bgColor,
                                child: SvgPicture.asset(
                                  AppImages.PERSON,
                                  height: iconSize,
                                  width: iconSize,
                                  color: AppColors.textColor,
                                ),
                              );
                            }

                            if (isLocalFile) {
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
                                child: SvgPicture.asset(
                                  AppImages.PERSON,
                                  height: iconSize,
                                  width: iconSize,
                                  color: AppColors.textColor,
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
                                child: SvgPicture.asset(
                                  AppImages.PERSON,
                                  height: iconSize,
                                  width: iconSize,
                                  color: AppColors.textColor,
                                ),
                              ),
                            );
                          }

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Hero(
                              tag: 'profile-photo',
                              child: buildProfileImage(),
                            ),
                            title: Hero(
                              tag: 'profile-name-$displayName',
                              child: Material(
                                color: Colors.transparent,
                                child: AutoSizeText(
                                  displayName.isNotEmpty ? displayName : "-",
                                  maxLines: 1,
                                  minFontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.headingLg.copyWith(
                                    fontSize: screenWidth * 0.045,
                                  ),
                                ),
                              ),
                            ),
                            subtitle: Text(
                              phone.isNotEmpty ? phone : "-",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.headingLg.copyWith(
                                fontSize: screenWidth * 0.035,
                                color: AppColors.tertiaryColor,
                              ),
                            ),
                            trailing: IconButton(
                              icon: SvgPicture.asset(
                                AppImages.EDIT_PENCIL,
                                width: screenWidth * 0.05,
                                height: screenWidth * 0.05,
                              ),
                              onPressed: controller.onEditProfile,
                            ),
                          );
                        }),
                      ),

                      const _SectionDivider(),

                      // Auto Sync Switch
                      Obx(
                        () => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                          ),
                          child: SwitchListTile(
                            activeColor: AppColors.success,
                            inactiveThumbColor: AppColors.primaryColor
                                .withOpacity(0.5),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                            ),
                            secondary: SvgPicture.asset(
                              AppImages.AUTO_SYNC_ICON,
                              width: screenWidth * 0.055,
                              height: screenWidth * 0.055,
                            ),
                            title: Text(
                              AppTexts.AUTO_SYNC_SETTINGS,
                              style: AppText.headingLg.copyWith(
                                fontSize: screenWidth * 0.035,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            value: controller.autoSync.value,
                            onChanged: controller.onAutoSyncChanged,
                          ),
                        ),
                      ),

                      const _SectionDivider(),

                      _ProfileMenuTile(
                        svgPath: AppImages.PERMISSIONS_ICON,
                        title: AppTexts.PRIVACY_PERMISSIONS,
                        onTap: controller.onPrivacyTap,
                      ),

                      const _SectionDivider(),

                      _ProfileMenuTile(
                        svgPath: AppImages.DELETE_ACCOUNT_ICON,
                        title: AppTexts.DELETE_ACCOUNT,
                        titleColor: Colors.red,
                        svgColor: Colors.red,
                        onTap: controller.onDeleteAccountTap,
                      ),
                    ],
                  ),

                  // Bottom section with logout button
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.025,
                    ),
                    child: Obx(
                      () => global_button(
                        loaderWhite: true,
                        isLoading: controller.isSigningOut.value,
                        title: AppTexts.SIGNOUT,
                        backgroundColor: AppColors.primaryColor,
                        textColor: AppColors.textColor3,
                        onTap: controller.onSignOut,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Divider
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: Dimensions.spacing4),
      child: const Divider(height: 1, thickness: 0.5),
    );
  }
}

// Menu Tile
class _ProfileMenuTile extends StatelessWidget {
  final String svgPath;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? svgColor;

  const _ProfileMenuTile({
    required this.svgPath,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.svgColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
      child: ListTile(
        leading: SvgPicture.asset(
          svgPath,
          width: width * 0.06,
          height: width * 0.06,
          color: svgColor ?? Colors.black87,
        ),
        title: Text(
          title,
          style: AppText.headingLg.copyWith(
            fontSize: width * 0.035,
            color: titleColor ?? Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: width * 0.04,
          color: titleColor ?? Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }
}