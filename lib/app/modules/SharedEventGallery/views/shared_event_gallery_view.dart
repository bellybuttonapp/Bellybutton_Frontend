// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use, curly_braces_in_flow_control_structures, unnecessary_underscores

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/utils/themes/font_style.dart';
import '../../../global_widgets/Button/global_button.dart';
import '../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../global_widgets/Loader/global_loader.dart';
import '../../../global_widgets/ReusableEventGalleryLayout.dart/ReusableEventGalleryLayout.dart';
import '../../../global_widgets/Shimmers/EventGalleryShimmer.dart';
import '../../../global_widgets/photo_preview_widget/photo_preview_widget.dart';
import '../controllers/shared_event_gallery_controller.dart';

class SharedEventGalleryView extends GetView<SharedEventGalleryController> {
  const SharedEventGalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    final RefreshController refreshController = RefreshController();
    final ScrollController scrollController = ScrollController();
    final c = controller;

    // MediaQuery for responsive sizing
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ReusableEventGalleryLayout(
      appBarTitle: AppTexts.SHARED_GALLERY,
      title: c.event.title,
      description: c.event.description,

      // ------------------------------------------------------
      // 🔒 PERMISSION BADGE (TOP RIGHT)
      // ------------------------------------------------------
      suffixWidget: Obx(() => _buildPermissionBadge(c, width, isDark)),

      // ------------------------------------------------------
      // 📸 GALLERY GRID VIEW
      // ------------------------------------------------------
      gridView: Obx(() {
        // Loading Shimmer
        if (c.isLoading.value) {
          return const EventGalleryShimmer(itemCount: 30, crossAxisCount: 3);
        }

        // Empty state - No photos
        if (c.photos.isEmpty) {
          return SmartRefresher(
            controller: refreshController,
            enablePullDown: true,
            onRefresh: () async {
              await c.fetchPhotos();
              refreshController.refreshCompleted();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: EmptyJobsPlaceholder(
                      title: AppTexts.NO_EVENT_PHOTOS_TITLE,
                      description: AppTexts.NO_EVENT_PHOTOS_DESCRIPTION,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Main Grid - Masonry Layout
        return SmartRefresher(
          controller: refreshController,
          enablePullDown: true,
          onRefresh: () async {
            await c.fetchPhotos();
            refreshController.refreshCompleted();
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: MasonryGridView.count(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              itemCount: c.photos.length,
              itemBuilder: (_, i) {
                // Load more when near end
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
                      placeholder: (_, __) => Container(
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
                      errorWidget: (_, __, ___) => Container(
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
      // 🔄 BOTTOM BUTTON (SYNC OR VIEW ONLY MESSAGE)
      // ------------------------------------------------------
      bottomButton: Obx(() {
        // If permission is view-only, show info message
        if (!c.canSync) {
          return _buildViewOnlyMessage(width, isDark);
        }

        // If already synced
        if (c.alreadySynced) {
          return global_button(
            title: "${AppTexts.SYNC_COMPLETE} (${c.savedCount}/${c.totalToSave})",
            backgroundColor: AppColors.success,
            onTap: null,
          );
        }

        // Sync button for view-sync permission
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

      // No floating buttons for shared gallery
      floatingButtons: const [],
    );
  }

  // ------------------------------------------------------
  // 🔒 PERMISSION BADGE WIDGET
  // ------------------------------------------------------
  Widget _buildPermissionBadge(SharedEventGalleryController c, double width, bool isDark) {
    final isViewOnly = !c.canSync;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.03,
        vertical: width * 0.015,
      ),
      decoration: BoxDecoration(
        color: isViewOnly
            ? Colors.orange.withOpacity(0.15)
            : AppColors.success.withOpacity(0.15),
        borderRadius: BorderRadius.circular(width * 0.02),
        border: Border.all(
          color: isViewOnly ? Colors.orange : AppColors.success,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isViewOnly ? Icons.visibility : Icons.sync,
            size: width * 0.04,
            color: isViewOnly ? Colors.orange : AppColors.success,
          ),
          SizedBox(width: width * 0.015),
          Text(
            isViewOnly ? AppTexts.VIEW_ONLY : AppTexts.VIEW_AND_SYNC,
            style: customMediumText.copyWith(
              fontSize: width * 0.03,
              color: isViewOnly ? Colors.orange : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  // 📝 VIEW ONLY MESSAGE WIDGET
  // ------------------------------------------------------
  Widget _buildViewOnlyMessage(double width, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: width * 0.035,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.orange.withOpacity(0.1)
            : Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(width * 0.025),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: width * 0.055,
            color: Colors.orange,
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Text(
              AppTexts.VIEW_ONLY_ACCESS_MESSAGE,
              style: customMediumText.copyWith(
                fontSize: width * 0.033,
                color: isDark ? Colors.orange.shade200 : Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}