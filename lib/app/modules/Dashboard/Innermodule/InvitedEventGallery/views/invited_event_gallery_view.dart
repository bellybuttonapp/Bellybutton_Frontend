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

    return Scaffold(
      body: ReusableEventGalleryLayout(
        appBarTitle: AppTexts.INVITED_EVENT_GALLERY,
        title: c.event.title,
        description: c.event.description,

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
              title: "Upload Photos",
              isLoading: c.isUploading.value,
              backgroundColor: AppColors.primaryColor,
              onTap: c.onUploadTap,
            );
          }

          return Row(
            children: [
              Expanded(
                child: global_button(
                  title: "Remove (${c.selectedAssets.length})",
                  backgroundColor: Colors.red,
                  onTap: c.removeSelected,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: global_button(
                  title: "Upload",
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
                    : c.galleryAssets.isEmpty
                    ? Center(
                      child: EmptyJobsPlaceholder(
                        title: AppTexts.NO_EVENT_PHOTOS_TITLE,
                        description: AppTexts.NO_EVENT_PHOTOS_DESCRIPTION,
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

                        return FutureBuilder(
                          future: asset.thumbnailDataWithSize(
                            const ThumbnailSize(300, 300),
                          ),
                          builder: (_, snapshot) {
                            if (!snapshot.hasData) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.black.withOpacity(.1),
                                ),
                              );
                            }

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
                                      isOriginal: false,
                                      thumbnailSize: const ThumbnailSize(
                                        400,
                                        400,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  Obx(() {
                                    final selected = c.isSelected(asset);

                                    if (!selected) return const SizedBox();

                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.black.withOpacity(.5),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
          );
        }),
      ),
    );
  }
}
