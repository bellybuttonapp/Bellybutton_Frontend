// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use, annotate_overrides

import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:bellybutton/app/global_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:bellybutton/app/modules/Dashboard/Innermodule/create_event/views/calender_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../Auth/signup/Widgets/Signup_textfield.dart';
import '../controllers/create_event_controller.dart';

class CreateEventView extends GetView<CreateEventController> {
  final CreateEventController controller = Get.put(CreateEventController());
  CreateEventView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppTexts.createEvent),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Event Title Field
                /// Event Title Field
                Obx(
                  () => Signup_textfield(
                    controller: controller.titleController,
                    hintText: "Event Title",
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    errorText: controller.titleError.value,
                    onChanged: controller.validateTitle,
                  ),
                ),
                const SizedBox(height: 12),

                /// Description Field
                /// Description Field
                Obx(
                  () => Signup_textfield(
                    controller: controller.descriptionController,
                    hintText: "Description",
                    obscureText: false,
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    errorText: controller.descriptionError.value,
                    onChanged: controller.validateDescription,
                  ),
                ),
                const SizedBox(height: 12),

                /// Date & Time Picker

                /// Date & Time Picker using Signup_textfield
                Obx(
                  () => Signup_textfield(
                    controller: controller.dateController,
                    hintText: "Set Date & Time",
                    obscureText: false,
                    readOnly: true,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        app_images.Calendar,
                        height: 20,
                        width: 20,
                        color: AppColors.tertiaryColor,
                      ),
                    ),
                    errorText:
                        controller.dateError.value.isEmpty
                            ? null
                            : controller.dateError.value,
                    onTap: () async {
                      final result = await Get.to<Map<String, DateTime>>(
                        () => const CalenderView(returnDateTime: true),
                      );

                      if (result != null &&
                          result.containsKey('from') &&
                          result.containsKey('to')) {
                        final from = result['from']!;
                        final to = result['to']!;
                        final formatted =
                            '${DateFormat('dd MMM yyyy, hh:mm a').format(from)} - ${DateFormat('hh:mm a').format(to)}';
                        controller.dateController.text = formatted;
                        controller.validateDate(formatted);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  color:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  height: 32,
                ),
                const SizedBox(height: 12),

                /// Search Field
                Obx(
                  () => Signup_textfield(
                    controller: controller.searchController,
                    hintText: "Search",
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    errorText: controller.searchError.value,
                    onChanged: controller.validateSearch,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        app_images.search,
                        height: 20,
                        width: 20,
                        color: AppColors.tertiaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                /// Suggestions List
                Obx(() {
                  final query = controller.searchQuery.value.toLowerCase();
                  final suggestions =
                      controller.sampleUsers
                          .where((user) => user.toLowerCase().contains(query))
                          .toList();

                  if (suggestions.isEmpty || query.isEmpty)
                    return const SizedBox();

                  return Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final user = suggestions[index];
                        final isSelected = controller.selectedUsers.contains(
                          index,
                        );
                        return ListTile(
                          title: Text(user),
                          trailing:
                              isSelected
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                          onTap: () {
                            if (isSelected) {
                              controller.selectedUsers.remove(index);
                            } else {
                              controller.selectedUsers.add(index);
                            }
                          },
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: 12),

                /// Invite Button
                Obx(
                  () => global_button(
                    loaderWhite: true,
                    isLoading: controller.isLoading.value,
                    onTap: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        controller.saveChanges();
                      }
                    },
                    title: AppTexts.invite,
                    backgroundColor:
                        isDarkMode
                            ? AppTheme.darkTheme.scaffoldBackgroundColor
                            : AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
