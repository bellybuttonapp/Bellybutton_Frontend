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
import '../../../core/utils/themes/dimensions.dart';
import '../../../core/utils/themes/font_style.dart';
import '../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../global_widgets/Loader/global_loader.dart';
import '../../../global_widgets/Shimmers/EventGalleryShimmer.dart';
import '../../../global_widgets/slideshow_preview/slideshow_preview.dart';
import '../controllers/shared_event_gallery_controller.dart';

class SharedEventGalleryView extends GetView<SharedEventGalleryController> {
  const SharedEventGalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    final RefreshController refreshController = RefreshController();
    final ScrollController scrollController = ScrollController();
    final c = controller;

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
        backgroundColor: isDark ? AppColors.scaffoldBackground : AppColors.surfaceVariant,
        appBar: AppBar(
          title: Obx(() => Text(
                c.eventTitle.value.isNotEmpty
                    ? c.eventTitle.value
                    : AppTexts.SHARED_GALLERY,
                style: AppText.titleMd.copyWith(
                  color: isDark ? AppColors.textOnDark : AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              )),
          backgroundColor: isDark ? AppColors.surface : AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.textOnDark : AppColors.textColor,
              size: Dimensions.iconSm,
            ),
            onPressed: () => Get.back(),
          ),
          actions: [
            // Photo count badge
            Obx(() {
              if (c.photos.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: EdgeInsets.only(right: Dimensions.spacing16),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.spacing12,
                  vertical: Dimensions.spacing6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: Dimensions.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_rounded,
                      size: Dimensions.iconXs,
                      color: AppColors.primaryColor,
                    ),
                    AppGap.h4,
                    Text(
                      '${c.photos.length}',
                      style: AppText.labelMd.copyWith(
                        color: AppColors.primaryColor,
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
                      margin: EdgeInsets.fromLTRB(
                        Dimensions.spacing16,
                        Dimensions.spacing16,
                        Dimensions.spacing16,
                        Dimensions.spacing8,
                      ),
                      padding: AppInsets.all16,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceElevated : AppColors.background,
                        borderRadius: Dimensions.borderRadiusMd,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: AppInsets.all8,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: Dimensions.borderRadiusSm,
                            ),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.primaryColor,
                              size: Dimensions.iconSm,
                            ),
                          ),
                          AppGap.h12,
                          Expanded(
                            child: Text(
                              c.eventDescription.value,
                              style: AppText.bodyMd.copyWith(
                                color: isDark ? AppColors.textSecondary : AppColors.textSecondary,
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
                  padding: AppInsets.all12,
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: Dimensions.spacing8,
                    crossAxisSpacing: Dimensions.spacing8,
                    childCount: c.photos.length,
                    itemBuilder: (_, i) {
                      // Load more when near end
                      if (i == c.photos.length - 10 && c.hasMorePhotos) {
                        c.fetchPhotos(loadMore: true);
                      }

                      return GestureDetector(
                        onTap: () {
                          // Single tap opens slideshow preview
                          Get.to(
                            () => SlideshowPreview(
                              images: c.photos.cast<String>(),
                              initialIndex: i,
                              eventTitle: c.eventTitle.value,
                            ),
                            transition: Transition.fadeIn,
                            duration: const Duration(milliseconds: 200),
                          );
                        },
                        child: Hero(
                          tag: 'photo_${c.photos[i]}_$i',
                          child: ClipRRect(
                            borderRadius: Dimensions.borderRadiusMd,
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
                                          AppColors.shimmerBase,
                                          AppColors.shimmerHighlight,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: Dimensions.borderRadiusMd,
                                    ),
                                    child: Center(
                                      child: Global_Loader(
                                        size: Dimensions.iconMd,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: AppColors.shimmerHighlight,
                                      borderRadius: Dimensions.borderRadiusMd,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image_rounded,
                                          color: AppColors.textDisabled,
                                          size: Dimensions.iconXl,
                                        ),
                                        AppGap.v4,
                                        Text(
                                          AppTexts.FAILED_TO_LOAD,
                                          style: AppText.bodyXs.copyWith(
                                            color: AppColors.textDisabled,
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
                                        // Single tap opens slideshow preview
                                        Get.to(
                                          () => SlideshowPreview(
                                            images: c.photos.cast<String>(),
                                            initialIndex: i,
                                            eventTitle: c.eventTitle.value,
                                          ),
                                          transition: Transition.fadeIn,
                                          duration: const Duration(milliseconds: 200),
                                        );
                                      },
                                      splashColor: AppColors.textOnDark.withOpacity(0.2),
                                      highlightColor: AppColors.textOnDark.withOpacity(0.1),
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
