import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/themes/Font_style.dart';
import '../../../../../core/themes/dimensions.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../../Auth/signup/Widgets/Signup_textfield.dart';
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
            Inviteuser(isDarkMode),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(InviteuserController controller) {
    return Obx(
      () => Signup_textfield(
        controller: controller.searchController,
        hintText: "Search..",
        obscureText: false,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0), // adjust padding as needed
          child: SvgPicture.asset(
            'assets/images/search.svg', // your SVG path
            width: 24,
            height: 24,
          ),
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
            controller.selectedUsers
                .map(
                  (id) => Chip(
                    label: Text(
                      "User $id",
                      style: customBoldText.copyWith(
                        color: AppColors.textColor,
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => controller.selectedUsers.remove(id),
                  ),
                )
                .toList(),
      );
    });
  }

  Widget _buildSearchResults(InviteuserController controller) {
    return Obx(() {
      // Show prompt if empty
      if (controller.searchQuery.value.isEmpty) {
        return Center(
          child: Text(
            "Start typing to search users",
            style: customBoldText.copyWith(
              color: AppColors.textColor,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
        );
      }

      // Show error if validation fails
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

      // Valid input → show search results
      final results = List.generate(
        5,
        (index) => "User ${controller.searchQuery.value} $index",
      );

      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final user = results[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              user,
              style: customBoldText.copyWith(
                color: AppColors.textColor,
                fontSize: Dimensions.fontSizeLarge,
              ),
            ),
            trailing: Obx(() {
              final isSelected = controller.selectedUsers.contains(index);
              return Transform.scale(
                scale: 1.2, // Slightly bigger checkbox for touch friendliness
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    controller.toggleUserSelection(index);
                  },
                  activeColor: AppColors.primaryColor,
                  checkColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            }),
          );
        },
      );
    });
  }

  Widget Inviteuser(bool isDarkMode) {
    return Obx(
      () => global_button(
        loaderWhite: true,
        isLoading: controller.isLoading.value,
        onTap: () async {
          if (controller.validateAllFields()) {
            controller.isLoading.value = true;

            // Simulate API call delay
            await Future.delayed(const Duration(seconds: 2));

            controller.isLoading.value = false;

            showCustomSnackBar(
              "Users invited successfully!",
              SnackbarState.success,
            );

            Get.back(); // Navigate back after successful invite
          } else {
            showCustomSnackBar(
              AppTexts.Please_fix_the_errors_in_the_form,
              SnackbarState.error,
            );
          }
        },
        title: AppTexts.createEvent,
        backgroundColor:
            isDarkMode
                ? AppTheme.darkTheme.scaffoldBackgroundColor
                : AppTheme.lightTheme.primaryColor,
      ),
    );
  }
}
