// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'dart:io';

import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../Controllers/oauth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/themes/Font_style.dart';
import '../../../global_widgets/Button/global_button.dart';
import '../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../utils/preference.dart';
import '../controllers/profile_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ProfileView extends GetView<ProfileController> {
  // ignore: annotate_overrides
  final ProfileController controller = Get.put(ProfileController());
  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppTexts.PROFILE),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                // Profile header
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                    horizontal: screenWidth * 0.04,
                  ),
                  child: Obx(() {
                    final user = AuthService().currentUser;
                    final displayName =
                        user?.displayName?.isNotEmpty == true
                            ? user!.displayName!
                            : (Preference.userName.isNotEmpty
                                ? Preference.userName
                                : "Example User");
                    final email =
                        Preference.email.isNotEmpty
                            ? Preference.email
                            : user?.email ?? "example@email.com";

                    final localImage = controller.pickedImage.value?.path;
                    final networkImage = user?.photoURL;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Hero(
                        tag: 'profile-photo',
                        child: CircleAvatar(
                          radius: screenWidth * 0.075,
                          backgroundColor: AppColors.other,
                          backgroundImage:
                              localImage != null
                                  ? FileImage(File(localImage))
                                  : (networkImage != null
                                          ? NetworkImage(networkImage)
                                          : null)
                                      as ImageProvider?,
                          child:
                              localImage == null && networkImage == null
                                  ? SvgPicture.asset(
                                    AppImages.PERSON,
                                    height: screenWidth * 0.055,
                                    width: screenWidth * 0.055,
                                    color: AppColors.textColor,
                                  )
                                  : null,
                        ),
                      ),
                      title: Hero(
                        tag:
                            'profile-name-$displayName', // must match tag in CustomAppBar
                        child: Material(
                          color: Colors.transparent,
                          child: AutoSizeText(
                            displayName,
                            style: customBoldText.copyWith(
                              fontSize: screenWidth * 0.045,
                            ),
                            maxLines: 1,
                            minFontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      subtitle: Text(
                        email,
                        style: customBoldText.copyWith(
                          fontSize: screenWidth * 0.035,
                          color: AppColors.tertiaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
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

                Obx(
                  () => Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                    ),
                    child: SwitchListTile(
                      // ignore: deprecated_member_use
                      activeColor: AppColors.success,
                      // ignore: deprecated_member_use
                      inactiveThumbColor: AppColors.primaryColor.withOpacity(
                        0.5,
                      ),
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
                        style: customBoldText.copyWith(
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

                // Menu items
                _ProfileMenuTile(
                  svgPath:
                      AppImages.NEW_PSWRD, // change if you have a password icon
                  title: AppTexts.NEW_PSWD,
                  onTap: controller.ResetPassword,
                ),
                const _SectionDivider(),

                _ProfileMenuTile(
                  svgPath:
                      AppImages.NEW_PSWRD, // change if you have a password icon
                  title: AppTexts.PREMIUM,
                  onTap: controller.PremiumScreen,
                ),

                const _SectionDivider(),

                _ProfileMenuTile(
                  svgPath: AppImages.FAQ_ICON,
                  title: AppTexts.FAQS,
                  onTap: controller.onFaqsTap,
                ),
                const _SectionDivider(),

                _ProfileMenuTile(
                  svgPath: AppImages.DELETE_ACCOUNT_ICON,
                  title: AppTexts.DELETE_ACCOUNT,
                  titleColor: Colors.red,
                  svgColor: Colors.red,
                  onTap: controller.onDeleteAccountTap,
                ),

                const Spacer(),

                // Sign out button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.025,
                  ),
                  child: Obx(
                    () => global_button(
                      loaderWhite: true,
                      isLoading: controller.isLoading.value,
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
        ],
      ),
    );
  }
}

// Divider widget
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 4,
      ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02,
          vertical: 4,
        ),
        leading: SvgPicture.asset(
          svgPath,
          width: screenWidth * 0.06,
          height: screenWidth * 0.06,
          color: svgColor ?? Colors.black87,
        ),
        title: Text(
          title,
          style: customBoldText.copyWith(
            fontSize: screenWidth * 0.035,
            color: titleColor ?? Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: screenWidth * 0.04,
          color: titleColor ?? Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }
}
