// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, unnecessary_underscores, curly_braces_in_flow_control_structures

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/utils/storage/preference.dart';
import '../../../../../global_widgets/AppFloatingButton/AppFloatingButton.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../../../global_widgets/ReusableEventGalleryLayout.dart/ReusableEventGalleryLayout.dart';
import '../../../../../global_widgets/Shimmers/EventGalleryShimmer.dart';
import '../../../../../global_widgets/photo_preview_widget/photo_preview_widget.dart';
import '../controllers/event_gallery_controller.dart';

class EventGalleryView extends GetView<EventGalleryController> {
  final RefreshController _refresh = RefreshController();

  @override
  Widget build(BuildContext context) {
    final c = Get.put(EventGalleryController());

    // ------------------------------------------------------
    // 🖼 MAIN LAYOUT WRAPPER
    // ------------------------------------------------------
    return ReusableEventGalleryLayout(
      appBarTitle: AppTexts.EVENT_GALLERY,
      title: c.event.title,
      description: c.event.description,

      // ------------------------------------------------------
      // 👥 USERS COUNT BADGE (TOP RIGHT IN APPBAR)
      // ------------------------------------------------------
      suffixWidget: Obx(() {
        return buildSuffixWidget(
          count:
              "${controller.invitedCount.value.toString().padLeft(2, '0')}/01",
          iconPath: AppImages.USERS_COUNT,
          onTap: controller.onInvitedUsersTap,
          screenWidth: MediaQuery.of(context).size.width,
        );
      }),

      // ------------------------------------------------------
      // 📸 GALLERY GRID VIEW + SHIMMER + REFRESH
      // ------------------------------------------------------
      gridView: Obx(() {
        return SmartRefresher(
          controller: _refresh,
          enablePullDown: true,
          header: const MaterialClassicHeader(),
          onRefresh: () async {
            await c.fetchPhotos();
            _refresh.refreshCompleted();
          },

          child:
              // ------------------------------------------------------
              // ⏳ LOADING STATE
              // ------------------------------------------------------
              c.isLoading.value
                  ? const EventGalleryShimmer(itemCount: 40, crossAxisCount: 4)
                  // ------------------------------------------------------
                  // 1️⃣ EVENT NOT STARTED YET
                  // ------------------------------------------------------
                  : c.eventNotStarted
                  ? Center(
                    child: EmptyJobsPlaceholder(
                      title: AppTexts.EVENT_GALLERY_NOT_STARTED_TITLE,
                      description: AppTexts.EVENT_GALLERY_NOT_STARTED_DESC,
                    ),
                  )
                  // ------------------------------------------------------
                  // 2️⃣ EVENT ENDED & NO PHOTOS WERE SHARED
                  // ------------------------------------------------------
                  : c.eventEnded && c.photos.isEmpty
                  ? Center(
                    child: EmptyJobsPlaceholder(
                      title: AppTexts.EVENT_GALLERY_ENDED_EMPTY_TITLE,
                      description: AppTexts.EVENT_GALLERY_ENDED_EMPTY_DESC,
                    ),
                  )
                  // ------------------------------------------------------
                  // 3️⃣ ALL PHOTOS ALREADY SYNCED
                  // ------------------------------------------------------
                  : c.allSynced && c.photos.isNotEmpty
                  ? Center(
                    child: EmptyJobsPlaceholder(
                      title: AppTexts.EVENT_GALLERY_ALL_SYNCED_TITLE,
                      description: AppTexts.EVENT_GALLERY_ALL_SYNCED_DESC,
                    ),
                  )
                  // ------------------------------------------------------
                  // 4️⃣ EVENT LIVE BUT NO PHOTOS YET
                  // ------------------------------------------------------
                  : c.eventLiveButEmpty
                  ? Center(
                    child: EmptyJobsPlaceholder(
                      title: AppTexts.EVENT_GALLERY_LIVE_EMPTY_TITLE,
                      description: AppTexts.EVENT_GALLERY_LIVE_EMPTY_DESC,
                    ),
                  )
                  // ------------------------------------------------------
                  // 5️⃣ FALLBACK: NO PHOTOS FOUND (GENERIC)
                  // ------------------------------------------------------
                  : c.photos.isEmpty
                  ? Center(
                    child: EmptyJobsPlaceholder(
                      title: AppTexts.NO_EVENT_PHOTOS_TITLE,
                      description: AppTexts.NO_EVENT_PHOTOS_DESCRIPTION,
                    ),
                  )
                  // ------------------------------------------------------
                  // 🔥 GALLERY PHOTOS GRID
                  // ------------------------------------------------------
                  : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: c.photos.length,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: .7,
                        ),
                    itemBuilder: (_, i) {
                      if (i == c.photos.length - 10)
                        c.fetchPhotos(loadMore: true);

                      return GestureDetector(
                        onLongPress: () {
                          Get.to(
                            () => ReusablePhotoPreview(
                              images: c.photos,
                              isNetwork: true,
                              initialIndex: i,
                            ),
                            transition: Transition.fadeIn,
                            duration: const Duration(milliseconds: 150),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: c.photos[i],
                            fit: BoxFit.cover,
                            memCacheWidth: 300,
                            memCacheHeight: 300,
                            placeholder:
                                (_, __) => const EventGalleryShimmer(
                                  itemCount: 1,
                                  crossAxisCount: 1,
                                ),
                            errorWidget:
                                (_, __, ___) => Container(
                                  color: Colors.black12,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                  ),
                                ),
                          ),
                        ),
                      );
                    },
                  ),
        );
      }),

      // ------------------------------------------------------
      // 🔄 BOTTOM SYNC BUTTON (FINAL WORKING LOGIC)
      // ------------------------------------------------------
      bottomButton: Obx(() {
        // 🔥 Check permanent sync completion saved in Hive
        bool syncedOnce =
            Preference.box.get(Preference.EVENT_SYNC_DONE) == true;

        // 🔥 Also check live runtime values
        bool fullySynced =
            c.savedCount.value == c.totalToSave.value &&
            c.totalToSave.value != 0;

        return global_button(
          title:
              (syncedOnce || fullySynced)
                  ? "Completed (${c.savedCount}/${c.totalToSave})"
                  : "Sync Now",

          backgroundColor: AppColors.primaryColor,
          loaderWhite: true,

          isLoading:
              !c.enableOK.value &&
              c.savedCount.value > 0 &&
              c.savedCount.value < c.totalToSave.value,

          onTap: (syncedOnce || fullySynced) ? null : c.syncNow,
        );
      }),

      // ------------------------------------------------------
      // ⚡ FLOATING ACTIONS
      // ------------------------------------------------------
      floatingButtons: [
        AppFloatingButton(
          backgroundColor: AppColors.primaryColor,
          iconPath: AppImages.EXPORT_ICON,
          onTap: c.fabOneAction,
        ),
        const SizedBox(height: 20),
        AppFloatingButton(
          backgroundColor: AppColors.primaryColor,
          iconPath: AppImages.INVITE_ICON,
          onTap: c.fabTwoAction,
        ),
      ],
    );
  }
}
