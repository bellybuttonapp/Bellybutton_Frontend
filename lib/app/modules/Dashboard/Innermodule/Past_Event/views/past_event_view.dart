// ignore_for_file: annotate_overrides, deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../../../global_widgets/Shimmers/EventCardShimmer.dart';
import '../../../../../global_widgets/EventCard/EventCard.dart';
import '../../../../../global_widgets/eventCard/InvitedEventCard/InvitedEventCard.dart';
import '../controllers/past_event_controller.dart';
import '../../Event_gallery/views/event_gallery_view.dart';

class PastEventView extends StatefulWidget {
  const PastEventView({super.key});

  @override
  State<PastEventView> createState() => _PastEventViewState();
}

class _PastEventViewState extends State<PastEventView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  // RefreshController is owned by the View, not the Controller
  // This ensures each SmartRefresher gets its own RefreshController
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      body: GetBuilder<PastEventController>(
        init: PastEventController(),
        builder: (controller) {
          return Obx(() {
            // Show shimmer while loading
            if (controller.isLoading.value) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: EventCardShimmer(
                  itemCount:
                      controller.unifiedEvents.isNotEmpty
                          ? controller.unifiedEvents.length
                          : 6,
                ),
              );
            }

            // Main content with SmartRefresher
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
                controller: _refreshController, // Use View's RefreshController
                enablePullDown: true,
                enablePullUp: controller.unifiedEvents.isNotEmpty,
                onRefresh: () async {
                  await controller.fetchPastEvents();
                  _refreshController.refreshCompleted();
                },
                onLoading: () async {
                  await controller.loadMoreEvents(_refreshController);
                },
                footer: CustomFooter(
                  builder: (context, mode) {
                    Widget body;
                    if (mode == LoadStatus.loading) {
                      body = const EventCardShimmer(itemCount: 2);
                    } else if (mode == LoadStatus.noMore) {
                      body = const SizedBox.shrink();
                    } else if (mode == LoadStatus.failed) {
                      body = Text(
                        AppTexts.LOAD_FAILED_TAP_RETRY,
                        style: AppText.headingLg.copyWith(color: Colors.grey),
                      );
                    } else {
                      body = const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: body,
                    );
                  },
                ),
                child: controller.unifiedEvents.isEmpty
                    ? CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: EmptyJobsPlaceholder(
                                imagePath: AppImages.UP_EVENT,
                                description: AppTexts.PAST_SHOOT_EMPTY,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.07,
                          vertical: size.height * 0.015,
                        ),
                        itemCount: controller.displayedEvents.length,
                        separatorBuilder:
                            (_, __) => SizedBox(height: size.height * 0.015),
                        itemBuilder: (context, index) {
                          final unifiedEvent = controller.displayedEvents[index];

                          // Render different cards based on event type
                          if (unifiedEvent.isOwned) {
                            final event = unifiedEvent.ownedEvent!;
                            return EventCard(
                              showViewPhotosInitially: true,
                              event: event,
                              isDarkMode: isDarkMode,
                              onTap: () => Get.to(() => EventGalleryView(), arguments: event),
                              onEditTap: () => controller.editEvent(event),
                              onDeleteTap: () => controller.confirmDelete(event),
                            );
                          } else {
                            final invitedEvent = unifiedEvent.invitedEvent!;
                            return InvitedEventCard(
                              event: invitedEvent,
                              isDarkMode: isDarkMode,
                              onTap: () => controller.openInvitedGallery(invitedEvent),
                              onAcceptTap: () => controller.showAcceptConfirmation(invitedEvent),
                              onDenyTap: () => controller.showDenyConfirmation(invitedEvent),
                            );
                          }
                        },
                      ),
              ),
            );
          });
        },
      ),
    );
  }
}
