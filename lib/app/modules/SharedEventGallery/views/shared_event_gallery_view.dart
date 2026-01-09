// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use, unnecessary_underscores, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:screen_protector/screen_protector.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../global_widgets/Loader/global_loader.dart';
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

    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        // Disable screenshot protection when user navigates back
        await _disableScreenshotProtection();

        // Smart exit: If app was opened from deep link with no navigation history, exit app
        // Otherwise, navigate back normally
        if (Navigator.of(context).canPop() == false) {
          // No previous route - user came directly from deep link
          // Exit the app gracefully
          SystemNavigator.pop();
          return false;
        }

        // Normal back navigation
        return true;
      },
      child: Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Obx(() => Text(
              c.eventTitle.value.isNotEmpty
                  ? c.eventTitle.value
                  : AppTexts.SHARED_GALLERY,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textColor,
                fontSize: width * 0.048,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            )),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.textColor,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Photo count badge
          Obx(() {
            if (c.photos.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_library_rounded,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${c.photos.length}',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
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
                      title: AppTexts.NO_SHOOT_PHOTOS_TITLE,
                      description: AppTexts.NO_SHOOT_PHOTOS_DESCRIPTION,
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
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Event Description Header (if available)
              if (c.eventDescription.value.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            c.eventDescription.value,
                            style: TextStyle(
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                              fontSize: 14,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Photo Grid
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childCount: c.photos.length,
                  itemBuilder: (_, i) {
                    // Load more when near end
                    if (i == c.photos.length - 10 && c.hasMorePhotos) {
                      c.fetchPhotos(loadMore: true);
                    }

                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => ReusablePhotoPreview(
                            images: c.photos,
                            isNetwork: true,
                            initialIndex: i,
                            enableInfoButton: false,
                          ),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 200),
                        );
                      },
                      child: Hero(
                        tag: 'photo_${c.photos[i]}_$i',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: c.photos[i],
                                fit: BoxFit.cover,
                                memCacheWidth: 400,
                                placeholder: (_, __) => Container(
                                  height: 120 + (i % 3) * 40.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey.shade200,
                                        Colors.grey.shade100,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Global_Loader(
                                      size: 24,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image_rounded,
                                        color: Colors.grey.shade400,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Failed to load',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Subtle overlay on tap
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(
                                        () => ReusablePhotoPreview(
                                          images: c.photos,
                                          isNetwork: true,
                                          initialIndex: i,
                                          enableInfoButton: false,
                                        ),
                                        transition: Transition.fadeIn,
                                        duration: const Duration(milliseconds: 200),
                                      );
                                    },
                                    splashColor: Colors.white.withOpacity(0.2),
                                    highlightColor: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      ),
    );
  }

  /// Disable screenshot protection when leaving this page
  Future<void> _disableScreenshotProtection() async {
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (e) {
      debugPrint('Error disabling screenshot protection: $e');
    }
  }
}
