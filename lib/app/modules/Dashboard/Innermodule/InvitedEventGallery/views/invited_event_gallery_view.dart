// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../../../global_widgets/ReusableEventGalleryLayout.dart/ReusableEventGalleryLayout.dart';
import '../../../../../global_widgets/Shimmers/EventGalleryShimmer.dart';
import '../../../../../global_widgets/photo_preview_widget/photo_preview_widget.dart';
import '../controllers/invited_event_gallery_controller.dart';

class InvitedEventGalleryView extends GetView<InvitedEventGalleryController> {
  final RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    final c = controller;

    // Safe access to event data
    final eventTitle = c.event?.title ?? "";
    final eventDescription = c.event?.description ?? "";

    return Scaffold(
      body: ReusableEventGalleryLayout(
        appBarTitle: AppTexts.INVITED_EVENT_GALLERY,
        title: eventTitle,
        description: eventDescription,

        suffixWidget: buildSuffixWidget(
          count: "01/01",
          iconPath: AppImages.USERS_COUNT,
          onTap: c.onInvitedUsersTap,
          screenWidth: MediaQuery.of(context).size.width,
        ),

        //----------------------------------------------------
        // BOTTOM BUTTON
        //----------------------------------------------------
        bottomButton: Obx(() {
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

        //----------------------------------------------------
        // GRID VIEW
        //----------------------------------------------------
        gridView: Obx(() {
          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            header: const MaterialClassicHeader(),
            onRefresh: () async {
              await c.refreshGallery();
              _refreshController.refreshCompleted();
            },

            child:
                c.isLoading.value
                    ? const EventGalleryShimmer(
                      itemCount: 40,
                      crossAxisCount: 4,
                    )
                    : c.eventNotStarted
                    ? Center(
                      child: EmptyJobsPlaceholder(
                        title: AppTexts.EVENT_NOT_STARTED_TITLE,
                        description: AppTexts.EVENT_NOT_STARTED_DESC,
                      ),
                    )
                    : c.eventEnded && c.galleryAssets.isEmpty
                    ? Center(
                      child: EmptyJobsPlaceholder(
                        title: AppTexts.EVENT_ENDED_TITLE,
                        description: AppTexts.EVENT_ENDED_DESC,
                      ),
                    )
                    : c.allUploaded
                    ? Center(
                      child: EmptyJobsPlaceholder(
                        title: AppTexts.ALL_PHOTOS_SYNCED_TITLE,
                        description: AppTexts.ALL_PHOTOS_SYNCED_DESC,
                      ),
                    )
                    : c.eventLiveButEmpty
                    ? Center(
                      child: EmptyJobsPlaceholder(
                        title: AppTexts.EVENT_LIVE_EMPTY_TITLE,
                        description: AppTexts.EVENT_LIVE_EMPTY_DESC,
                      ),
                    )
                    : c.noPhotosFound
                    ? Center(
                      child: EmptyJobsPlaceholder(
                        title: AppTexts.NO_PHOTOS_FOUND_TITLE,
                        description: AppTexts.NO_PHOTOS_FOUND_DESC,
                      ),
                    )
                    : GridView.builder(
                      itemCount: c.galleryAssets.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: .7,
                          ),
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
                                enableInfoButton: true,
                                onInfoTap:
                                    () => c.showImageInfoFromIndex(index),
                              ),
                            );
                          },

                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: AssetEntityImage(
                                  asset,
                                  thumbnailSize: const ThumbnailSize(400, 400),
                                  fit: BoxFit.cover,
                                ),
                              ),

                              Obx(() {
                                final selected = c.isSelected(asset);
                                return AnimatedOpacity(
                                  opacity: selected ? 1 : 0,
                                  duration: const Duration(milliseconds: 180),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
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
                            ],
                          ),
                        );
                      },
                    ),
          );
        }),
      ),
    );
  }
}
