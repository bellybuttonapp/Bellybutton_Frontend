// ignore_for_file: file_names, avoid_print, use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../database/models/EventModel.dart';
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../utils/coadingRequirement/date_converter.dart';
import '../../inviteuser/views/inviteuser_view.dart';

class CreateEventController extends GetxController {
  final _apiService = PublicApiService();

  /// ---------------- CONTROLLERS ----------------
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;

  /// ---------------- STATES ----------------
  RxBool isLoading = false.obs;
  RxBool isProcessing = false.obs;
  RxBool isEditMode = false.obs;

  EventModel? editingEvent;

  /// ---------------- VALIDATION ----------------
  var titleError = ''.obs;
  var descriptionError = ''.obs;
  var dateError = ''.obs;
  var startTimeError = ''.obs;
  var endTimeError = ''.obs;

  /// ---------------- CALENDAR ----------------
  var showCalendar = false.obs;
  var selectedDay = DateTime.now().obs;
  var focusedDay = DateTime.now().obs;
  var calendarFormat = CalendarFormat.month.obs;

  bool _isInitializing = false;

  @override
  void onInit() {
    super.onInit();
    _initControllers();
  }

  void _initControllers() {
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    dateController = TextEditingController();
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();
  }

  @override
  void onReady() {
    super.onReady();
    _loadEventData();
  }

  /// ✅ Load data safely when editing
  void _loadEventData() {
    _isInitializing = true;
    final args = Get.arguments;
    print("🟢 Received Arguments: $args");

    if (args is EventModel) {
      isEditMode.value = true;
      editingEvent = args;

      titleController.text = args.title ?? '';
      descriptionController.text = args.description ?? '';
      dateController.text = DateFormat('dd MMM yyyy').format(args.eventDate);
      startTimeController.text = args.startTime ?? '';
      endTimeController.text = args.endTime ?? '';
    } else {
      clearForm();
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      _isInitializing = false;
    });
  }

  // ---------------- FIELD VALIDATIONS ----------------
  bool validateAllFields() {
    validateTitle(titleController.text);
    validateDescription(descriptionController.text);
    validateDate(dateController.text);
    validateStartTime(startTimeController.text);
    validateEndTime(endTimeController.text);

    return titleError.value.isEmpty &&
        descriptionError.value.isEmpty &&
        dateError.value.isEmpty &&
        startTimeError.value.isEmpty &&
        endTimeError.value.isEmpty;
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

    if (startTimeController.text.isNotEmpty && dateController.text.isNotEmpty) {
      try {
        final start = _parseTime(startTimeController.text, dateController.text);
        final end = _parseTime(value, dateController.text);

        // Prevent past event time
        final now = DateTime.now();
        if (start.isBefore(now)) {
          endTimeError.value = "Event time cannot be in the past";
          return;
        }

        final diff = end.difference(start).inMinutes;
        if (diff <= 0) {
          endTimeError.value = "End time must be after start time";
        } else if (diff > 120) {
          endTimeError.value = "Event duration cannot exceed 2 hours";
        } else {
          endTimeError.value = '';
        }
      } catch (_) {
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

  // ---------------- DATE & TIME ----------------
  void selectDay(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    dateController.text = DateFormat('dd MMM yyyy').format(selected);
  }

  // ---------------- CREATE EVENT ----------------
  Future<void> createEvent() async {
    isLoading.value = true;
    try {
      final start = DateConverter.convertTo24Hour(startTimeController.text);
      final end = DateConverter.convertTo24Hour(endTimeController.text);

      // Print converted times
      print("Selected Start Time (24h): $start");
      print("Selected End Time (24h): $end");

      final response = await _apiService.createEvent(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        eventDate: DateFormat(
          'yyyy-MM-dd',
        ).format(DateFormat('dd MMM yyyy').parse(dateController.text)),
        startTime: start,
        endTime: end,
      );

      // ✅ Fixed condition: check if ID exists instead of response["id"] == true
      if (response != null && response["id"] != null) {
        showCustomSnackBar(
          AppTexts.EVENT_SAVED_SUCCESSFULLY,
          SnackbarState.success,
        );

        final eventId = response['id'];

        final newEvent = EventModel(
          id: eventId,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          eventDate: DateFormat(
            'dd MMM yyyy',
          ).parse(dateController.text.trim()),
          startTime: start,
          endTime: end,
          invitedPeople: [],
        );

        clearForm();
        Get.off(() => InviteuserView(), arguments: newEvent);
      } else {
        showCustomSnackBar(
          response?["message"] ?? "Failed to create event",
          SnackbarState.error,
        );
      }
    } catch (e) {
      showCustomSnackBar("Error: $e", SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- UPDATE EVENT ----------------
  Future<void> updateEvent() async {
    if (editingEvent == null) return;
    isLoading.value = true;

    try {
      final start = DateConverter.convertTo24Hour(startTimeController.text);
      final end = DateConverter.convertTo24Hour(endTimeController.text);

      final response = await _apiService.updateEvent(
        id: editingEvent!.id!,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        eventDate: DateFormat(
          'yyyy-MM-dd',
        ).format(DateFormat('dd MMM yyyy').parse(dateController.text)),
        startTime: start,
        endTime: end,
      );

      print("🔍 API Response: $response");

      final bool isSuccess =
          response["success"] == true || response["id"] != null;

      if (isSuccess) {
        showCustomSnackBar("Event updated successfully", SnackbarState.success);
        await Future.delayed(const Duration(milliseconds: 700));

        final updatedEvent = EventModel(
          id: response["id"] ?? editingEvent!.id,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          eventDate: DateFormat(
            'dd MMM yyyy',
          ).parse(dateController.text.trim()),
          startTime: start,
          endTime: end,
          invitedPeople: [],
        );

        clearForm();
        Get.off(() => InviteuserView(), arguments: updatedEvent);
      } else {
        showCustomSnackBar(
          response["message"] ?? "Failed to update event",
          SnackbarState.error,
        );
      }
    } catch (e) {
      showCustomSnackBar("Error updating event: $e", SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- CLEAR FORM ----------------
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    dateController.clear();
    startTimeController.clear();
    endTimeController.clear();
    editingEvent = null;
    isEditMode.value = false;
  }

  // ---------------- CONFIRMATION POPUP ----------------
  void showEventConfirmationDialog() {
    _showConfirmationDialog(
      title:
          isEditMode.value
              ? AppTexts.CONFIRM_EVENT_UPDATE
              : AppTexts.CONFIRM_EVENT_CREATION,
      confirmText: AppTexts.OK,
      messageWidget: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text:
                  isEditMode.value
                      ? AppTexts.CONFIRM_EVENT_UPDATE_MESSAGE
                      : AppTexts.CONFIRM_EVENT_CREATION_MESSAGE,
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
        if (Get.isDialogOpen ?? false) Get.back();
        isEditMode.value ? await updateEvent() : await createEvent();
      },
    );
  }

  // ---------------- TIME PICKER ----------------
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

      // // ✅ Show confirmation dialog immediately after selecting end time
      // if (isEndTime) {
      //   showEventConfirmationDialog();
      // }
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

/// ---------------- HELPER POPUP ----------------
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
      cancelText: AppTexts.CANCEL,
      isProcessing: isProcessing,
      onConfirm: onConfirm,
    ),
  );
}
