// ignore_for_file: deprecated_member_use, annotate_overrides

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bellybutton/app/core/constants/app_colors.dart';
import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import 'package:bellybutton/app/global_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:bellybutton/app/global_widgets/Button/global_button.dart';
import 'package:bellybutton/app/modules/Dashboard/Innermodule/Past_Event/views/past_event_view.dart';
import 'package:bellybutton/app/modules/Dashboard/Innermodule/Upcomming_Event/views/upcomming_event_view.dart';
import '../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  final DashboardController controller = Get.put(DashboardController());
  DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'User';
    final photoURL = user?.photoURL;

    // ✅ MediaQuery for responsive sizing
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    DateTime? lastPressedTime;

    return WillPopScope(
      onWillPop: () async {
        final currentTime = DateTime.now();

        if (lastPressedTime == null ||
            currentTime.difference(lastPressedTime!) >
                const Duration(seconds: 2)) {
          lastPressedTime = currentTime;
          showCustomSnackBar(
            AppTexts.PRESS_BACK_TO_EXIT,
            SnackbarState.pending,
            durationSeconds: 2,
          );
          return false;
        }
        return true;
      },
      child: DefaultTabController(
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
            profileImageNetwork: photoURL ?? '',
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  AppImages.INVITATIONS_ICON,
                  height: width * 0.065,
                  width: width * 0.065,
                  color: theme.iconTheme.color,
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  controller.goToEventInvitationsView();
                },
                tooltip: "EventInvitations",
              ),
              IconButton(
                icon: SvgPicture.asset(
                  AppImages.NOTIFICATION,
                  height: width * 0.065,
                  width: width * 0.065,
                  color: theme.iconTheme.color,
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  controller.goToNotificationView();
                },
                tooltip: "Notifications",
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(height * 0.07),
              child: TabBar(
                onTap: (index) => HapticFeedback.selectionClick(),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelStyle: customBoldText.copyWith(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: customBoldText.copyWith(
                  fontSize: width * 0.04,
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
          body: GetBuilder<DashboardController>(
            builder: (_) {
              return Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [UpcommingEventView(), PastEventView()],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(width * 0.04),
                    child: Column(
                      children: [
                        // ✅ Existing global_button
                        Obx(
                          () => global_button(
                            loaderWhite: true,
                            isLoading: controller.isLoading.value,
                            title: AppTexts.CREATE_EVENT,
                            backgroundColor: AppColors.primaryColor,
                            textColor: AppColors.textColor3,
                            onTap: controller.CreateEvent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
