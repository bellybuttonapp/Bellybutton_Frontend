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

  // Showcase GlobalKeys - Instance-level to avoid duplicate key errors
  final GlobalKey _membersKey = GlobalKey();
  final GlobalKey _uploadKey = GlobalKey();

  // Static flag to prevent showcase from starting multiple times per session
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

        // Only include upload key if button will be visible
        final canUpload = !c.eventNotStarted && !c.eventEnded && c.galleryAssets.isNotEmpty;
        final showcaseKeys = canUpload
            ? [_membersKey, _uploadKey]
            : [_membersKey];

        ShowcaseService.startShowcase(context, showcaseKeys);
      }
    });

    // Safe access to event data
    final eventTitle = c.event?.title ?? "";
    final eventDescription = c.event?.description ?? "";

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        c.handleBackNavigation();
      },
      child: Scaffold(
        body: ReusableEventGalleryLayout(
        appBarTitle: AppTexts.INVITED_SHOOT_GALLERY,
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
          child: Obx(() {
            final currentMembers = c.invitedCount.value;
            final maxCapacity = c.totalCapacity.value;

            return buildSuffixWidget(
              count: "${currentMembers.toString().padLeft(2, '0')}/${maxCapacity.toString().padLeft(2, '0')}",
              iconPath: AppImages.USERS_COUNT,
              onTap: c.onInvitedUsersTap,
              screenWidth: width,
            );
          }),
        ),

        //----------------------------------------------------
        // BOTTOM BUTTON
        // Flow: Select to Exclude
        // - No selection → "Upload All (X)" uploads everything
        // - Has selection → selected images are EXCLUDED from upload
        // - "Clear (X)" removes exclusion marks
        // - "Upload (Y)" uploads non-excluded images
        //----------------------------------------------------
        bottomButton: Obx(() {
          // 🔥 IMPORTANT: Access all observables FIRST to register with GetX
          final galleryAssets = c.galleryAssets;
          final selectedAssets = c.selectedAssets; // Selected = Excluded
          final isUploading = c.isUploading.value;

          // Now compute derived values using the accessed observables
          final totalPhotos = galleryAssets.length;
          final hasPhotos = totalPhotos > 0;
          final excludedCount = selectedAssets.length;
          final hasExclusions = excludedCount > 0;
          final uploadCount = totalPhotos - excludedCount;

          // Hide upload button if event not started, ended, or no photos
          final canUpload = !c.eventNotStarted && !c.eventEnded && hasPhotos;

          if (!canUpload) {
            return const SizedBox.shrink();
          }

          // No exclusions → Show "Upload All (X)" button
          if (!hasExclusions) {
            return Showcase(
              key: _uploadKey,
              title: AppTexts.SHOWCASE_INVITED_UPLOAD_TITLE,
              description: AppTexts.SHOWCASE_INVITED_UPLOAD_DESC,
              tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
              textColor: ShowcaseService.textColor,
              titleTextStyle: ShowcaseService.titleStyle,
              descTextStyle: ShowcaseService.descriptionStyle,
              child: global_button(
                loaderWhite: true,
                title: "Upload All ($totalPhotos)",
                isLoading: isUploading,
                backgroundColor: AppColors.primaryColor,
                onTap: c.onUploadTap,
              ),
            );
          }

          // Has exclusions → Show "Clear" + "Upload" buttons
          return Row(
            children: [
              // Clear button - removes all exclusion marks
              Expanded(
                child: global_button(
                  title: "Clear ($excludedCount)",
                  backgroundColor: Colors.grey.shade600,
                  onTap: c.clearSelection,
                ),
              ),
              const SizedBox(width: 10),
              // Upload button - uploads non-excluded images
              Expanded(
                child: global_button(
                  title: "Upload ($uploadCount)",
                  backgroundColor: uploadCount > 0
                      ? AppColors.primaryColor
                      : Colors.grey,
                  isLoading: isUploading,
                  onTap: uploadCount > 0 ? c.onUploadTap : null,
                ),
              ),
            ],
          );
        }),

        //----------------------------------------------------
        // GRID VIEW
        //----------------------------------------------------
        gridView: Obx(() {
          // 🔥 IMPORTANT: Access all observables FIRST to register with GetX
          final galleryAssets = c.galleryAssets;
          final isLoading = c.isLoading.value;
          // Access uploadedCount to track changes (used in allUploaded getter)
          c.uploadedCount.value;

          // ✅ Loading Shimmer
          if (isLoading) {
            return const EventGalleryShimmer(
              itemCount: 30,
              crossAxisCount: 3,
            );
          }

          // ✅ Empty states
          if (c.eventNotStarted) {
            return _buildEmptyState(
              title: AppTexts.SHOOT_NOT_STARTED_TITLE,
              description: AppTexts.SHOOT_NOT_STARTED_DESC,
            );
          }

          if (c.allUploaded) {
            return _buildEmptyState(
              title: AppTexts.ALL_PHOTOS_SYNCED_TITLE,
              description: AppTexts.ALL_PHOTOS_SYNCED_DESC,
            );
          }

          if (c.eventLiveButEmpty) {
            return _buildEmptyState(
              title: AppTexts.SHOOT_LIVE_EMPTY_TITLE,
              description: AppTexts.SHOOT_LIVE_EMPTY_DESC,
            );
          }

          if (c.noPhotosFound) {
            return _buildEmptyState(
              title: AppTexts.SHOOT_ENDED_TITLE,
              description: AppTexts.SHOOT_ENDED_DESC,
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
                shrinkWrap: false,
                physics: const ClampingScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                itemCount: galleryAssets.length,
                itemBuilder: (_, index) {
                  final asset = galleryAssets[index];

                  return GestureDetector(
                    onTap: () => c.toggleSelection(asset),
                    onLongPress: () {
                      Get.to(
                        () => ReusablePhotoPreview(
                          images: galleryAssets.toList(),
                          isAsset: true,
                          initialIndex: index,
                          enableInfoButton: false,
                        ),
                      );
                    },
                    child: _buildGridItem(asset),
                  );
                },
              ),
            ),
          );
        }),
      ),
      ),
    );
  }

  /// Build empty state with SmartRefresher for pull-to-refresh
  Widget _buildEmptyState({required String title, required String description}) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: () async {
        await controller.refreshGallery();
        _refreshController.refreshCompleted();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: EmptyJobsPlaceholder(
                title: title,
                description: description,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual grid item with exclusion overlay
  /// Selected = Excluded from upload (shows X icon)
  Widget _buildGridItem(dynamic asset) {
    // Calculate safe aspect ratio
    final aspectRatio = (asset.height > 0)
        ? (asset.width / asset.height).clamp(0.5, 2.0)
        : 1.0;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: AssetEntityImage(
              asset,
              thumbnailSize: const ThumbnailSize(400, 400),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: Obx(() {
            // 🔥 Access the observable list to register with GetX
            final selectedList = controller.selectedAssets;
            final isExcluded = selectedList.contains(asset);

            return AnimatedOpacity(
              opacity: isExcluded ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(.6),
                ),
                child: const Center(
                  child: Icon(
                    Icons.cancel, // X icon to indicate exclusion
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
