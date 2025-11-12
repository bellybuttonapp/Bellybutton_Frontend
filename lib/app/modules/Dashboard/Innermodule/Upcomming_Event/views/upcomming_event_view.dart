// ignore_for_file: annotate_overrides, deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../../../global_widgets/Shimmers/EventCardShimmer.dart';
import '../../../../../global_widgets/eventCard/EventCard.dart';
import '../controllers/upcomming_event_controller.dart';
import '../../Event_gallery/views/event_gallery_view.dart';

class UpcommingEventView extends GetView<UpcommingEventController> {
  UpcommingEventView({super.key});

  // ✅ Explicitly initialize controller
  final UpcommingEventController controller = Get.put(
    UpcommingEventController(),
  );
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: EventCardShimmer(
              itemCount:
                  controller.eventData.isNotEmpty
                      ? controller.eventData.length
                      : 6,
            ),
          );
        }

        // ✅ Add pull-to-refresh to EmptyJobsPlaceholder
        if (controller.eventData.isEmpty) {
          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: false,
            onRefresh: () async {
              await controller.fetchUpcomingEvents();
              _refreshController.refreshCompleted();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: EmptyJobsPlaceholder(
                      imagePath: AppImages.UP_EVENT,
                      description: AppTexts.UPCOMING_EMPTY,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // ✅ Main list view with scrollbar
        return AdaptiveScrollbar(
          controller: _scrollController,
          position: ScrollbarPosition.right,
          width: 10,
          sliderSpacing: const EdgeInsets.symmetric(vertical: 6),
          sliderDefaultColor: AppColors.primaryColor,
          sliderActiveColor: AppColors.primaryColor.withOpacity(0.8),
          underColor:
              isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
          sliderHeight: 100,
          child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () async {
              await controller.fetchUpcomingEvents();
              _refreshController.refreshCompleted();
            },
            child: ListView.separated(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.07,
                vertical: size.height * 0.015,
              ),
              itemCount: controller.eventData.length,
              separatorBuilder:
                  (_, __) => SizedBox(height: size.height * 0.015),
              itemBuilder: (context, index) {
                final event = controller.eventData[index];
                return EventCard(
                  event: event,
                  isDarkMode: isDarkMode,
                  onTap:
                      () => Get.to(() => EventGalleryView(), arguments: event),
                  onEditTap: () => controller.editEvent(event),
                  onDeleteTap: () => controller.confirmDelete(event),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
