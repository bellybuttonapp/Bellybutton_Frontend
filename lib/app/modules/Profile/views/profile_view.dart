// ignore_for_file: deprecated_member_use, duplicate_ignore

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
      appBar: CustomAppBar(title: AppTexts.profile),
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
                                : "example User");
                    final email =
                        Preference.email.isNotEmpty
                            ? Preference.email
                            : user?.email ?? "example@email.com";
                    final photoUrl = user?.photoURL;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Hero(
                        tag: 'profile-photo', // same tag as AccountDetailsView
                        child: CircleAvatar(
                          radius: screenWidth * 0.075,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              photoUrl != null ? NetworkImage(photoUrl) : null,
                          child:
                              photoUrl == null
                                  ? Icon(
                                    Icons.person,
                                    size: screenWidth * 0.075,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),

                      title: Text(
                        displayName,
                        style: customBoldText.copyWith(
                          fontSize: screenWidth * 0.045,
                        ),
                        overflow: TextOverflow.visible,
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
                          app_images.edit_pencil,
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
                        app_images.Auto_sync_icon,
                        width: screenWidth * 0.055,
                        height: screenWidth * 0.055,
                      ),
                      title: Text(
                        AppTexts.autoSyncSettings,
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
                  svgPath: app_images.permissions_icon,
                  title: AppTexts.privacyPermissions,
                  onTap: controller.onPrivacyTap,
                ),

                const _SectionDivider(),

                // Menu items
                _ProfileMenuTile(
                  svgPath:
                      app_images
                          .New_pswrd, // change if you have a password icon
                  title: AppTexts.Newpswd,
                  onTap: controller.ResetPassword,
                ),
                const _SectionDivider(),

                _ProfileMenuTile(
                  svgPath:
                      app_images
                          .New_pswrd, // change if you have a password icon
                  title: AppTexts.premium,
                  onTap: controller.PremiumScreen,
                ),

                const _SectionDivider(),

                _ProfileMenuTile(
                  svgPath: app_images.Faq_icon,
                  title: AppTexts.faqs,
                  onTap: controller.onFaqsTap,
                ),
                const _SectionDivider(),

                _ProfileMenuTile(
                  svgPath: app_images.Delete_account_icon,
                  title: AppTexts.deleteAccount,
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
                      title: AppTexts.signOut,
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
