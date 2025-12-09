// ignore_for_file: file_names, deprecated_member_use, prefer_typing_uninitialized_variables, prefer_if_null_operators, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_texts.dart';
import '../../core/utils/themes/font_style.dart';
import '../EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../GlobalTextField/GlobalTextField.dart';
import '../Shimmers/InvitedUsersShimmer.dart';
import '../../core/constants/app_images.dart';

class MembersListWidget<T extends GetxController> extends StatelessWidget {
  final T controller;

  const MembersListWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    double w(double v) => mq.width * v;
    double h(double v) => mq.height * v;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final c = controller as dynamic;

    /// -------- SAFE AUTO CONTROLLER DETECTION ----------
    late List list;

    try {
      list = c.filteredAdmins; // Admin Controller
    } catch (_) {
      list = c.filteredUsers ?? []; // Users Controller
    }

    return Container(
      color:
          isDark
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(horizontal: w(.045), vertical: h(.018)),

      child: Column(
        children: [
          _searchField(h),
          SizedBox(height: h(.02)),

          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return InvitedUsersShimmer(width: w(1), count: 6);
              }

              return SmartRefresher(
                controller: c.refreshController,
                enablePullDown: true,

                onRefresh: () async {
                  try {
                    // Get event ID - supports both EventModel (id) and InvitedEventModel (eventId)
                    int? eventId;
                    try {
                      eventId = c.event.eventId;
                    } catch (_) {
                      eventId = c.event.id;
                    }

                    if (eventId != null) {
                      try {
                        await c.fetchAdmins(eventId); // Admin Screen
                      } catch (_) {
                        await c.fetchJoinedUsers(eventId); // Users Screen
                      }
                    }
                  } catch (e) {
                    print("❌ Error refreshing members: $e");
                  }
                  c.refreshController.refreshCompleted();
                },

                child:
                    list.isEmpty
                        ? Center(
                          child: EmptyJobsPlaceholder(
                            title: AppTexts.NO_MEMBERS_TITLE,
                            description: AppTexts.NO_MEMBERS_DESCRIPTION,
                          ),
                        )
                        : ListView.separated(
                          padding: EdgeInsets.only(top: h(.01)),
                          physics: const BouncingScrollPhysics(),
                          itemCount: list.length,
                          separatorBuilder:
                              (_, __) => Divider(
                                height: h(.03),
                                thickness: .8,
                                indent: w(.015),
                                endIndent: w(.015),
                                color: Colors.grey.withOpacity(.35),
                              ),
                          itemBuilder: (_, i) => _memberTile(list[i], w),
                        ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 🔍 SearchField
  Widget _searchField(double Function(double) h) {
    final c = controller as dynamic;

    return GlobalTextField(
      hintText: AppTexts.SEARCH,
      controller: c.searchController,
      prefixIcon: Padding(
        padding: EdgeInsets.all(h(.012)),
        child: SvgPicture.asset(AppImages.SEARCH, height: h(.03)),
      ),
      onChanged: c.validateSearch,
      errorText: c.searchError.value.isEmpty ? null : c.searchError.value,
    );
  }

  // 👤 User/Admin Tile
  Widget _memberTile(String name, double Function(double) w) {
    final c = controller as dynamic;
    final isAdmin = c.adminUser?.value == name;
    final letter = name.isNotEmpty ? name[0].toUpperCase() : "?";

    return Padding(
      padding: EdgeInsets.symmetric(vertical: w(.015)),
      child: Row(
        children: [
          CircleAvatar(
            radius: w(.045),
            backgroundColor: AppColors.primaryColor,
            child: Text(
              letter,
              style: customBoldText.copyWith(
                color: Colors.white,
                fontSize: w(.04),
              ),
            ),
          ),

          SizedBox(width: w(.04)),

          Expanded(
            child: Text(
              name,
              style: customBoldText.copyWith(
                fontSize: w(.038),
                color: AppColors.textColor,
              ),
            ),
          ),

          if (isAdmin)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: w(.03),
                vertical: w(.015),
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(.22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange, width: 1.1),
              ),
              child: Text(
                "ADMIN",
                style: customBoldText.copyWith(
                  color: Colors.orange,
                  fontSize: w(.032),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
