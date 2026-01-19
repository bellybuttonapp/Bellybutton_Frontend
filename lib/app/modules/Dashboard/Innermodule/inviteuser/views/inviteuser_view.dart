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
import '../../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../../../global_widgets/loader/global_loader.dart';
import '../../../../../global_widgets/Shimmers/ContactsListShimmer.dart';
import '../controllers/inviteuser_controller.dart' show InviteuserController, SafeContact;
import '../../../../../global_widgets/CountryPickerDialog/CountryPickerDialog.dart';

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

    // Determine title based on flow
    final title = controller.isReinviteFlow.value
        ? AppTexts.REINVITE_CREW
        : AppTexts.INVITE;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkTheme.scaffoldBackgroundColor
          : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: title,
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
              // Event context header (show event details for update flow)
              Obx(() {
                if (controller.isUpdateFlow.value) {
                  return Column(
                    children: [
                      _buildEventContextHeader(context, isDark),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

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
                            AppTexts.LOAD_FAILED_TAP_RETRY,
                            style: AppText.headingLg.copyWith(color: Colors.grey),
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
                        // Available Contacts Section Header
                        SliverToBoxAdapter(
                          child: _buildAvailableContactsHeader(context, isDark),
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

  /// Invite limit indicator - Simple, compact design
  Widget _buildInviteLimitIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final total = controller.alreadyInvitedCount + controller.selectedUsers.length;
      final progress = total / 4.0;
      final isLimitReached = total >= 4;

      // Color coding
      Color progressColor;
      if (isLimitReached) {
        progressColor = Colors.red;
      } else if (progress >= 0.75) {
        progressColor = Colors.orange;
      } else if (progress >= 0.5) {
        progressColor = Colors.amber;
      } else {
        progressColor = AppColors.primaryColor;
      }

      return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: progressColor.withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 14,
              color: progressColor,
            ),
            AppGap.h8,
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress > 1.0 ? 1.0 : progress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppGap.h8,
            Text(
              "$total/4",
              style: TextStyle(
                fontFamily: 'DM_Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: progressColor,
              ),
            ),
            if (isLimitReached) ...[
              AppGap.h6,
              Icon(
                Icons.warning_rounded,
                size: 14,
                color: Colors.red,
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Event context header - shows event details when updating/reinviting
  Widget _buildEventContextHeader(BuildContext context, bool isDark) {
    final event = controller.eventData;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    // Determine badge text and icon based on flow
    final badgeText = controller.isReinviteFlow.value
        ? AppTexts.REINVITING_CREW
        : AppTexts.UPDATING_SHOOT_BADGE;
    final badgeIcon = controller.isReinviteFlow.value
        ? Icons.group_add_outlined
        : Icons.edit_outlined;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryColor.withOpacity(0.15)
            : AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: AppText.headingLg.copyWith(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                badgeIcon,
                size: 18,
                color: AppColors.primaryColor,
              ),
            ],
          ),
          AppGap.v8,
          Text(
            event.title,
            style: AppText.headingLg.copyWith(
              fontSize: isSmallScreen ? 14 : 16,
              color: isDark ? Colors.white : AppColors.textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (event.description.isNotEmpty &&
              event.description.toLowerCase() != 'active' &&
              event.description.toLowerCase() != 'inactive') ...[
            AppGap.v4,
            Text(
              event.description,
              style: AppText.bodyMd.copyWith(
                fontSize: isSmallScreen ? 12 : 13,
                color: isDark ? Colors.white70 : AppColors.textColor.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          AppGap.v8,
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: isDark ? Colors.white60 : AppColors.textColor.withOpacity(0.6),
              ),
              AppGap.h6,
              Expanded(
                child: Text(
                  "${event.getLocalDateString()} • ${event.getLocalTimeRangeString()}",
                  style: AppText.bodyMd.copyWith(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppColors.textColor.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
          padding: AppInsets.all12,
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

      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple section header
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 18,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
                AppGap.h8,
                Text(
                  AppTexts.CAMERA_CREW,
                  style: AppText.headingLg.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                AppGap.h8,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    controller.alreadyInvitedUsers.length.toString(),
                    style: TextStyle(
                      fontFamily: 'DM_Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                              style: AppText.headingLg.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          errorWidget: (_, _, _) => CircleAvatar(
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            child: Text(
                              initial,
                              style: AppText.headingLg.copyWith(
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
                          style: AppText.headingLg.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                label: Text(
                  displayName,
                  style: AppText.headingLg.copyWith(color: Colors.grey[700]),
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
          AppGap.v12,
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

  /// Available contacts section header
  Widget _buildAvailableContactsHeader(BuildContext context, bool isDark) {
    return Obx(() {
      // Only show if we have contacts and they're not all selected
      if (controller.filteredContacts.isEmpty && !controller.isLoadingContacts.value) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.contacts_outlined,
                size: 16,
                color: isDark ? Colors.white70 : AppColors.primaryColor,
              ),
            ),
            AppGap.h10,
            Text(
              AppTexts.AVAILABLE_CONTACTS,
              style: AppText.headingLg.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: isDark ? Colors.white70 : AppColors.textColor,
              ),
            ),
            AppGap.h8,
            Expanded(
              child: Container(
                height: 1,
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[300],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Selected users chips
  Widget _buildSelectedUsers(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Obx(() {
      if (controller.selectedUsers.isEmpty) {
        return const SizedBox.shrink();
      }

      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple section header
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.person_add_alt_outlined,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
                AppGap.h8,
                Text(
                  AppTexts.ADD_TO_CREW,
                  style: AppText.headingLg.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: isDark ? Colors.white : AppColors.textColor,
                  ),
                ),
                AppGap.h8,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    controller.selectedUsers.length.toString(),
                    style: const TextStyle(
                      fontFamily: 'DM_Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                          style: AppText.headingLg,
                        ),
                ),
                label: Text(displayName, style: AppText.headingLg),
                deleteIcon: SvgPicture.asset(AppImages.CLOSE),
                onDeleted: () => controller.toggleUserSelection(contact),
              );
            }).toList(),
          ),
          AppGap.v12,
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
                AppGap.v12,
                Text(
                  controller.contactsPermissionError.value,
                  style: AppText.headingLg.copyWith(
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
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: AppInsets.all24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]
                          : AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_search_outlined,
                      size: 60,
                      color: isDark
                          ? Colors.grey[600]
                          : AppColors.primaryColor.withOpacity(0.6),
                    ),
                  ),
                  AppGap.v20,
                  Text(
                    controller.searchQuery.value.isEmpty
                        ? "No Contacts Yet"
                        : "No Matching Contacts",
                    style: AppText.headingLg.copyWith(
                      fontSize: Dimensions.fontSizeOverLarge,
                      color: isDark ? Colors.white : AppColors.textColor,
                    ),
                  ),
                  AppGap.v12,
                  Text(
                    controller.searchQuery.value.isEmpty
                        ? "Add contacts to your phone to build\nyour camera crew for shoots."
                        : "No contacts found matching\n\"${controller.searchQuery.value}\"",
                    style: AppText.bodyMd.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: isDark
                          ? Colors.white60
                          : AppColors.textColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (controller.searchQuery.value.isNotEmpty) ...[
                    AppGap.v20,
                    TextButton.icon(
                      onPressed: () {
                        controller.searchController.clear();
                        controller.searchQuery.value = '';
                        controller.filterContacts();
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text("Clear Search"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
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

  /// Handle contact tap - shows country picker for ambiguous numbers
  Future<void> _handleContactTap(SafeContact contact, bool isSelected) async {
    // Check limit first
    if (!isSelected && controller.selectedUsers.length >= 4) {
      showCustomSnackBar(AppTexts.LIMIT_REACHED, SnackbarState.error);
      return;
    }

    // If already selected, just deselect
    if (isSelected) {
      controller.toggleUserSelection(contact);
      return;
    }

    // Check if phone number is ambiguous (valid for both US and India)
    if (contact.phones.isNotEmpty) {
      final rawPhone = contact.phones.first.number;
      debugPrint('📞 [UI] Contact: ${contact.safeName}, Phone: $rawPhone');
      debugPrint('📞 [UI] Is ambiguous: ${controller.isAmbiguousPhoneNumber(rawPhone)}');

      if (controller.isAmbiguousPhoneNumber(rawPhone)) {
        debugPrint('📞 [UI] Showing country picker dialog...');
        // Show country picker dialog
        final selectedCountry = await showCountryPickerDialog(
          context: Get.context!,
          contactName: contact.safeName,
          phoneNumber: rawPhone,
        );

        // If user cancelled, don't add contact
        if (selectedCountry == null) return;

        // Store the selected country code for this contact
        controller.setSelectedCountryCode(contact.id, selectedCountry);
      }
    }

    // Add contact to selection
    controller.toggleUserSelection(contact);
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
        onTap: () => _handleContactTap(contact, isSelected),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor.withOpacity(0.12),
          backgroundImage: hasPhoto ? MemoryImage(contact.photo!) : null,
          child: hasPhoto
              ? null
              : Text(
                  displayName[0].toUpperCase(),
                  style: AppText.headingLg,
                ),
        ),
        title: Text(displayName, style: AppText.headingLg),
        trailing: Checkbox(
          value: isSelected,
          activeColor: AppColors.primaryColor,
          onChanged: (_) => _handleContactTap(contact, isSelected),
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