import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:bellybutton/app/core/utils/appColors/custom_color.g.dart';
import 'package:bellybutton/app/modules/Dashboard/Innermodule/Past_Event/views/past_event_view.dart';
import 'package:bellybutton/app/modules/Dashboard/Innermodule/Upcomming_Event/views/upcomming_event_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/themes/Font_style.dart';
import '../../../core/themes/dimensions.dart';
import '../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../controllers/dashboard_controller.dart';

// DASHBOARD VIEW

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            isDark
                ? AppTheme.darkTheme.scaffoldBackgroundColor
                : AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: "Dashboard",
          showBackButton: false,
          showProfileSection: true,
          profileName: "Karthick",
          profileImageAsset: null, // Provide path if available
          actions: [
            IconButton(
              icon: SvgPicture.asset(
                app_images.notification,
                height: 26,
                width: 26,
                color: theme.iconTheme.color, // dynamic color
              ),
              onPressed: () => controller.goToNotificationView(),
              tooltip: "Notifications",
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: TabBar(
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
              tabs: [
                Tab(text: app_texts.Upcoming_event),
                Tab(text: app_texts.Past_event),
              ],
            ),
          ),
        ),
        body:  TabBarView(
          physics: BouncingScrollPhysics(),
          children: [UpcommingEventView(), PastEventView()],
        ),
      ),
    );
  }
}
