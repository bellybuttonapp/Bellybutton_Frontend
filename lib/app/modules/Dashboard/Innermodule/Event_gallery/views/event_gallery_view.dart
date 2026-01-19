// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, curly_braces_in_flow_control_structures, must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/services/showcase_service.dart';
import '../../../../../core/utils/themes/dimensions.dart';
import '../../../../../global_widgets/AppFloatingButton/AppFloatingButton.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../../../global_widgets/Loader/global_loader.dart';
import '../../../../../global_widgets/ReusableEventGalleryLayout.dart/ReusableEventGalleryLayout.dart';
import '../../../../../global_widgets/Shimmers/EventGalleryShimmer.dart';
import '../../../../../global_widgets/photo_preview_widget/photo_preview_widget.dart';
import '../controllers/event_gallery_controller.dart';

class EventGalleryView extends GetView<EventGalleryController> {
  final RefreshController _refresh = RefreshController();
  final ScrollController _scrollController = ScrollController();

  // Showcase GlobalKeys - Create unique keys per instance
  final GlobalKey _membersKey = GlobalKey();
  final GlobalKey _uploadKey = GlobalKey();
  final GlobalKey _shareKey = GlobalKey();
  final GlobalKey _syncKey = GlobalKey();

  // Static flag to prevent showcase from starting multiple times per session
  // (persists across widget rebuilds)
  static bool _showcaseStarted = false;

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () {
        ShowcaseService.completeEventGalleryTour();
        _showcaseStarted = false;
      },
      builder: (context) => _buildEventGallery(context),
    );
  }

  Widget _buildEventGallery(BuildContext context) {
    final c = Get.put(EventGalleryController());

    // MediaQuery for responsive sizing
    final width = MediaQuery.of(context).size.width;

    // Start showcase tour if not shown before (only once per session)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ShowcaseService.shouldShowEventGalleryTour && !_showcaseStarted) {
        _showcaseStarted = true;
        ShowcaseService.startShowcase(
          context,
          [_membersKey, _uploadKey, _shareKey, _syncKey],
        );
      }
    });

    // ------------------------------------------------------
    // 🖼 MAIN LAYOUT WRAPPER
    // ------------------------------------------------------
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        c.handleBackNavigation();
      },
      child: ReusableEventGalleryLayout(
      appBarTitle: AppTexts.SHOOT_GALLERY,
      title: c.event.title,
      description: c.event.description,

      // ------------------------------------------------------
      // 👥 USERS COUNT BADGE (next to title)
      // ------------------------------------------------------
      suffixWidget: Obx(() {
        final currentMembers = controller.invitedCount.value;
        final maxCapacity = controller.totalCapacity.value;

        return Showcase(
          key: _membersKey,
          title: AppTexts.SHOWCASE_GALLERY_MEMBERS_TITLE,
          description: AppTexts.SHOWCASE_GALLERY_MEMBERS_DESC,
          tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
          textColor: ShowcaseService.textColor,
          titleTextStyle: ShowcaseService.titleStyle,
          descTextStyle: ShowcaseService.descriptionStyle,
          child: buildSuffixWidget(
            count: "${currentMembers.toString().padLeft(2, '0')}/${maxCapacity.toString().padLeft(2, '0')}",
            iconPath: AppImages.USERS_COUNT,
            onTap: controller.onInvitedUsersTap,
            screenWidth: width,
          ),
        );
      }),

      // ------------------------------------------------------
      // 📸 PHOTO COUNT BADGE (below description, right corner)
      // ------------------------------------------------------
      belowDescriptionWidget: Obx(() {
        final photoCount = c.photos.length;
        return buildSuffixWidget(
          count: photoCount.toString().padLeft(2, '0'),
          iconPath: AppImages.GALLERY,
          onTap: () {}, // No action needed
          screenWidth: width,
        );
      }),

      // ------------------------------------------------------
      // 📸 GALLERY GRID VIEW + SHIMMER + REFRESH
      // ------------------------------------------------------
      gridView: Obx(() {
        // Loading Shimmer
        if (c.isLoading.value) {
          return const EventGalleryShimmer(itemCount: 30, crossAxisCount: 3);
        }

        // Empty states
        // 1️⃣ EVENT NOT STARTED YET
        if (c.eventNotStarted) {
          return SmartRefresher(
            controller: _refresh,
            enablePullDown: true,
            onRefresh: () async {
              await c.fetchPhotos();
              _refresh.refreshCompleted();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: EmptyJobsPlaceholder(
                      title: AppTexts.SHOOT_GALLERY_NOT_STARTED_TITLE,
                      description: AppTexts.SHOOT_GALLERY_NOT_STARTED_DESC,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 2️⃣ EVENT ENDED & NO PHOTOS WERE SHARED
        if (c.eventEnded && c.photos.isEmpty) {
          return SmartRefresher(
            controller: _refresh,
            enablePullDown: true,
            onRefresh: () async {
              await c.fetchPhotos();
              _refresh.refreshCompleted();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: EmptyJobsPlaceholder(
                      title: AppTexts.SHOOT_GALLERY_ENDED_EMPTY_TITLE,
                      description: AppTexts.SHOOT_GALLERY_ENDED_EMPTY_DESC,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 3️⃣ ALL PHOTOS ALREADY SYNCED
        if (c.allSynced && c.photos.isNotEmpty) {
          return SmartRefresher(
            controller: _refresh,
            enablePullDown: true,
            onRefresh: () async {
              await c.fetchPhotos();
              _refresh.refreshCompleted();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: EmptyJobsPlaceholder(
                      title: AppTexts.SHOOT_GALLERY_ALL_SYNCED_TITLE,
                      description: AppTexts.SHOOT_GALLERY_ALL_SYNCED_DESC,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 4️⃣ EVENT LIVE BUT NO PHOTOS YET
        if (c.eventLiveButEmpty) {
          return SmartRefresher(
            controller: _refresh,
            enablePullDown: true,
            onRefresh: () async {
              await c.fetchPhotos();
              _refresh.refreshCompleted();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: EmptyJobsPlaceholder(
                      title: AppTexts.SHOOT_GALLERY_LIVE_EMPTY_TITLE,
                      description: AppTexts.SHOOT_GALLERY_LIVE_EMPTY_DESC,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 5️⃣ FALLBACK: NO PHOTOS FOUND (GENERIC)
        if (c.photos.isEmpty) {
          return SmartRefresher(
            controller: _refresh,
            enablePullDown: true,
            onRefresh: () async {
              await c.fetchPhotos();
              _refresh.refreshCompleted();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: EmptyJobsPlaceholder(
                      title: AppTexts.NO_SHOOT_PHOTOS_TITLE,
                      description: AppTexts.NO_SHOOT_PHOTOS_DESCRIPTION,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Main Grid List - Masonry Layout
        return SmartRefresher(
          controller: _refresh,
          enablePullDown: true,
          onRefresh: () async {
            await c.fetchPhotos();
            _refresh.refreshCompleted();
          },
          child: Padding(
            padding: AppInsets.all8,
            child: MasonryGridView.count(
              controller: _scrollController,
              shrinkWrap: false,
              physics: const ClampingScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              itemCount: c.photos.length,
              itemBuilder: (_, i) {
                if (i == c.photos.length - 10) c.fetchPhotos(loadMore: true);

                return GestureDetector(
                  onTap: () {
                    Get.to(
                      () => ReusablePhotoPreview(
                        images: c.photos,
                        isNetwork: true,
                        initialIndex: i,
                        enableInfoButton: true,
                        onInfoTapWithIndex: (currentIndex) =>
                            c.showMediaInfoBottomSheet(currentIndex),
                      ),
                      transition: Transition.fadeIn,
                      duration: const Duration(milliseconds: 150),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: c.photos[i],
                      fit: BoxFit.cover,
                      memCacheWidth: 400,
                      placeholder: (_, _) => Container(
                        height: 120 + (i % 3) * 40.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Global_Loader(
                            size: 20,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: Colors.grey,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),

      // ------------------------------------------------------
      // 🔄 BOTTOM SYNC BUTTON (Only show after event ends)
      // One-time sync to prevent photo duplication
      // ------------------------------------------------------
      bottomButton: Builder(builder: (_) {
        // Hide sync button if event hasn't ended yet
        if (!c.eventEnded) {
          return const SizedBox.shrink();
        }

        return Showcase(
          key: _syncKey,
          title: AppTexts.SHOWCASE_GALLERY_SYNC_TITLE,
          description: AppTexts.SHOWCASE_GALLERY_SYNC_DESC,
          tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
          textColor: ShowcaseService.textColor,
          titleTextStyle: ShowcaseService.titleStyle,
          descTextStyle: ShowcaseService.descriptionStyle,
          child: Obx(() {
            // Check permanent sync completion saved in Hive (event-specific)
            bool syncedOnce = c.allSynced;

            // Also check live runtime values
            bool fullySynced =
                c.savedCount.value == c.totalToSave.value && c.totalToSave.value != 0;

            // Check if auto-sync is enabled
            bool isAutoSyncOn = c.isAutoSyncEnabled.value;
            bool isCurrentlySyncing = c.isAutoSyncing.value;

            // If already synced (one-time sync completed), show grey completed status but still tappable
            if (syncedOnce || fullySynced) {
              return global_button(
                title: "${AppTexts.SYNC_COMPLETED} (${c.savedCount}/${c.totalToSave})",
                backgroundColor: Colors.grey.shade400,
                loaderWhite: true,
                onTap: c.syncNow, // Still tappable to re-sync if needed
              );
            }

            // If auto-sync is ON and currently syncing
            if (isAutoSyncOn && isCurrentlySyncing) {
              return global_button(
                title: c.savedCount.value > 0
                    ? "${AppTexts.AUTO_SYNCING} (${c.savedCount}/${c.totalToSave})"
                    : AppTexts.AUTO_SYNCING,
                backgroundColor: AppColors.primaryColor,
                loaderWhite: true,
                isLoading: true,
                onTap: null,
              );
            }

            // Show manual Sync Now button (one-time sync)
            return global_button(
              title: AppTexts.SYNC_NOW,
              backgroundColor: AppColors.primaryColor,
              loaderWhite: true,
              isLoading: !c.enableOK.value &&
                  c.savedCount.value > 0 &&
                  c.savedCount.value < c.totalToSave.value,
              onTap: c.syncNow,
            );
          }),
        );
      }),

      // ------------------------------------------------------
      // ⚡ FLOATING ACTIONS
      // Share button only shows after event ends (to prevent duplicates)
      // Upload/Invite button always visible
      // ------------------------------------------------------
      floatingButtons: [
        // Share FAB - Only show after event ends, grey when synced but still tappable
        if (c.eventEnded)
          Showcase(
            key: _shareKey,
            title: AppTexts.SHOWCASE_GALLERY_SHARE_TITLE,
            description: AppTexts.SHOWCASE_GALLERY_SHARE_DESC,
            tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
            textColor: ShowcaseService.textColor,
            titleTextStyle: ShowcaseService.titleStyle,
            descTextStyle: ShowcaseService.descriptionStyle,
            child: AppFloatingButton(
              backgroundColor: c.allSynced ? Colors.grey.shade400 : AppColors.primaryColor,
              iconPath: AppImages.EXPORT_ICON,
              onTap: c.fabOneAction,
            ),
          ),
        if (c.eventEnded) AppGap.v20,
        // Upload/Invite FAB - Always visible
        Showcase(
          key: _uploadKey,
          title: AppTexts.SHOWCASE_GALLERY_UPLOAD_TITLE,
          description: AppTexts.SHOWCASE_GALLERY_UPLOAD_DESC,
          tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
          textColor: ShowcaseService.textColor,
          titleTextStyle: ShowcaseService.titleStyle,
          descTextStyle: ShowcaseService.descriptionStyle,
          child: AppFloatingButton(
            backgroundColor: AppColors.primaryColor,
            iconPath: AppImages.INVITE_ICON,
            onTap: c.fabTwoAction,
          ),
        ),
      ],
    ),
    );
  }
}