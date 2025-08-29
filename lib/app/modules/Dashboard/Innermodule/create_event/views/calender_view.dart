// ignore_for_file: deprecated_member_use

import 'package:bellybutton/app/core/utils/appColors/custom_color.g.dart';
import 'package:bellybutton/app/modules/Dashboard/Innermodule/create_event/controllers/create_event_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/themes/Font_style.dart';
import '../../../../../global_widgets/Button/global_button.dart';
import '../../../../../global_widgets/custom_app_bar/custom_app_bar.dart';

class CalenderView extends GetView<CreateEventController> {
  final bool returnDateTime;

  const CalenderView({super.key, this.returnDateTime = false});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size; // ✅ MediaQuery added
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppTexts.calendar),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(width * 0.04), // ✅ Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              AppTexts.selectDate,
              style: customBoldText.copyWith(
                fontSize: height * 0.022, // ✅ Responsive text size
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: height * 0.015),

            /// Calendar
            Obx(() => _buildCalendar(context, height, width)),

            SizedBox(height: height * 0.025),

            /// Events List or Time Picker
            if (!returnDateTime) _buildEventList(height),
            if (returnDateTime) ...[
              SizedBox(height: height * 0.02),
              Text(
                AppTexts.chooseTime,
                textAlign: TextAlign.center,
                style: customBoldText.copyWith(
                  fontSize: height * 0.022,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: height * 0.025),
              _buildTimePickers(height, width),
              SizedBox(height: height * 0.04),
              _buildConfirmButton(),
            ],
          ],
        ),
      ),
    );
  }

  /// Calendar Widget
  Widget _buildCalendar(BuildContext context, double height, double width) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(color: gray_textfield.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(width * 0.03),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: controller.focusedDay.value,
        selectedDayPredicate:
            (day) => isSameDay(controller.selectedDay.value, day),
        onDaySelected: (selectedDay, focusedDay) {
          controller.selectDay(selectedDay, focusedDay);
          HapticFeedback.mediumImpact();
        },
        calendarFormat: controller.calendarFormat.value,
        headerStyle: HeaderStyle(
          headerPadding: EdgeInsets.symmetric(
            vertical: height * 0.012,
            horizontal: width * 0.04,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(width * 0.035),
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
            fontSize: height * 0.022,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            size: width * 0.07,
            color: AppColors.textColor.withOpacity(0.65),
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            size: width * 0.07,
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
        daysOfWeekHeight: height * 0.035,
        rowHeight: height * 0.055,
      ),
    );
  }

  /// Event List
  Widget _buildEventList(double height) {
    return Obx(() {
      final events = controller.events[controller.selectedDay.value] ?? [];
      if (events.isEmpty) {
        return Center(
          child: Text(
            "No events scheduled",
            style: customBoldText.copyWith(
              fontSize: height * 0.018,
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: events.length,
        itemBuilder:
            (_, i) => Card(
              margin: EdgeInsets.symmetric(vertical: height * 0.008),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(height * 0.015),
              ),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryColor.withOpacity(0.8),
                  child: const Icon(Icons.event, color: Colors.white),
                ),
                title: Text(
                  events[i].toString(),
                  style: customBoldText.copyWith(
                    fontSize: height * 0.018,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: height * 0.018),
              ),
            ),
      );
    });
  }

  /// Time Pickers
  Widget _buildTimePickers(double height, double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(color: gray_textfield.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _timePickerColumn(
            AppTexts.from,
            controller.fromTime,
            (val) => controller.fromTime.value = val,
            height,
          ),
          SizedBox(width: width * 0.03),
          Container(width: 1, height: height * 0.22, color: gray_textfield),
          SizedBox(width: width * 0.03),
          _timePickerColumn(
            AppTexts.to,
            controller.toTime,
            (val) => controller.toTime.value = val,
            height,
          ),
        ],
      ),
    );
  }

  Widget _timePickerColumn(
    String title,
    Rx<DateTime> time,
    ValueChanged<DateTime> onChange,
    double height,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: customBoldText.copyWith(
              fontSize: height * 0.018,
              color: AppColors.textColor.withOpacity(0.8),
            ),
          ),
          SizedBox(height: height * 0.01),
          SizedBox(
            height: height * 0.22,
            child: Obx(() {
              return DefaultTextStyle(
                style: TextStyle(
                  fontSize: height * 0.018,
                  color: AppColors.textColor,
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: time.value,
                  onDateTimeChanged: (val) {
                    onChange(val);
                    HapticFeedback.selectionClick();
                  },
                  itemExtent: height * 0.032,
                  use24hFormat: false,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Confirm Button
  Widget _buildConfirmButton() {
    return Obx(
      () => global_button(
        loaderWhite: true,
        isLoading: controller.isConfirmLoading.value,
        onTap: () {
          if (!controller.isConfirmLoading.value) {
            controller.isConfirmLoading.value = true;

            final fromDateTime = DateTime(
              controller.selectedDay.value.year,
              controller.selectedDay.value.month,
              controller.selectedDay.value.day,
              controller.fromTime.value.hour,
              controller.fromTime.value.minute,
            );
            final toDateTime = DateTime(
              controller.selectedDay.value.year,
              controller.selectedDay.value.month,
              controller.selectedDay.value.day,
              controller.toTime.value.hour,
              controller.toTime.value.minute,
            );

            Future.delayed(const Duration(milliseconds: 300), () {
              controller.isConfirmLoading.value = false;
              Get.back(result: {'from': fromDateTime, 'to': toDateTime});
            });
          }
        },
        title: AppTexts.setDateTime,
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}
