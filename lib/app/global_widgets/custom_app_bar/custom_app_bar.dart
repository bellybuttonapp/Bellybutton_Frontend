// ignore_for_file: avoid_print, deprecated_member_use, duplicate_ignore

import 'dart:io';
import 'package:bellybutton/app/modules/Profile/views/profile_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/themes/Font_style.dart';
import '../../utils/preference.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool showBackButton;
  final bool showProfileSection;
  final String? profileName;
  final String? profileImageAsset;
  final String? profileImageNetwork;
  final Color? backgroundColor;
  final Widget? titleWidget;
  final double toolbarHeight;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.showBackButton = true,
    this.showProfileSection = false,
    this.profileName,
    this.profileImageAsset,
    this.profileImageNetwork,
    this.backgroundColor,
    this.titleWidget,
    this.toolbarHeight = 70,
  }) : assert(
         !(showProfileSection && showBackButton),
         'Cannot show both profile section and back button at the same time.',
       );

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom != null ? 60 : 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;

    // 🌙 Adaptive Colors
    final bgColor =
        backgroundColor ??
        (isDark
            ? const Color(0xFF121212) // Dark scaffold
            : Colors.white); // ☀️ Light scaffold

    final iconColor = isDark ? Colors.white : AppColors.textColor;
    final textColor = isDark ? Colors.white : AppColors.textColor;

    Widget? leadingWidget;
    if (showProfileSection) {
      leadingWidget = _buildProfileSection(context, textColor, size, isDark);
    } else if (showBackButton) {
      leadingWidget =
          Platform.isIOS
              ? const BackButton()
              : IconButton(
                tooltip: 'Back',
                icon: SvgPicture.asset(
                  AppImages.BACK_ARROW,
                  color: iconColor,
                  width: size.width * 0.06,
                ),
                padding: EdgeInsets.all(size.width * 0.02),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Get.back();
                },
              );
    }

    return AppBar(
      elevation: 0,
      backgroundColor: bgColor,
      iconTheme: IconThemeData(color: iconColor, size: size.width * 0.05),
      leadingWidth: showProfileSection ? size.width * 0.38 : null,
      leading: leadingWidget,
      toolbarHeight: toolbarHeight,
      title:
          titleWidget ??
          (showProfileSection
              ? null
              : Text(
                title ?? '',
                style: customBoldText.copyWith(
                  color: iconColor,
                  fontSize: size.width * 0.05,
                ),
                overflow: TextOverflow.ellipsis,
              )),
      centerTitle: !showProfileSection,
      actions:
          actions == null
              ? null
              : [
                Padding(
                  padding: EdgeInsets.only(right: size.width * 0.03),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
                ),
              ],
      bottom:
          bottom != null
              ? PreferredSize(
                preferredSize: Size.fromHeight(size.height * 0.075),
                child: Container(
                  height: size.height * 0.075,
                  margin: EdgeInsets.symmetric(
                    horizontal: size.width * 0.08,
                    vertical: size.height * 0.01,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.03,
                    vertical: size.height * 0.007,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size.width * 0.025),
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [
                                Colors.blueGrey.withOpacity(
                                  0.25,
                                ), // 🌙 darker shade
                                Colors.black26,
                              ]
                              : [
                                const Color.fromARGB(
                                  255,
                                  166,
                                  216,
                                  233,
                                ).withOpacity(0.15),
                                const Color.fromARGB(
                                  255,
                                  166,
                                  216,
                                  233,
                                ).withOpacity(0.15),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * 0.03),
                    child: bottom,
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    Color textColor,
    Size size,
    bool isDark,
  ) {
    return Obx(() {
      String prefName = Preference.userNameRx.value;
      String? prefPhoto = Preference.profileImageRx.value;

      final firebaseUser = FirebaseAuth.instance.currentUser;
      String displayName =
          firebaseUser?.displayName?.isNotEmpty == true
              ? firebaseUser!.displayName!
              : prefName;

      File? localImageFile =
          (prefPhoto != null && prefPhoto.isNotEmpty) ? File(prefPhoto) : null;

      ImageProvider? imageProvider;
      if (localImageFile != null && localImageFile.existsSync()) {
        imageProvider = FileImage(localImageFile);
      } else if (firebaseUser?.photoURL != null) {
        imageProvider = NetworkImage(firebaseUser!.photoURL!);
      }

      return Padding(
        padding: EdgeInsets.only(left: size.width * 0.02),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Get.to(
              () => ProfileView(),
              transition: Transition.fade,
              duration: const Duration(milliseconds: 300),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: size.height * 0.007,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isDark
                        ? [
                          Colors.blueGrey.withOpacity(0.25), // 🌙
                          Colors.black26,
                        ]
                        : [
                          const Color.fromARGB(
                            255,
                            166,
                            216,
                            233,
                          ).withOpacity(0.15), // ☀️
                          const Color.fromARGB(
                            255,
                            166,
                            216,
                            233,
                          ).withOpacity(0.15),
                        ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(size.width * 0.025),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'profile-photo',
                  child: CircleAvatar(
                    radius: size.width * 0.045,
                    backgroundColor: Colors.transparent,
                    backgroundImage: imageProvider,
                    child:
                        imageProvider == null
                            ? SvgPicture.asset(
                              AppImages.PERSON,
                              height: size.width * 0.055,
                              width: size.width * 0.055,
                              color: textColor,
                            )
                            : null,
                  ),
                ),
                SizedBox(width: size.width * 0.02),
                Flexible(
                  child: Hero(
                    tag: 'profile-name-$displayName',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        displayName,
                        style: customBoldText.copyWith(
                          color: textColor,
                          fontSize: size.width * 0.035,
                          shadows: [
                            Shadow(
                              color:
                                  isDark
                                      ? Colors.black.withOpacity(0.6)
                                      : Colors.grey.withOpacity(0.3),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        maxLines: null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
