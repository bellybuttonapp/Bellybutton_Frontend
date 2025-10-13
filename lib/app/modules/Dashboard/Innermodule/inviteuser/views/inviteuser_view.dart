// ignore_for_file: deprecated_member_use, unnecessary_null_comparison, avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/themes/Font_style.dart';
import '../../../../../core/themes/dimensions.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(InviteuserController());

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppTexts.invite),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchField(controller),
            const SizedBox(height: 12),
            _buildSelectedUsers(controller),
            const SizedBox(height: 16),
            Expanded(child: _buildSearchResults(controller)),
            const SizedBox(height: 12),
            _inviteButton(isDarkMode, controller),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(InviteuserController controller) {
    return Obx(
      () => GlobalTextField(
        controller: controller.searchController,
        hintText: AppTexts.Search,
        obscureText: false,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(app_images.search, width: 24, height: 24),
        ),
        errorText:
            controller.searchError.value.isEmpty
                ? null
                : controller.searchError.value,
        onChanged: controller.validateSearch,
      ),
    );
  }

  Widget _buildSelectedUsers(InviteuserController controller) {
    return Obx(() {
      if (controller.selectedUsers.isEmpty) return const SizedBox.shrink();

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            controller.selectedUsers.map((contact) {
              return Chip(
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                avatar: CircleAvatar(
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  radius: 12,
                  backgroundImage:
                      (contact.photo != null && contact.photo!.isNotEmpty)
                          ? MemoryImage(contact.photo!)
                          : null,
                  child:
                      (contact.photo == null || contact.photo!.isEmpty)
                          ? Text(
                            contact.displayName != null &&
                                    contact.displayName!.isNotEmpty
                                ? contact.displayName![0].toUpperCase()
                                : '?',
                            style: customBoldText.copyWith(
                              color: AppColors.textColor,
                              fontSize: 12,
                            ),
                          )
                          : null,
                ),
                label: Text(
                  contact.displayName ?? 'Unnamed',
                  style: customBoldText.copyWith(
                    color: AppColors.textColor,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                deleteIcon: SvgPicture.asset(
                  app_images.close,
                  color: AppColors.textColor,
                ),
                onDeleted:
                    () => controller.selectedUsers.removeWhere(
                      (c) => c.id == contact.id,
                    ),
              );
            }).toList(),
      );
    });
  }

  Widget _buildSearchResults(InviteuserController controller) {
    return Obx(() {
      if (controller.searchQuery.value.isEmpty) {
        return Center(
          child: Text(
            "Search users from your contacts..",
            style: customBoldText.copyWith(
              color: AppColors.textColor,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
        );
      }

      if (controller.searchError.value.isNotEmpty) {
        return Center(
          child: Text(
            controller.searchError.value,
            style: customBoldText.copyWith(
              color: AppColors.textColor,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
        );
      }

      if (controller.filteredContacts.isEmpty) {
        return const EmptyJobsPlaceholder(
          description: AppTexts.No_contacts_found,
        );
      }
      // Lazy load photos for visible contacts
      controller.filteredContacts.forEach((contact) {
        if (contact.photo == null || contact.photo!.isEmpty) {
          controller.fetchPhoto(contact);
        }
      });
      return ListView.builder(
        itemCount: controller.filteredContacts.length,
        itemBuilder: (context, index) {
          final contact = controller.filteredContacts[index];

          return Obx(() {
            final isSelected = controller.selectedUsers.any(
              (c) => c.id == contact.id,
            );

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                backgroundImage:
                    (contact.photo != null && contact.photo!.isNotEmpty)
                        ? MemoryImage(contact.photo!)
                        : null,
                child:
                    (contact.photo == null || contact.photo!.isEmpty)
                        ? Text(
                          contact.displayName != null &&
                                  contact.displayName!.isNotEmpty
                              ? contact.displayName![0].toUpperCase()
                              : '?',
                          style: customBoldText.copyWith(
                            color: AppColors.textColor,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        )
                        : null,
              ),
              title: Text(
                contact.displayName ?? 'Unnamed',
                style: customBoldText.copyWith(
                  color: AppColors.textColor,
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),
              trailing: Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (newValue) {
                    if (newValue == true &&
                        controller.selectedUsers.length >= 5 &&
                        !isSelected) {
                      showCustomSnackBar(
                        AppTexts.Limit_Reached,
                        SnackbarState.error,
                      );
                      return;
                    }
                    controller.toggleUserSelection(contact);
                  },
                  activeColor: AppColors.primaryColor,
                  checkColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            );
          });
        },
      );
    });
  }

  Widget _inviteButton(bool isDarkMode, InviteuserController controller) {
    return Obx(
      () => global_button(
        loaderWhite: true,
        isLoading: controller.isLoading.value,
        onTap: () async {
          if (controller.selectedUsers.isNotEmpty) {
            controller.isLoading.value = true;
            await Future.delayed(const Duration(seconds: 2));
            controller.isLoading.value = false;

            showCustomSnackBar(
              "Users invited successfully!",
              SnackbarState.success,
            );

            Get.back();
          } else {
            showCustomSnackBar(
              "Please select at least one user",
              SnackbarState.error,
            );
          }
        },
        title: AppTexts.invite,
        backgroundColor:
            isDarkMode
                ? AppTheme.darkTheme.scaffoldBackgroundColor
                : AppTheme.lightTheme.primaryColor,
      ),
    );
  }
}
