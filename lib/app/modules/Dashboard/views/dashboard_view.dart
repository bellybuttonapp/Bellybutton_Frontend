// ignore_for_file: deprecated_member_use

import 'package:bellybutton/app/core/constants/app_colors.dart';
import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/themes/Font_style.dart';
import 'package:bellybutton/app/core/themes/dimensions.dart';
import 'package:bellybutton/app/global_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:bellybutton/app/modules/Dashboard/Innermodule/Past_Event/views/past_event_view.dart';
import 'package:bellybutton/app/modules/Dashboard/Innermodule/Upcomming_Event/views/upcomming_event_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get current Firebase user
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'User';
    final photoURL = user?.photoURL;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            isDark
                ? AppTheme.darkTheme.scaffoldBackgroundColor
                : AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          showBackButton: false,
          showProfileSection: true,
          profileName: displayName,
          profileImageNetwork: photoURL,
          actions: [
            IconButton(
              icon: SvgPicture.asset(
                app_images.notification,
                height: 26,
                width: 26,
                color: theme.iconTheme.color,
              ),
              onPressed: () {
                HapticFeedback.mediumImpact(); // vibrate
                controller.goToNotificationView();
              },
              tooltip: "Notifications",
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: TabBar(
              onTap: (index) {
                HapticFeedback.selectionClick(); // light vibration on tab tap
              },
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              labelStyle: customBoldText.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: customBoldText.copyWith(
                fontSize: Dimensions.fontSizeLarge,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              tabs: const [
                Tab(text: "Upcoming Event"),
                Tab(text: "Past Event"),
              ],
            ),
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [UpcommingEventView(), PastEventView()],
        ),
      ),
    );
  }
}
