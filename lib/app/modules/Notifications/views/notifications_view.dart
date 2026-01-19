// ignore_for_file: annotate_overrides, deprecated_member_use

import 'dart:io';
import 'package:bellybutton/app/global_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/utils/index.dart';
import '../../../database/models/NotificationModel.dart';
import '../../../global_widgets/Shimmers/NotificationShimmer.dart';
import '../../../global_widgets/loader/global_loader.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends StatelessWidget {
  NotificationsView({super.key})
      : controller = Get.put(
          NotificationsController(),
          tag: 'notifications_${DateTime.now().millisecondsSinceEpoch}',
        );

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final c = controller;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkTheme.scaffoldBackgroundColor
          : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppTexts.NOTIFICATION),
      body: Obx(() {
        if (c.isLoading.value && c.notifications.isEmpty) {
          return const NotificationShimmer(count: 5);
        }

        return _buildNotificationList(context, isDarkMode, size, c);
      }),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    bool isDarkMode,
    Size size,
    NotificationsController controller,
  ) {
    return SmartRefresher(
      controller: controller.refreshController,
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: controller.refreshNotifications,
      onLoading: controller.loadMoreNotifications,
      footer: CustomFooter(
        builder: (context, mode) {
          Widget body;
          if (mode == LoadStatus.loading) {
            body = const NotificationShimmer(count: 2);
          } else if (mode == LoadStatus.noMore) {
            body = const SizedBox.shrink();
          } else if (mode == LoadStatus.failed) {
            body = Text(
              AppTexts.LOAD_FAILED_TAP_RETRY,
              style: AppText.bodySm.copyWith(color: AppColors.textColor2),
            );
          } else {
            body = const SizedBox.shrink();
          }
          return Padding(
            padding: AppInsets.verticalSm,
            child: body,
          );
        },
      ),
      child: Obx(() {
        final hasToday = controller.todayNotifications.isNotEmpty;
        final hasYesterday = controller.yesterdayNotifications.isNotEmpty;
        final hasOlder = controller.olderNotifications.isNotEmpty;
        final hasAny = hasToday || hasYesterday || hasOlder;

        return CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Empty state
            if (!hasAny)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(isDarkMode, size),
              ),

            // Today section
            if (hasToday) ...[
              _buildSectionHeader(AppTexts.NOTIFICATION_TODAY, isDarkMode, size),
              _buildNotificationSection(
                controller.todayNotifications,
                isDarkMode,
                size,
                controller,
              ),
            ],

            // Yesterday section
            if (hasYesterday) ...[
              _buildSectionHeader(AppTexts.NOTIFICATION_YESTERDAY, isDarkMode, size),
              _buildNotificationSection(
                controller.yesterdayNotifications,
                isDarkMode,
                size,
                controller,
              ),
            ],

            // Older section
            if (hasOlder) ...[
              _buildSectionHeader(AppTexts.NOTIFICATION_EARLIER, isDarkMode, size),
              _buildNotificationSection(
                controller.olderNotifications,
                isDarkMode,
                size,
                controller,
                isLast: !controller.hasMoreNotifications.value,
              ),
            ],

            // Loading more indicator at bottom
            if (controller.hasMoreNotifications.value)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                  child: Center(
                    child: Text(
                      'Pull up to load more',
                      style: AppText.bodySm.copyWith(
                        color: isDarkMode ? Colors.white38 : AppColors.textColor2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: size.width * 0.2,
              color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              AppTexts.NO_NOTIFICATION,
              style: AppText.titleMd.copyWith(
                fontSize: 18,
                color: isDarkMode ? Colors.white70 : AppColors.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              AppTexts.NOTIFICATION_SUBTITLE,
              style: AppText.bodyMd.copyWith(
                fontSize: 14,
                color: isDarkMode ? Colors.white38 : AppColors.textColor2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode, Size size) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.012,
        ),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withOpacity(0.03)
              : Colors.grey.shade100,
          border: Border(
            bottom: BorderSide(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade200,
              width: 0.5,
            ),
          ),
        ),
        child: Text(
          title,
          style: AppText.titleMd.copyWith(
            fontSize: 13,
            color: isDarkMode ? Colors.white60 : AppColors.textColor2,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSection(
    List<NotificationModel> notifications,
    bool isDarkMode,
    Size size,
    NotificationsController controller, {
    bool isLast = false,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final isLastItem = index == notifications.length - 1;
          return _buildNotificationItem(
            notifications[index],
            isDarkMode,
            size,
            controller,
            showDivider: !isLastItem || !isLast,
          );
        },
        childCount: notifications.length,
      ),
    );
  }

  Widget _buildNotificationItem(
    NotificationModel notification,
    bool isDarkMode,
    Size size,
    NotificationsController controller, {
    bool showDivider = true,
  }) {
    // Unread: primaryColor tinted background, Read: transparent
    final backgroundColor = notification.read
        ? Colors.transparent
        : (isDarkMode
            ? AppColors.primaryColor.withOpacity(0.12)
            : AppColors.primaryColor.withOpacity(0.08));

    // Time color based on read status
    final timeColor = notification.read
        ? (isDarkMode ? Colors.white30 : AppColors.tertiaryColor)
        : (isDarkMode ? Colors.white54 : AppColors.textColor2);

    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: () => controller.onNotificationTap(notification),
        splashColor: AppColors.primaryColor.withOpacity(0.1),
        highlightColor: AppColors.primaryColor.withOpacity(0.05),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.016,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unread indicator dot
                  if (!notification.read)
                    Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.only(
                        top: size.height * 0.008,
                        right: size.width * 0.025,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    SizedBox(width: size.width * 0.055),

                  // Profile avatar
                  _buildProfileAvatar(notification, isDarkMode, size),

                  SizedBox(width: size.width * 0.03),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message with name highlighted
                        RichText(
                          text: TextSpan(
                            children: _buildMessageSpans(
                              notification,
                              isDarkMode,
                              isRead: notification.read,
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.006),

                        // Time
                        Text(
                          _formatNotificationTime(notification),
                          style: AppText.bodySm.copyWith(
                            fontSize: 12,
                            color: timeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            if (showDivider)
              Divider(
                height: 1,
                thickness: 0.5,
                indent: size.width * 0.17,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.08)
                    : Colors.grey.shade200,
              ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildMessageSpans(
    NotificationModel notification,
    bool isDarkMode, {
    bool isRead = false,
  }) {
    final message = notification.message;
    final fullName = notification.fullName;

    // Colors based on read status
    final nameColor = isRead
        ? (isDarkMode ? Colors.white70 : AppColors.textColor2)
        : (isDarkMode ? Colors.white : AppColors.textColor);

    final textColor = isRead
        ? (isDarkMode ? Colors.white54 : AppColors.tertiaryColor)
        : (isDarkMode ? Colors.white.withOpacity(0.85) : AppColors.textColor);

    // Style for the name (bold)
    final nameStyle = AppText.labelLg.copyWith(
      fontSize: 14,
      color: nameColor,
      fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
      height: 1.4,
    );

    // Style for the rest of the message
    final messageStyle = AppText.bodyMd.copyWith(
      fontSize: 14,
      color: textColor,
      height: 1.4,
    );

    // If the message contains the full name, highlight it
    if (fullName.isNotEmpty && message.contains(fullName)) {
      final parts = message.split(fullName);
      final spans = <TextSpan>[];

      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(text: parts[i], style: messageStyle));
        }
        if (i < parts.length - 1) {
          spans.add(TextSpan(text: fullName, style: nameStyle));
        }
      }

      return spans;
    }

    // Fallback: just return the message as is
    return [TextSpan(text: message, style: messageStyle)];
  }

  Widget _buildProfileAvatar(
    NotificationModel notification,
    bool isDarkMode,
    Size size,
  ) {
    final avatarSize = size.width * 0.12;
    final iconSize = size.width * 0.06;
    final bgColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final iconColor = isDarkMode ? Colors.white54 : Colors.grey.shade500;
    final imageUrl = notification.profileImageUrl?.trim();

    // No image URL
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_outline_rounded,
          size: iconSize,
          color: iconColor,
        ),
      );
    }

    // Local file image
    if (!imageUrl.startsWith('http')) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
      return Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_outline_rounded,
          size: iconSize,
          color: iconColor,
        ),
      );
    }

    // Network image with caching
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Global_Loader(
          size: iconSize * 0.5,
          strokeWidth: 2,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_outline_rounded,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }

  /// Formats notification time in a LinkedIn-style format
  String _formatNotificationTime(NotificationModel notification) {
    final localDateTime = notification.localCreatedAt;
    final now = DateTime.now();
    final difference = now.difference(localDateTime);

    // Less than 1 minute
    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    // Less than 1 hour
    if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '${minutes}m ago';
    }

    // Less than 24 hours
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h ago';
    }

    // Less than 7 days
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '${days}d ago';
    }

    // Less than 30 days
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    }

    // More than 30 days - show date
    return DateFormat('MMM d').format(localDateTime);
  }
}
