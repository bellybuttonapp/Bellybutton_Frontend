// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use, annotate_overrides, use_key_in_widget_constructors

import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:bellybutton/app/global_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:bellybutton/app/modules/Dashboard/Innermodule/inviteuser/views/inviteuser_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/themes/Font_style.dart';
import '../../../../../core/utils/appColors/custom_color.g.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../Auth/signup/Widgets/Signup_textfield.dart';
import '../controllers/create_event_controller.dart';

class CreateEventView extends GetView<CreateEventController> {
  final CreateEventController controller = Get.put(CreateEventController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

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
                _buildTitleField(),
                const SizedBox(height: 12),
                _buildDescriptionField(),
                const SizedBox(height: 12),
                _buildDatePicker(size),
                const SizedBox(height: 12),
                _buildTimeRangePicker(context),
                const SizedBox(height: 12),
                Divider(
                  color:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  height: 32,
                ),
                const SizedBox(height: 12),
                _buildcreateeventButton(isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Obx(
      () => Signup_textfield(
        controller: controller.titleController,
        hintText: "Event Title",
        obscureText: false,
        keyboardType: TextInputType.text,
        errorText: controller.titleError.value,
        onChanged: controller.validateTitle,
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Obx(
      () => Signup_textfield(
        controller: controller.descriptionController,
        hintText: "Description",
        obscureText: false,
        keyboardType: TextInputType.multiline,
        maxLines: 2,
        errorText: controller.descriptionError.value,
        onChanged: controller.validateDescription,
      ),
    );
  }

  Widget _buildDatePicker(Size size) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Signup_textfield(
            controller: controller.dateController,
            hintText: "Set Date",
            obscureText: false,
            readOnly: true,
            suffixIcon: InkWell(
              onTap:
                  () =>
                      controller.showCalendar.value =
                          !controller.showCalendar.value,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  app_images.Calendar,
                  height: 20,
                  width: 20,
                  color: AppColors.textColor,
                ),
              ),
            ),
            errorText:
                controller.dateError.value.isEmpty
                    ? null
                    : controller.dateError.value,
            onTap: () {}, // Prevent keyboard
          ),
          const SizedBox(height: 8),
          if (controller.showCalendar.value) _buildInlineCalendar(size),
        ],
      ),
    );
  }

  Widget _buildInlineCalendar(Size size) {
    return Obx(
      () => TableCalendar(
        firstDay: DateTime.now(), // Start from today
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: controller.focusedDay.value,
        selectedDayPredicate:
            (day) => isSameDay(controller.selectedDay.value, day),
        onDaySelected: (selectedDay, focusedDay) {
          controller.selectDay(selectedDay, focusedDay);
          HapticFeedback.mediumImpact();
          final formattedDate = DateFormat('dd MMM yyyy').format(selectedDay);
          controller.dateController.text = formattedDate;
          controller.validateDate(formattedDate);
          controller.showCalendar.value = false;
        },
        calendarFormat: controller.calendarFormat.value,
        headerStyle: HeaderStyle(
          headerPadding: EdgeInsets.symmetric(
            vertical: size.height * 0.012,
            horizontal: size.width * 0.04,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size.width * 0.035),
            border: Border.all(color: gray_textfield.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: customBoldText.copyWith(
            fontSize: size.height * 0.022,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            size: size.width * 0.07,
            color: AppColors.textColor.withOpacity(0.65),
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            size: size.width * 0.07,
            color: AppColors.textColor.withOpacity(0.65),
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.tertiaryColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.tertiaryColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primaryColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          todayTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          weekendTextStyle: const TextStyle(
            color: AppColors.primaryColor1,
            fontWeight: FontWeight.w500,
          ),
          defaultTextStyle: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.w500,
          ),
          outsideDaysVisible: false,
        ),
        daysOfWeekHeight: size.height * 0.035,
        rowHeight: size.height * 0.055,
      ),
    );
  }

  Widget _buildTimeRangePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(
                () => Signup_textfield(
                  controller: controller.startTimeController,
                  hintText: "Start Time",
                  readOnly: true,
                  obscureText: false,
                  errorText:
                      controller.startTimeError.value.isEmpty
                          ? null
                          : controller.startTimeError.value,
                  onTap:
                      () => controller.selectTime(
                        context,
                        controller.startTimeController,
                        controller.startTimeError,
                      ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      app_images.clock_icon,
                      height: 20,
                      width: 20,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => Signup_textfield(
                  controller: controller.endTimeController,
                  hintText: "End Time",
                  readOnly: true,
                  obscureText: false,
                  errorText:
                      controller.endTimeError.value.isEmpty
                          ? null
                          : controller.endTimeError.value,
                  onTap:
                      () => controller.selectTime(
                        context,
                        controller.endTimeController,
                        controller.endTimeError,
                        isEndTime: true, // Pass the flag here
                      ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      app_images.clock_icon,
                      height: 20,
                      width: 20,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildcreateeventButton(bool isDarkMode) {
    return Obx(
      () => global_button(
        loaderWhite: true,
        isLoading: controller.isLoading.value,
        onTap: () {
          if (controller.validateAllFields()) {
            Get.off(() => InviteuserView()); // Navigate without back
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
