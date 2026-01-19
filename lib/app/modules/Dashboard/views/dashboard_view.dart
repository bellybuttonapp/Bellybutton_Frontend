// ignore_for_file: deprecated_member_use, annotate_overrides, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart' as badges;
import 'package:showcaseview/showcaseview.dart';
import 'package:bellybutton/app/core/constants/app_colors.dart';
import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import 'package:bellybutton/app/global_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:bellybutton/app/global_widgets/Button/global_button.dart';
import 'package:bellybutton/app/modules/Dashboard/Innermodule/Past_Event/views/past_event_view.dart';
import 'package:bellybutton/app/modules/Dashboard/Innermodule/Upcomming_Event/views/upcomming_event_view.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/showcase_service.dart';
import '../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  final DashboardController controller = Get.put(DashboardController());
  DashboardView({super.key});

  // Showcase GlobalKeys - Create unique keys per instance
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _notificationsKey = GlobalKey();
  final GlobalKey _tabsKey = GlobalKey();
  final GlobalKey _createEventKey = GlobalKey();

  // Flag to prevent showcase from starting multiple times
  bool _showcaseStarted = false;

  @override
  Widget build(BuildContext context) {
    // Skip ShowCaseWidget when there's a pending deep link to avoid navigation conflicts
    if (ShowcaseService.hasPendingDeepLink) {
      return _buildDashboard(context);
    }

    return ShowCaseWidget(
      onComplete: (index, key) {
        // Mark tour as complete when last showcase is shown
        if (key == _createEventKey) {
          ShowcaseService.completeDashboardTour();
        }
      },
      onFinish: () {
        ShowcaseService.completeDashboardTour();
        _showcaseStarted = false; // Reset for potential future "show tutorial again" feature
      },
      builder: (context) => _buildDashboard(context),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ MediaQuery for responsive sizing
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    DateTime? lastPressedTime;

    // Start showcase tour if not shown before (only once per session)
    // Use post-frame callback to ensure UI is fully rendered before showing showcase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Short delay to ensure all widgets are rendered and stable
      Future.delayed(const Duration(milliseconds: 800), () async {
        // Check if context is still valid (widget not deactivated)
        if (!context.mounted) return;

        // First, ask user if they want to see the tour (only if not asked before)
        if (!ShowcaseService.hasBeenAskedAboutTour) {
          await ShowcaseService.showTourPrompt(context);
        }

        // Check context again after async call
        if (!context.mounted) return;

        // Then start showcase if user wants it and it hasn't been shown
        if (ShowcaseService.shouldShowDashboardTour && !_showcaseStarted) {
          _showcaseStarted = true;
          ShowcaseService.startShowcase(
            context,
            [_profileKey, _notificationsKey, _tabsKey, _createEventKey],
            delay: const Duration(milliseconds: 200),
          );
        }
      });
    });

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
        initialIndex: controller.initialTabIndex.value,
        child: Scaffold(
          backgroundColor:
              isDark
                  ? AppTheme.darkTheme.scaffoldBackgroundColor
                  : AppTheme.lightTheme.scaffoldBackgroundColor,
          appBar: CustomAppBar(
            showBackButton: false,
            showProfileSection: true,
            profileName: Preference.userName.isNotEmpty ? Preference.userName : 'User',
            profileImageNetwork: Preference.profileImage ?? '',
            profileKey: _profileKey,
            actions: [
              // Notifications button with showcase
              Showcase(
                key: _notificationsKey,
                title: AppTexts.SHOWCASE_DASHBOARD_NOTIFICATIONS_TITLE,
                description: AppTexts.SHOWCASE_DASHBOARD_NOTIFICATIONS_DESC,
                tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
                textColor: ShowcaseService.textColor,
                titleTextStyle: ShowcaseService.titleStyle,
                descTextStyle: ShowcaseService.descriptionStyle,
                child: Obx(() {
                  // Access notifications.length to trigger reactivity
                  final notifications = NotificationService.to.notifications;
                  final unreadCount = notifications.where((n) => !n.read).length;
                  return IconButton(
                    icon: badges.Badge(
                      showBadge: unreadCount > 0,
                      position: badges.BadgePosition.topEnd(top: -8, end: -6),
                      badgeStyle: badges.BadgeStyle(
                        badgeColor: AppColors.error,
                        padding: EdgeInsets.all(unreadCount > 9 ? 4 : 6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      badgeAnimation: const badges.BadgeAnimation.scale(
                        animationDuration: Duration(milliseconds: 300),
                        colorChangeAnimationDuration: Duration(milliseconds: 300),
                      ),
                      badgeContent: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: AppText.bodyXs.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: unreadCount > 9 ? 9 : 10,
                        ),
                      ),
                      child: SvgPicture.asset(
                        AppImages.NOTIFICATION,
                        height: width * 0.065,
                        width: width * 0.065,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      controller.goToNotificationView();
                    },
                    tooltip: AppTexts.NOTIFICATION,
                  );
                }),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(height * 0.07),
              child: Showcase(
                key: _tabsKey,
                title: AppTexts.SHOWCASE_DASHBOARD_TABS_TITLE,
                description: AppTexts.SHOWCASE_DASHBOARD_TABS_DESC,
                tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
                textColor: ShowcaseService.textColor,
                titleTextStyle: ShowcaseService.titleStyle,
                descTextStyle: ShowcaseService.descriptionStyle,
                child: TabBar(
                  onTap: (index) => HapticFeedback.selectionClick(),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelStyle: AppText.headingLg.copyWith(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: AppText.headingLg.copyWith(
                    fontSize: width * 0.04,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  tabs: const [
                    Tab(text: AppTexts.UPCOMING_SHOOT),
                    Tab(text: AppTexts.PAST_SHOOT),
                  ],
                ),
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
                        // Create Event button with showcase
                        Showcase(
                          key: _createEventKey,
                          title: AppTexts.SHOWCASE_DASHBOARD_CREATE_TITLE,
                          description: AppTexts.SHOWCASE_DASHBOARD_CREATE_DESC,
                          tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
                          textColor: ShowcaseService.textColor,
                          titleTextStyle: ShowcaseService.titleStyle,
                          descTextStyle: ShowcaseService.descriptionStyle,
                          child: Obx(
                            () => global_button(
                              loaderWhite: true,
                              isLoading: controller.isLoading.value,
                              title: AppTexts.CREATE_SHOOT,
                              backgroundColor: AppColors.primaryColor,
                              textColor: AppColors.textColor3,
                              onTap: controller.CreateEvent,
                            ),
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