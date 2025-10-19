/// =====================
/// IMPORTS
/// =====================

// ignore_for_file: dangling_library_doc_comments, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../api/PublicApiService.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../utils/coadingRequirement/date_converter.dart';
import '../../inviteuser/views/inviteuser_view.dart';

/// =====================
/// CREATE EVENT CONTROLLER
/// =====================

class CreateEventController extends GetxController {
  // ---------------- API SERVICE ----------------
  final _apiService = PublicApiService(); // ✅ define _apiService

  /// ---------------- CONTROLLERS ----------------
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  var startTimeController = TextEditingController();
  var endTimeController = TextEditingController();

  /// ---------------- ERROR OBSERVABLES ----------------
  var startTimeError = ''.obs;
  var endTimeError = ''.obs;
  var titleError = ''.obs;
  var descriptionError = ''.obs;
  var dateError = ''.obs;
  RxBool isProcessing = false.obs;

  /// ---------------- STATE OBSERVABLES ----------------
  var showCalendar = false.obs;
  var isLoading = false.obs;
  var selectedUsers = <int>[].obs;
  var focusedDay = DateTime.now().obs;
  var selectedDay = DateTime.now().obs;
  var calendarFormat = CalendarFormat.month.obs;

  bool isDialogShown = false;

  @override
  void onInit() {
    super.onInit();

    // Auto-trigger confirmation dialog when date + times are filled
    dateController.addListener(_checkAndShowDialog);
    startTimeController.addListener(_checkAndShowDialog);
    endTimeController.addListener(_checkAndShowDialog);
  }

  /// ---------------- VALIDATE ALL FIELDS ----------------
  bool validateAllFields() {
    validateTitle(titleController.text);
    validateDescription(descriptionController.text);
    validateDate(dateController.text);
    validateStartTime(startTimeController.text);
    validateEndTime(endTimeController.text);

    // Return true only if all errors are empty
    return titleError.value.isEmpty &&
        descriptionError.value.isEmpty &&
        dateError.value.isEmpty &&
        startTimeError.value.isEmpty &&
        endTimeError.value.isEmpty;
  }

  void _checkAndShowDialog() {
    if (dateController.text.isNotEmpty &&
        startTimeController.text.isNotEmpty &&
        endTimeController.text.isNotEmpty &&
        !isDialogShown) {
      isDialogShown = true;
      showEventConfirmationDialog();
    }

    if (dateController.text.isEmpty ||
        startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty) {
      isDialogShown = false;
    }
  }

  Future<void> selectTime(
    BuildContext context,
    TextEditingController timeController,
    RxString errorObservable, {
    bool isEndTime = false,
  }) async {
    if (dateController.text.isEmpty) {
      showCustomSnackBar(
        "Please select the event date first",
        SnackbarState.error,
      );
      return;
    }

    final now = TimeOfDay.now();
    DateTime selectedDate;

    try {
      selectedDate = DateFormat('dd MMM yyyy').parse(dateController.text);
    } catch (e) {
      showCustomSnackBar("Invalid date format", SnackbarState.error);
      return;
    }

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        picked.hour,
        picked.minute,
        0,
      );

      // Prevent past start times
      if (!isEndTime && selectedDateTime.isBefore(DateTime.now())) {
        await Get.dialog(
          CustomPopup(
            title: "Invalid Time..! ",
            message: "You cannot select a past time.",
            confirmText: "OK",
            cancelText: null,
            isProcessing: false.obs,
            onConfirm: () => Get.back(),
          ),
        );
        return;
      }

      // Directly format in 24-hour for API
      final formatted24 = DateFormat('HH:mm:ss').format(selectedDateTime);

      // Set controller and clear error
      timeController.text = formatted24;
      errorObservable.value = '';

      print("Selected ${isEndTime ? "End" : "Start"} Time (24h): $formatted24");
    }
  }

  void validateTitle(String value) {
    titleError.value =
        value.trim().length < 3 ? "Title must be at least 3 characters" : '';
  }

  void validateDescription(String value) {
    descriptionError.value =
        value.trim().length < 5
            ? "Description must be at least 5 characters"
            : '';
  }

  void validateDate(String value) {
    dateError.value = value.trim().isEmpty ? "Please select date" : '';
  }

  void validateStartTime(String value) {
    startTimeError.value =
        value.trim().isEmpty ? "Please select start time" : '';
  }

  void validateEndTime(String value) {
    if (value.trim().isEmpty) {
      endTimeError.value = "Please select end time";
      return;
    }

    // Check difference with start time
    if (startTimeController.text.isNotEmpty) {
      try {
        final startTime = _parseTime(
          startTimeController.text,
          dateController.text,
        );
        final endTime = _parseTime(value, dateController.text);

        final difference = endTime.difference(startTime).inMinutes;

        if (difference <= 0) {
          endTimeError.value = "End time must be after start time";
        } else if (difference > 120) {
          // 2 hours = 120 minutes
          endTimeError.value = "Event duration cannot exceed 2 hours";
        } else {
          endTimeError.value = '';
        }
      } catch (e) {
        endTimeError.value = "Invalid time format";
      }
    }
  }

  // Helper to convert time string to DateTime
  DateTime _parseTime(String time, String date) {
    final datePart = DateFormat('dd MMM yyyy').parse(date);
    final timeParts = time.split(RegExp(r'[:\s]')); // Handles 12-hour format
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPM = time.toLowerCase().contains('pm');

    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    return DateTime(datePart.year, datePart.month, datePart.day, hour, minute);
  }

  void selectDay(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    dateController.text = DateFormat('dd MMM yyyy').format(selected);
  }

  void showEventConfirmationDialog() {
    validateTitle(titleController.text);
    validateDescription(descriptionController.text);
    validateDate(dateController.text);
    validateStartTime(startTimeController.text);
    validateEndTime(endTimeController.text);

    if (titleError.value.isEmpty &&
        descriptionError.value.isEmpty &&
        dateError.value.isEmpty &&
        startTimeError.value.isEmpty &&
        endTimeError.value.isEmpty) {
      _showConfirmationDialog(
        title: "Confirm Event",
        confirmText: "Ok",
        messageWidget: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 16),
            children: [
              const TextSpan(
                text: "Are you sure you want to create the event ",
              ),
              TextSpan(
                text: titleController.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: " on "),
              TextSpan(
                text: dateController.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: " from "),
              TextSpan(
                text: startTimeController.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: " to "),
              TextSpan(
                text: endTimeController.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: "?"),
            ],
          ),
        ),
        isProcessing: isProcessing,
        onConfirm: () async {
          isLoading.value = true;
          await Future.delayed(const Duration(seconds: 1));
          isLoading.value = false;
          showCustomSnackBar(
            AppTexts.Event_saved_successfully,
            SnackbarState.success,
          );
          Get.back();
        },
      );
    } else {
      showCustomSnackBar(
        AppTexts.Please_fix_the_errors_in_the_form,
        SnackbarState.error,
      );
    }
  }

  void saveChanges() {
    validateTitle(titleController.text);
    validateDescription(descriptionController.text);
    validateDate(dateController.text);
    validateStartTime(startTimeController.text);
    validateEndTime(endTimeController.text);

    if (titleError.value.isEmpty &&
        descriptionError.value.isEmpty &&
        dateError.value.isEmpty &&
        startTimeError.value.isEmpty &&
        endTimeError.value.isEmpty) {
      isLoading.value = true;
      Future.delayed(const Duration(seconds: 1), () {
        isLoading.value = false;
        showCustomSnackBar(
          AppTexts.Event_saved_successfully,
          SnackbarState.success,
        );
      });
    } else {
      showCustomSnackBar(
        AppTexts.Please_fix_the_errors_in_the_form,
        SnackbarState.error,
      );
    }
  }

  // ==========================
  // 1️⃣ Create Event
  // ==========================

  Future<void> createEvent() async {
    isLoading.value = true;

    try {
      // Convert times
      final startTime = DateConverter.convertTo24Hour(startTimeController.text);
      final endTime = DateConverter.convertTo24Hour(endTimeController.text);

      // Print converted times
      print("Selected Start Time (24h): $startTime");
      print("Selected End Time (24h): $endTime");

      final response = await _apiService.createEvent(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        eventDate: DateFormat(
          'yyyy-MM-dd',
        ).format(DateFormat('dd MMM yyyy').parse(dateController.text)),
        startTime: startTime, // e.g. "14:10:00"
        endTime: endTime, // e.g. "16:10:00"
      );

      print("API Response: $response");

      if (response['id'] != null) {
        showCustomSnackBar(
          AppTexts.Event_saved_successfully,
          SnackbarState.success,
        );
        Future.delayed(Duration.zero, () {
          Get.to(
            () => InviteuserView(),
            transition: Transition.fade,
            duration: const Duration(milliseconds: 300),
            arguments: {
              "eventId": response['id'],
              "title": titleController.text.trim(),
              "date": dateController.text,
              "startTime": startTime,
              "endTime": endTime,
            },
          );
        });
      } else {
        showCustomSnackBar(
          response['message'] ?? 'Failed to create event',
          SnackbarState.error,
        );
      }
    } catch (e) {
      print("Error creating event: $e");
      showCustomSnackBar(
        'Something went wrong while creating the event',
        SnackbarState.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.onClose();
  }
}

void _showConfirmationDialog({
  required String title,
  String? message,
  RichText? messageWidget,
  required String confirmText,
  required Future<void> Function() onConfirm,
  required RxBool isProcessing,
}) {
  assert(
    message != null || messageWidget != null,
    'Either message or messageWidget must be provided',
  );

  Get.dialog(
    CustomPopup(
      title: title,
      message: message,
      messageWidget: messageWidget,
      confirmText: confirmText,
      cancelText: AppTexts.cancel,
      isProcessing: isProcessing,
      onConfirm: onConfirm,
    ),
  );
}
