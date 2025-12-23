// ignore_for_file: annotate_overrides, deprecated_member_use

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:bellybutton/app/global_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/utils/index.dart';
import '../../../database/models/NotificationModel.dart';
import '../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../global_widgets/Shimmers/NotificationShimmer.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  final NotificationsController controller = Get.put(NotificationsController());
  NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppTexts.NOTIFICATION),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const NotificationShimmer(count: 5);
        }

        if (!controller.hasNotifications) {
          return SmartRefresher(
            controller: controller.refreshController,
            enablePullDown: true,
            onRefresh: controller.refreshNotifications,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: EmptyJobsPlaceholder(
                      imagePath: AppImages.OBJECT,
                      title: AppTexts.NO_NOTIFICATION,
                      description: AppTexts.NOTIFICATION_SUBTITLE,
                      isLoading: controller.isLoading,
                      buttonText: AppTexts.GO_BACK,
                      onButtonTap: controller.goToBack,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _buildNotificationList(context, isDarkMode, size);
      }),
    );
  }

  Widget _buildNotificationList(BuildContext context, bool isDarkMode, Size size) {
    return AdaptiveScrollbar(
      controller: controller.scrollController,
      position: ScrollbarPosition.right,
      width: 10,
      sliderSpacing: const EdgeInsets.symmetric(vertical: 6),
      sliderDefaultColor: AppColors.primaryColor,
      sliderActiveColor: AppColors.primaryColor.withOpacity(0.8),
      underColor: isDarkMode
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.05),
      sliderHeight: 100,
      child: SmartRefresher(
        controller: controller.refreshController,
        enablePullDown: true,
        onRefresh: controller.refreshNotifications,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Today section
            if (controller.todayNotifications.isNotEmpty) ...[
              SliverPadding(
                padding: EdgeInsets.only(
                  left: size.width * 0.05,
                  right: size.width * 0.05,
                  top: size.height * 0.02,
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    'Today',
                    isDarkMode,
                    size,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildNotificationItem(
                      controller.todayNotifications[index],
                      isDarkMode,
                      size,
                    ),
                    childCount: controller.todayNotifications.length,
                  ),
                ),
              ),
            ],

            // Yesterday section
            if (controller.yesterdayNotifications.isNotEmpty) ...[
              SliverPadding(
                padding: EdgeInsets.only(
                  left: size.width * 0.05,
                  right: size.width * 0.05,
                  top: size.height * 0.02,
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    'Yesterday',
                    isDarkMode,
                    size,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildNotificationItem(
                      controller.yesterdayNotifications[index],
                      isDarkMode,
                      size,
                    ),
                    childCount: controller.yesterdayNotifications.length,
                  ),
                ),
              ),
            ],

            // Older section
            if (controller.olderNotifications.isNotEmpty) ...[
              SliverPadding(
                padding: EdgeInsets.only(
                  left: size.width * 0.05,
                  right: size.width * 0.05,
                  top: size.height * 0.02,
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    'Earlier',
                    isDarkMode,
                    size,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  left: size.width * 0.05,
                  right: size.width * 0.05,
                  bottom: size.height * 0.02,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildNotificationItem(
                      controller.olderNotifications[index],
                      isDarkMode,
                      size,
                    ),
                    childCount: controller.olderNotifications.length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool isDarkMode,
    Size size,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.015),
      child: Text(
        title,
        style: customSemiBoldText.copyWith(
          color: isDarkMode ? Colors.white70 : AppColors.textColor2,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    NotificationModel notification,
    bool isDarkMode,
    Size size,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(size.width * 0.03),
        border:
            !notification.read
                ? Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 1,
                  )
                : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification indicator (blue dot for unread)
          if (!notification.read)
            Container(
              width: size.width * 0.025,
              height: size.width * 0.025,
              margin: EdgeInsets.only(
                top: size.height * 0.005,
                right: size.width * 0.03,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            )
          else
            SizedBox(width: size.width * 0.055),

          // Profile avatar
          CircleAvatar(
            radius: size.width * 0.065,
            backgroundColor:
                isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            backgroundImage: notification.profileImageUrl != null &&
                    notification.profileImageUrl!.isNotEmpty
                ? NetworkImage(notification.profileImageUrl!)
                : null,
            child: notification.profileImageUrl == null ||
                    notification.profileImageUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    size: size.width * 0.07,
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                  )
                : null,
          ),

          SizedBox(width: size.width * 0.035),

          // Notification content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: (notification.read ? customTextNormal : customMediumText).copyWith(
                    color: isDarkMode ? Colors.white : AppColors.textColor,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: size.height * 0.008),
                Text(
                  _formatNotificationTime(notification.createdAt),
                  style: customTextSmall.copyWith(
                    color: isDarkMode ? Colors.white54 : AppColors.textColor2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    final timeFormat = DateFormat('h:mm a');

    if (notificationDate == today) {
      return timeFormat.format(dateTime);
    } else if (notificationDate == yesterday) {
      return timeFormat.format(dateTime);
    } else {
      return '${DateFormat('MMMM dd/yyyy').format(dateTime)} at ${timeFormat.format(dateTime)}';
    }
  }
}