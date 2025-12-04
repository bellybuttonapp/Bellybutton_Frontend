// ignore_for_file: deprecated_member_use, unnecessary_null_comparison, avoid_function_literals_in_foreach_calls, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import 'package:bellybutton/app/core/utils/index.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../global_widgets/EmptyJobsPlaceholder/EmptyJobsPlaceholder.dart';
import '../../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../controllers/inviteuser_controller.dart';

class InviteuserView extends GetView<InviteuserController> {
  const InviteuserView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: AppTexts.INVITE),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _searchField(),
            const SizedBox(height: 12),
            _selectedUsers(),
            const SizedBox(height: 16),
            Expanded(child: _searchResults()),
            const SizedBox(height: 12),
            _inviteButton(isDark),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // Search
  // -------------------------------
  Widget _searchField() {
    return Obx(
      () => GlobalTextField(
        controller: controller.searchController,
        hintText: AppTexts.SEARCH,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(AppImages.SEARCH, width: 22),
        ),
        errorText:
            controller.searchError.value.isEmpty
                ? null
                : controller.searchError.value,
        onChanged: controller.validateSearch,
      ),
    );
  }

  // -------------------------------
  // Selected Chips
  // -------------------------------
  Widget _selectedUsers() {
    return Obx(() {
      if (controller.selectedUsers.isEmpty) return const SizedBox.shrink();
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            controller.selectedUsers.map((contact) {
              return Chip(
                backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                avatar: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      (contact.photo != null && contact.photo!.isNotEmpty)
                          ? MemoryImage(contact.photo!)
                          : null,
                  child:
                      (contact.photo == null || contact.photo!.isEmpty)
                          ? Text(
                            contact.displayName.isNotEmpty
                                ? contact.displayName[0].toUpperCase()
                                : "?",
                            style: customBoldText,
                          )
                          : null,
                ),
                label: Text(contact.displayName, style: customBoldText),
                deleteIcon: SvgPicture.asset(AppImages.CLOSE),
                onDeleted: () => controller.toggleUserSelection(contact),
              );
            }).toList(),
      );
    });
  }

  // -------------------------------
  // Search Results
  // -------------------------------
  Widget _searchResults() {
    return Obx(() {
      if (controller.searchQuery.value.isEmpty) {
        return Center(
          child: Text(
            AppTexts.SEARCH_CONTACTS,
            style: customBoldText.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
        );
      }

      if (controller.searchError.value.isNotEmpty) {
        return Center(
          child: Text(
            controller.searchError.value,
            style: customBoldText.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
        );
      }

      if (controller.filteredContacts.isEmpty) {
        return const EmptyJobsPlaceholder(
          description: AppTexts.NO_CONTACTS_FOUND,
        );
      }

      return ListView.builder(
        itemCount: controller.filteredContacts.length,
        itemBuilder: (c, i) {
          final x = controller.filteredContacts[i];

          return Obx(() {
            final isSelected = controller.selectedUsers.any(
              (u) => u.id == x.id,
            );

            return ListTile(
              onTap: () {
                if (!isSelected && controller.selectedUsers.length >= 5) {
                  showCustomSnackBar(
                    AppTexts.LIMIT_REACHED,
                    SnackbarState.error,
                  );
                  return;
                }
                controller.toggleUserSelection(x);
              },
              leading: FutureBuilder(
                future: controller.fetchPhoto(x),
                builder: (_, __) {
                  return CircleAvatar(
                    backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                    backgroundImage:
                        x.photo != null ? MemoryImage(x.photo!) : null,
                    child:
                        x.photo == null
                            ? Text(
                              x.displayName[0].toUpperCase(),
                              style: customBoldText,
                            )
                            : null,
                  );
                },
              ),
              title: Text(x.displayName, style: customBoldText),
              trailing: Checkbox(
                value: isSelected,
                onChanged: (_) => controller.toggleUserSelection(x),
              ),
            );
          });
        },
      );
    });
  }

  // -------------------------------
  // Button
  // -------------------------------
  Widget _inviteButton(bool isDark) {
    return Obx(
      () => global_button(
        title: AppTexts.INVITE,
        loaderWhite: true,
        isLoading: controller.isLoading.value,
        backgroundColor: AppColors.primaryColor,
        onTap: controller.inviteSelectedUsers,
      ),
    );
  }
}
