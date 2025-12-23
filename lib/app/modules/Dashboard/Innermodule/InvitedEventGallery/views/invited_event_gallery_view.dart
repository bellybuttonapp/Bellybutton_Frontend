// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/services/showcase_service.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../../../global_widgets/ReusableEventGalleryLayout.dart/ReusableEventGalleryLayout.dart';
import '../../../../../global_widgets/Shimmers/EventGalleryShimmer.dart';
import '../../../../../global_widgets/photo_preview_widget/photo_preview_widget.dart';
import '../controllers/invited_event_gallery_controller.dart';

class InvitedEventGalleryView extends GetView<InvitedEventGalleryController> {
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();

  // Showcase GlobalKeys
  static final GlobalKey _membersKey = GlobalKey();
  static final GlobalKey _uploadKey = GlobalKey();

  // Flag to prevent showcase from starting multiple times
  static bool _showcaseStarted = false;

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () {
        ShowcaseService.completeInvitedGalleryTour();
        _showcaseStarted = false;
      },
      builder: (context) => _buildInvitedGallery(context),
    );
  }

  Widget _buildInvitedGallery(BuildContext context) {
    final c = controller;

    // MediaQuery for responsive sizing
    final width = MediaQuery.of(context).size.width;

    // Start showcase tour if not shown before (only once per session)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ShowcaseService.shouldShowInvitedGalleryTour && !_showcaseStarted) {
        _showcaseStarted = true;
        ShowcaseService.startShowcase(
          context,
          [_membersKey, _uploadKey],
        );
      }
    });

    // Safe access to event data
    final eventTitle = c.event?.title ?? "";
    final eventDescription = c.event?.description ?? "";

    return Scaffold(
      body: ReusableEventGalleryLayout(
        appBarTitle: AppTexts.INVITED_EVENT_GALLERY,
        title: eventTitle,
        description: eventDescription,

        suffixWidget: Showcase(
          key: _membersKey,
          title: AppTexts.SHOWCASE_INVITED_MEMBERS_TITLE,
          description: AppTexts.SHOWCASE_INVITED_MEMBERS_DESC,
          tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
          textColor: ShowcaseService.textColor,
          titleTextStyle: ShowcaseService.titleStyle,
          descTextStyle: ShowcaseService.descriptionStyle,
          child: buildSuffixWidget(
            count: "01/01",
            iconPath: AppImages.USERS_COUNT,
            onTap: c.onInvitedUsersTap,
            screenWidth: width,
          ),
        ),

        //----------------------------------------------------
        // BOTTOM BUTTON
        //----------------------------------------------------
        bottomButton: Showcase(
          key: _uploadKey,
          title: AppTexts.SHOWCASE_INVITED_UPLOAD_TITLE,
          description: AppTexts.SHOWCASE_INVITED_UPLOAD_DESC,
          tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
          textColor: ShowcaseService.textColor,
          titleTextStyle: ShowcaseService.titleStyle,
          descTextStyle: ShowcaseService.descriptionStyle,
          child: Obx(() {
            if (c.selectedAssets.isEmpty) {
              return global_button(
                loaderWhite: true,
                title: AppTexts.BTN_UPLOAD_PHOTOS,
                isLoading: c.isUploading.value,
                backgroundColor: AppColors.primaryColor,
                onTap: c.onUploadTap,
              );
            }

            return Row(
              children: [
                Expanded(
                  child: global_button(
                    title: "${AppTexts.BTN_REMOVE} (${c.selectedAssets.length})",
                    backgroundColor: Colors.red,
                    onTap: c.removeSelected,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: global_button(
                    title: AppTexts.BTN_UPLOAD,
                    backgroundColor: AppColors.primaryColor,
                    isLoading: c.isUploading.value,
                    onTap: c.onUploadTap,
                  ),
                ),
              ],
            );
          }),
        ),

        //----------------------------------------------------
        // GRID VIEW
        //----------------------------------------------------
        gridView: Obx(() {
          // ✅ Loading Shimmer
          if (c.isLoading.value) {
            return const EventGalleryShimmer(
              itemCount: 30,
              crossAxisCount: 3,
            );
          }

          // ✅ Empty states
          if (c.eventNotStarted) {
            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              onRefresh: () async {
                await c.refreshGallery();
                _refreshController.refreshCompleted();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyJobsPlaceholder(
                        title: AppTexts.EVENT_NOT_STARTED_TITLE,
                        description: AppTexts.EVENT_NOT_STARTED_DESC,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (c.eventEnded && c.galleryAssets.isEmpty) {
            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              onRefresh: () async {
                await c.refreshGallery();
                _refreshController.refreshCompleted();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyJobsPlaceholder(
                        title: AppTexts.EVENT_ENDED_TITLE,
                        description: AppTexts.EVENT_ENDED_DESC,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (c.allUploaded) {
            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              onRefresh: () async {
                await c.refreshGallery();
                _refreshController.refreshCompleted();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyJobsPlaceholder(
                        title: AppTexts.ALL_PHOTOS_SYNCED_TITLE,
                        description: AppTexts.ALL_PHOTOS_SYNCED_DESC,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (c.eventLiveButEmpty) {
            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              onRefresh: () async {
                await c.refreshGallery();
                _refreshController.refreshCompleted();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyJobsPlaceholder(
                        title: AppTexts.EVENT_LIVE_EMPTY_TITLE,
                        description: AppTexts.EVENT_LIVE_EMPTY_DESC,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (c.noPhotosFound) {
            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              onRefresh: () async {
                await c.refreshGallery();
                _refreshController.refreshCompleted();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyJobsPlaceholder(
                        title: AppTexts.NO_PHOTOS_FOUND_TITLE,
                        description: AppTexts.NO_PHOTOS_FOUND_DESC,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // ✅ Main Grid List - Masonry Layout
          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () async {
              await c.refreshGallery();
              _refreshController.refreshCompleted();
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: MasonryGridView.count(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                itemCount: c.galleryAssets.length,
                itemBuilder: (_, index) {
                  final asset = c.galleryAssets[index];

                  return GestureDetector(
                    onTap: () => c.toggleSelection(asset),
                    onLongPress: () {
                      Get.to(
                        () => ReusablePhotoPreview(
                          images: c.galleryAssets.toList(),
                          isAsset: true,
                          initialIndex: index,
                          enableInfoButton: false,
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: asset.width / asset.height,
                            child: AssetEntityImage(
                              asset,
                              thumbnailSize: const ThumbnailSize(400, 400),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Obx(() {
                            final selected = c.isSelected(asset);
                            return AnimatedOpacity(
                              opacity: selected ? 1 : 0,
                              duration: const Duration(milliseconds: 180),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black.withOpacity(.5),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}