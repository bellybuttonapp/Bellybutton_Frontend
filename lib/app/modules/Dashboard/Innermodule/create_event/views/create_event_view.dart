// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use, annotate_overrides, use_key_in_widget_constructors, must_be_immutable

import 'package:bellybutton/app/core/constants/app_images.dart';
import 'package:bellybutton/app/core/constants/app_texts.dart';
import 'package:bellybutton/app/global_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/helpers/date_converter.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/showcase_service.dart';
import '../../../../../core/utils/themes/font_style.dart';
import '../../../../../core/utils/themes/custom_color.g.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../global_widgets/GlobalTextField/GlobalTextField.dart';
import '../controllers/create_event_controller.dart';

class CreateEventView extends GetView<CreateEventController> {
  final CreateEventController controller = Get.put(CreateEventController());
  final _formKey = GlobalKey<FormState>();

  // Showcase GlobalKeys - Create unique keys per instance
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _descriptionKey = GlobalKey();
  final GlobalKey _dateKey = GlobalKey();
  final GlobalKey _timeKey = GlobalKey();

  // Flag to prevent showcase from starting multiple times
  bool _showcaseStarted = false;

  @override
  Widget build(BuildContext context) {
    // Always wrap with ShowCaseWidget (required for Showcase widgets inside)
    // But we only START the showcase in new event mode, not edit mode
    return ShowCaseWidget(
      onFinish: () {
        ShowcaseService.completeCreateEventTour();
        _showcaseStarted = false;
      },
      builder: (context) => _buildCreateEventScreen(context),
    );
  }

  Widget _buildCreateEventScreen(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Start showcase tour if not shown before (only once per session, only for NEW events)
    // IMPORTANT: Never show showcase in edit/update mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isEditMode.value &&
          ShowcaseService.shouldShowCreateEventTour &&
          !_showcaseStarted) {
        _showcaseStarted = true;
        ShowcaseService.startShowcase(
          context,
          [_titleKey, _descriptionKey, _dateKey, _timeKey],
        );
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.discardChanges();
      },
      child: Obx(
        () => Scaffold(
          backgroundColor:
              isDarkMode
                  ? AppTheme.darkTheme.scaffoldBackgroundColor
                  : AppTheme.lightTheme.scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: controller.isEditMode.value ? AppTexts.UPDATE_SHOOT : AppTexts.CREATE_SHOOT,
            onBackPressed: controller.discardChanges,
          ),
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
                _buildDatePicker(size, isDarkMode),
                const SizedBox(height: 12),
                _buildTimeRangePicker(context, isDarkMode),
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
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Showcase(
      key: _titleKey,
      title: AppTexts.SHOWCASE_CREATE_TITLE_TITLE,
      description: AppTexts.SHOWCASE_CREATE_TITLE_DESC,
      tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
      textColor: ShowcaseService.textColor,
      titleTextStyle: ShowcaseService.titleStyle,
      descTextStyle: ShowcaseService.descriptionStyle,
      child: Obx(
        () => GlobalTextField(
          controller: controller.titleController,
          hintText: AppTexts.SHOOT_TITLE,
          labelText: controller.titleController.text.isEmpty
              ? controller.currentTitleSuggestion
              : null,
          obscureText: false,
          keyboardType: TextInputType.text,
          maxLength: 50,
          errorText: controller.titleError.value,
          onChanged: controller.validateTitle,
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Showcase(
      key: _descriptionKey,
      title: AppTexts.SHOWCASE_CREATE_DESC_TITLE,
      description: AppTexts.SHOWCASE_CREATE_DESC_DESC,
      tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
      textColor: ShowcaseService.textColor,
      titleTextStyle: ShowcaseService.titleStyle,
      descTextStyle: ShowcaseService.descriptionStyle,
      child: Obx(
        () => GlobalTextField(
          controller: controller.descriptionController,
          hintText: AppTexts.DESCRIPTION,
          labelText: controller.descriptionController.text.isEmpty
              ? controller.currentDescriptionSuggestion
              : null,
          obscureText: false,
          keyboardType: TextInputType.multiline,
          maxLines: 2,
          maxLength: 200,
          errorText: controller.descriptionError.value,
          onChanged: controller.validateDescription,
        ),
      ),
    );
  }

  Widget _buildDatePicker(Size size, bool isDarkMode) {
    return Showcase(
      key: _dateKey,
      title: AppTexts.SHOWCASE_CREATE_DATE_TITLE,
      description: AppTexts.SHOWCASE_CREATE_DATE_DESC,
      tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
      textColor: ShowcaseService.textColor,
      titleTextStyle: ShowcaseService.titleStyle,
      descTextStyle: ShowcaseService.descriptionStyle,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlobalTextField(
              controller: controller.dateController,
              hintText: AppTexts.SET_DATE,
              obscureText: false,
              readOnly: true,
              suffixIcon: InkWell(
                onTap: () {
                  // Close any open keyboard
                  FocusScope.of(Get.context!).unfocus();

                  // Toggle calendar visibility
                  controller.showCalendar.value = !controller.showCalendar.value;
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    AppImages.CALENDAR,
                    height: 20,
                    width: 20,
                    color: isDarkMode ? Colors.white : AppColors.primaryColor,
                  ),
                ),
              ),
              errorText:
                  controller.dateError.value.isEmpty
                      ? null
                      : controller.dateError.value,
              onTap: () {
                // Close any open keyboard
                FocusScope.of(Get.context!).unfocus();

                // Toggle calendar visibility when tapping the text field
                controller.showCalendar.value = !controller.showCalendar.value;
              },
            ),
            const SizedBox(height: 8),
            if (controller.showCalendar.value) _buildInlineCalendar(size, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineCalendar(Size size, bool isDarkMode) {
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
          // Use locale-aware date formatting
          final formattedDate = DateConverter.formatDateLocale(selectedDay);
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
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(size.width * 0.035),
            border: Border.all(
              color: isDarkMode
                  ? Colors.grey[700]!.withOpacity(0.6)
                  : gray_textfield.withOpacity(0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.04),
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
            color: isDarkMode ? Colors.white : AppColors.textColor,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            size: size.width * 0.07,
            color: isDarkMode
                ? Colors.white.withOpacity(0.65)
                : AppColors.textColor.withOpacity(0.65),
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            size: size.width * 0.07,
            color: isDarkMode
                ? Colors.white.withOpacity(0.65)
                : AppColors.textColor.withOpacity(0.65),
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
          weekendTextStyle: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textColor,
            fontWeight: FontWeight.w500,
          ),
          defaultTextStyle: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textColor,
            fontWeight: FontWeight.w500,
          ),
          outsideDaysVisible: false,
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: isDarkMode ? Colors.white70 : AppColors.textColor,
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            color: isDarkMode ? Colors.white70 : AppColors.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        daysOfWeekHeight: size.height * 0.035,
        rowHeight: size.height * 0.055,
      ),
    );
  }

  Widget _buildTimeRangePicker(BuildContext context, bool isDarkMode) {
    return Showcase(
      key: _timeKey,
      title: AppTexts.SHOWCASE_CREATE_TIME_TITLE,
      description: AppTexts.SHOWCASE_CREATE_TIME_DESC,
      tooltipBackgroundColor: ShowcaseService.tooltipBackgroundColor,
      textColor: ShowcaseService.textColor,
      titleTextStyle: ShowcaseService.titleStyle,
      descTextStyle: ShowcaseService.descriptionStyle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.SET_TIME_RANGE,
            style: customBoldText.copyWith(
              fontSize: 16,
              color: isDarkMode ? Colors.white : AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
          children: [
            Expanded(
              child: Obx(
                () => GlobalTextField(
                  controller: controller.startTimeController,
                  hintText: AppTexts.START_TIME,
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
                  suffixIcon: Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          AppImages.CLOCK_ICON,
                          height: 20,
                          width: 20,
                          color: isDark ? Colors.white : AppColors.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => GlobalTextField(
                  controller: controller.endTimeController,
                  hintText: AppTexts.END_TIME,
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
                        isEndTime: true,
                      ),
                  suffixIcon: Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          AppImages.CLOCK_ICON,
                          height: 20,
                          width: 20,
                          color: isDark ? Colors.white : AppColors.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }

  Widget _buildcreateeventButton(bool isDarkMode) {
    return Obx(
      () => global_button(
        loaderWhite: true,
        isLoading: controller.isLoading.value,
        onTap: () {
          if (controller.validateAllFields()) {
            controller
                .showEventConfirmationDialog(); // 🟢 Show popup before create/update
          } else {
            showCustomSnackBar(AppTexts.FIX_FORM_ERRORS, SnackbarState.error);
          }
        },
        title:
            controller.isEditMode.value
                ? AppTexts.UPDATE_SHOOT
                : AppTexts.CREATE_SHOOT,
        backgroundColor:
            isDarkMode
                ? AppTheme.darkTheme.scaffoldBackgroundColor
                : AppTheme.lightTheme.primaryColor,
      ),
    );
  }
}