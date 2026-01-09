// ignore_for_file: annotate_overrides, unnecessary_underscores, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../../../global_widgets/Shimmers/EventCardShimmer.dart';
import '../../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../../../global_widgets/eventCard/InvitedEventCard/InvitedEventCard.dart';
import '../controllers/event_invitations_controller.dart';

class EventInvitationsView extends GetView<EventInvitationsController> {
  // Note: GetView already provides controller via Get.find()
  // The binding handles controller creation via Get.lazyPut()

  final RefreshController _refreshController = RefreshController();

  /// 🔥 Scroll bar controller
  final ScrollController _scrollController = ScrollController();

  EventInvitationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,

      appBar: const CustomAppBar(title: AppTexts.INVITED_SHOOTS),

      body: Obx(() {
        // shimmer while loading
        if (controller.isLoading.value) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: EventCardShimmer(itemCount: 6),
          );
        }

        final events = controller.invitedEvents;

        // ======================= EMPTY + REFRESH + SCROLLBAR =======================
        if (events.isEmpty) {
          return AdaptiveScrollbar(
            controller: _scrollController,
            sliderDefaultColor: AppColors.primaryColor,
            sliderActiveColor: AppColors.primaryColor.withOpacity(0.8),
            underColor: isDarkMode ? Colors.white12 : Colors.black12,
            width: 10,
            sliderHeight: 100,

            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              onRefresh: () async {
                await controller.loadInvitedEvents();
                _refreshController.refreshCompleted();
              },

              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyJobsPlaceholder(
                        description: AppTexts.NO_INVITED_SHOOTS_FOUND,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ======================= LIST + REFRESH + SCROLLBAR =======================
        return AdaptiveScrollbar(
          controller: _scrollController,
          sliderDefaultColor: AppColors.primaryColor,
          sliderActiveColor: AppColors.primaryColor.withOpacity(0.8),
          underColor: isDarkMode ? Colors.white12 : Colors.black12,
          width: 10,
          sliderHeight: 100,

          child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () async {
              await controller.loadInvitedEvents();
              _refreshController.refreshCompleted();
            },

            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.012,
              ),
              itemCount: events.length,
              separatorBuilder: (_, __) => SizedBox(height: h * 0.01),
              itemBuilder: (context, index) {
                final invitedEvent = events[index];
                return InvitedEventCard(
                  event: invitedEvent,
                  isDarkMode: isDarkMode,
                  onTap: () => controller.openInvitedGallery(invitedEvent),
                  onAcceptTap: () => controller.showAcceptConfirmation(invitedEvent),
                  onDenyTap: () => controller.showDenyConfirmation(invitedEvent),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
