// ignore_for_file: deprecated_member_use, must_be_immutable

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/services/showcase_service.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../../../global_widgets/loader/global_loader.dart';
import '../../../../../global_widgets/Shimmers/ContactsListShimmer.dart';
import '../controllers/inviteuser_controller.dart' show InviteuserController, SafeContact;

class InviteuserView extends GetView<InviteuserController> {
  InviteuserView({super.key});

  // Showcase GlobalKeys - Create unique keys per instance
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _selectKey = GlobalKey();
  final GlobalKey _sendKey = GlobalKey();

  // Flag to prevent showcase from starting multiple times
  bool _showcaseStarted = false;

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () {
        ShowcaseService.completeInviteUsersTour();
        _showcaseStarted = false;
      },
      builder: (context) => _buildInviteUserScreen(context),
    );
  }

  Widget _buildInviteUserScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final verticalSpacing = isSmallScreen ? 12.0 : 16.0;

    // Start showcase tour if not shown before (only once per session)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ShowcaseService.shouldShowInviteUsersTour && !_showcaseStarted) {
        _showcaseStarted = true;
        ShowcaseService.startShowcase(
          context,
          [_searchKey, _selectKey, _sendKey],
        );
      }
    });

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkTheme.scaffoldBackgroundColor
          : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppTexts.INVITE,
        bottom: _buildInviteLimitIndicator(context),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalSpacing,
          ),
          child: Column(
            children: [
              // Search field stays outside the scrollable area
              _buildSearchField(context),
              SizedBox(height: isSmallScreen ? 8 : 12),

              // Scrollable content with SmartRefresher and AdaptiveScrollbar
              Expanded(
                child: AdaptiveScrollbar(
                  controller: controller.scrollController,
                  position: ScrollbarPosition.right,
                  width: 10,
                  sliderSpacing: const EdgeInsets.symmetric(vertical: 6),
                  sliderDefaultColor: AppColors.primaryColor,
                  sliderActiveColor: AppColors.primaryColor.withOpacity(0.8),
                  underColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  sliderHeight: 100,
                  child: SmartRefresher(
                    controller: controller.refreshController,
                    enablePullDown: false,
                    enablePullUp: true,
                    onLoading: controller.loadMoreContacts,
                    footer: CustomFooter(
                      builder: (context, mode) {
                        Widget body;
                        if (mode == LoadStatus.loading) {
                          body = const ContactsListShimmer(count: 3);
                        } else if (mode == LoadStatus.noMore) {
                          body = const SizedBox.shrink();
                        } else if (mode == LoadStatus.failed) {
                          body = Text(
                            'Load failed, tap to retry',
                            style: customBoldText.copyWith(color: Colors.grey),
                          );
                        } else {
                          body = const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: body,
                        );
                      },
                    ),
                    child: CustomScrollView(
                      controller: controller.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Already invited users
                        SliverToBoxAdapter(
                          child: _buildAlreadyInvitedUsers(context),
                        ),
                        // Selected users
                        SliverToBoxAdapter(
                          child: _buildSelectedUsers(context),
                        ),
                        // Search results
                        _buildSearchResultsSliver(context, isDark),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: verticalSpacing),
              _buildInviteButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Invite limit indicator
  Widget _buildInviteLimitIndicator(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Obx(() {
      final total = controller.alreadyInvitedCount + controller.selectedUsers.length;
      final remaining = 4 - total;
      final isLimitReached = remaining <= 0;

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: isSmallScreen ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isLimitReached
              ? Colors.red.withOpacity(0.1)
              : AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLimitReached ? Icons.warning_amber_rounded : Icons.people_outline,
              size: 18,
              color: isLimitReached ? Colors.red : AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              isLimitReached
                  ? AppTexts.LIMIT_REACHED.split('\n').first
                  : "Slots: $total/4 ($remaining remaining)",
              style: customBoldText.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: isLimitReached ? Colors.red : AppColors.primaryColor,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Search input field
  Widget _buildSearchField(BuildContext context) {
    return Showcase(
      key: _searchKey,
      title: AppTexts.SHOWCASE_INVITE_SEARCH_TITLE,
      description: AppTexts.SHOWCASE_INVITE_SEARCH_DESC,
      tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
      textColor: ShowcaseService.textColor,
      titleTextStyle: ShowcaseService.titleStyle,
      descTextStyle: ShowcaseService.descriptionStyle,
      child: GlobalTextField(
        controller: controller.searchController,
        hintText: AppTexts.SEARCH_BY_NAME_OR_NUMBER,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(AppImages.SEARCH, width: 22),
        ),
        onChanged: controller.validateSearch,
      ),
    );
  }

  /// Already invited users chips
  Widget _buildAlreadyInvitedUsers(BuildContext context) {
    return Obx(() {
      if (controller.alreadyInvitedUsers.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.ALREADY_INVITED,
            style: customBoldText.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.alreadyInvitedUsers.map((user) {
              final rawName = controller.getInvitedUserDisplayName(user);
              final displayName = controller.sanitizeDisplayName(rawName);
              final initial = displayName[0].toUpperCase();
              final profileImage = user['profileImage']?.toString();
              final hasNetworkImage = profileImage != null && profileImage.isNotEmpty;

              return Chip(
                backgroundColor: Colors.grey.withOpacity(0.2),
                avatar: hasNetworkImage
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: profileImage,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => CircleAvatar(
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            child: Text(
                              initial,
                              style: customBoldText.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          errorWidget: (_, _, _) => CircleAvatar(
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            child: Text(
                              initial,
                              style: customBoldText.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        child: Text(
                          initial,
                          style: customBoldText.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                label: Text(
                  displayName,
                  style: customBoldText.copyWith(color: Colors.grey[700]),
                ),
                deleteIcon: controller.isRemovingUser.value
                    ? const Global_Loader(size: 16, strokeWidth: 2)
                    : SvgPicture.asset(
                        AppImages.CLOSE,
                        colorFilter: ColorFilter.mode(
                          Colors.grey[600]!,
                          BlendMode.srcIn,
                        ),
                      ),
                onDeleted: controller.isRemovingUser.value
                    ? null
                    : () => _showRemoveConfirmation(context, user),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      );
    });
  }

  /// Remove user confirmation dialog
  void _showRemoveConfirmation(BuildContext context, Map<String, dynamic> user) {
    final rawName = controller.getInvitedUserDisplayName(user);
    final displayName = controller.sanitizeDisplayName(rawName);

    Get.dialog(
      CustomPopup(
        title: AppTexts.REMOVE_USER_CONFIRM_TITLE,
        message: "${AppTexts.REMOVE_USER_CONFIRM_MESSAGE}\n\n$displayName",
        confirmText: AppTexts.BTN_REMOVE,
        cancelText: AppTexts.CANCEL,
        isProcessing: controller.isRemovingUser,
        confirmButtonColor: AppColors.error,
        cancelButtonColor: AppColors.primaryColor,
        onConfirm: () => controller.removeInvitedUser(user),
      ),
      barrierDismissible: true,
    );
  }

  /// Selected users chips
  Widget _buildSelectedUsers(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Obx(() {
      if (controller.selectedUsers.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.NEW_INVITES,
            style: customBoldText.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: isSmallScreen ? 6 : 8,
            runSpacing: isSmallScreen ? 6 : 8,
            children: controller.selectedUsers.map((contact) {
              final displayName = contact.safeName;
              final hasPhoto = contact.photo != null && contact.photo!.isNotEmpty;

              return Chip(
                backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                avatar: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: hasPhoto ? MemoryImage(contact.photo!) : null,
                  child: hasPhoto
                      ? null
                      : Text(
                          displayName[0].toUpperCase(),
                          style: customBoldText,
                        ),
                ),
                label: Text(displayName, style: customBoldText),
                deleteIcon: SvgPicture.asset(AppImages.CLOSE),
                onDeleted: () => controller.toggleUserSelection(contact),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      );
    });
  }

  /// Search results as Sliver
  Widget _buildSearchResultsSliver(BuildContext context, bool isDark) {
    return Obx(() {
      // Loading state with shimmer
      if (controller.isLoadingContacts.value) {
        return const SliverToBoxAdapter(
          child: ContactsListShimmer(count: 8),
        );
      }

      // Permission error state
      if (controller.contactsPermissionError.value.isNotEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.contacts_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  controller.contactsPermissionError.value,
                  style: customBoldText.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // No results state
      if (controller.filteredContacts.isEmpty) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: EmptyJobsPlaceholder(
              description: AppTexts.NO_MATCHING_CONTACTS,
            ),
          ),
        );
      }

      // Results list
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final contact = controller.displayedContacts[index];
            return _buildContactListItem(contact, isFirst: index == 0);
          },
          childCount: controller.displayedContacts.length,
        ),
      );
    });
  }

  /// Single contact list item
  Widget _buildContactListItem(SafeContact contact, {bool isFirst = false}) {
    final displayName = contact.safeName;

    // Trigger photo fetch in background
    controller.fetchPhoto(contact);

    return Obx(() {
      final isSelected = controller.selectedUsers.any((u) => u.id == contact.id);
      final hasPhoto = contact.photo != null;

      final listTile = ListTile(
        onTap: () {
          if (!isSelected && controller.selectedUsers.length >= 4) {
            showCustomSnackBar(AppTexts.LIMIT_REACHED, SnackbarState.error);
            return;
          }
          controller.toggleUserSelection(contact);
        },
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor.withOpacity(0.12),
          backgroundImage: hasPhoto ? MemoryImage(contact.photo!) : null,
          child: hasPhoto
              ? null
              : Text(
                  displayName[0].toUpperCase(),
                  style: customBoldText,
                ),
        ),
        title: Text(displayName, style: customBoldText),
        trailing: Checkbox(
          value: isSelected,
          activeColor: AppColors.primaryColor,
          onChanged: (_) => controller.toggleUserSelection(contact),
        ),
      );

      // Wrap first contact with showcase
      if (isFirst) {
        return Showcase(
          key: _selectKey,
          title: AppTexts.SHOWCASE_INVITE_SELECT_TITLE,
          description: AppTexts.SHOWCASE_INVITE_SELECT_DESC,
          tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
          textColor: ShowcaseService.textColor,
          titleTextStyle: ShowcaseService.titleStyle,
          descTextStyle: ShowcaseService.descriptionStyle,
          child: listTile,
        );
      }

      return listTile;
    });
  }

  /// Invite button (only visible when new users are selected)
  Widget _buildInviteButton() {
    return Obx(() {
      if (controller.selectedUsers.isEmpty) {
        return const SizedBox.shrink();
      }

      return Showcase(
        key: _sendKey,
        title: AppTexts.SHOWCASE_INVITE_SEND_TITLE,
        description: AppTexts.SHOWCASE_INVITE_SEND_DESC,
        tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
        textColor: ShowcaseService.textColor,
        titleTextStyle: ShowcaseService.titleStyle,
        descTextStyle: ShowcaseService.descriptionStyle,
        child: global_button(
          title: AppTexts.INVITE,
          loaderWhite: true,
          isLoading: controller.isLoading.value,
          backgroundColor: AppColors.primaryColor,
          onTap: controller.inviteSelectedUsers,
        ),
      );
    });
  }
}