// ignore_for_file: file_names, avoid_print, use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/services/local_notification_service.dart';
import '../../../../../core/utils/helpers/validation_utils.dart';
import '../../../../../database/models/EventModel.dart';
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../core/utils/helpers/date_converter.dart';
import '../../inviteuser/controllers/inviteuser_controller.dart';
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

  /// Load data safely when editing
  void _loadEventData() {
    _isInitializing = true;
    final args = Get.arguments;

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
    titleError.value = Validation.validateEventTitle(value) ?? '';
  }

  void validateDescription(String value) {
    descriptionError.value = Validation.validateEventDescription(value) ?? '';
  }

  void validateDate(String value) {
    dateError.value = Validation.validateEventDate(value) ?? '';
  }

  void validateStartTime(String value) {
    startTimeError.value = Validation.validateEventStart(value) ?? '';
  }

  void validateEndTime(String value) {
    // basic check moved to Validation
    endTimeError.value = Validation.validateEventEnd(value) ?? '';

    // *** keep your existing advanced logic ***
    if (endTimeError.value.isNotEmpty) return;

    if (startTimeController.text.isNotEmpty && dateController.text.isNotEmpty) {
      try {
        final start = _parseTime(startTimeController.text, dateController.text);
        final end = _parseTime(value, dateController.text);

        final now = DateTime.now();

        if (start.isBefore(now)) {
          endTimeError.value = AppTexts.EVENT_TIME_IN_PAST;
          return;
        }

        final diff = end.difference(start).inMinutes;

        if (diff <= 0) {
          endTimeError.value = AppTexts.END_AFTER_START;
        } else if (diff > 120) {
          endTimeError.value = AppTexts.EVENT_DURATION_LIMIT;
        } else {
          endTimeError.value = '';
        }
      } catch (_) {
        endTimeError.value = AppTexts.INVALID_TIME;
      }
    }
  }

  DateTime _parseTime(String time, String date) {
    final datePart = DateFormat('dd MMM yyyy').parse(date);
    final timeParts = time.split(RegExp(r'[:\s]'));
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

  Future<void> createEvent() async {
    isLoading.value = true;

    try {
      final start = DateConverter.convertTo24Hour(startTimeController.text);
      final end = DateConverter.convertTo24Hour(endTimeController.text);
      final eventDate = DateFormat('dd MMM yyyy').parse(dateController.text);

      final newEvent = EventModel(
        id: null,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        eventDate: eventDate,
        startTime: start,
        endTime: end,
        invitedPeople: [],
      );

      await LocalNotificationService.show(
        title: AppTexts.NOTIFY_EVENT_CREATED_TITLE,
        body:
            "Your event '${titleController.text}' has been scheduled successfully.",
      );

      Get.off(() {
        Get.delete<InviteuserController>();
        Get.put(InviteuserController());
        return const InviteuserView();
      }, arguments: newEvent);
    } catch (e) {
      showCustomSnackBar(
        "${AppTexts.ERROR_PREPARING_EVENT} $e",
        SnackbarState.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

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

      final headers = response["headers"];
      final data = response["data"];
      final success = headers?["status"] == "success";

      if (success && data != null) {
        showCustomSnackBar(
          headers?["message"] ?? AppTexts.EVENT_UPDATED,
          SnackbarState.success,
        );
        await LocalNotificationService.show(
          title: AppTexts.NOTIFY_EVENT_UPDATED_TITLE,
          body:
              "Your event '${titleController.text}' has been updated successfully.",
        );

        final updatedEvent = EventModel(
          id: data["id"],
          title: data["title"],
          description: data["description"],
          eventDate: DateTime.parse(data["eventDate"]),
          startTime: data["startTime"],
          endTime: data["endTime"],
          invitedPeople: data["invitedPeople"] ?? [],
        );

        clearForm();

        Get.off(() {
          Get.delete<InviteuserController>();
          Get.put(InviteuserController());
          return const InviteuserView();
        }, arguments: updatedEvent);
      } else {
        showCustomSnackBar(
          AppTexts.FAILED_TO_UPDATE_EVENT,
          SnackbarState.error,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        "${AppTexts.ERROR_UPDATING_EVENT} $e",
        SnackbarState.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    dateController.clear();
    startTimeController.clear();
    endTimeController.clear();
    editingEvent = null;
    isEditMode.value = false;
  }

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

  Future<void> selectTime(
    BuildContext context,
    TextEditingController timeController,
    RxString errorObservable, {
    bool isEndTime = false,
  }) async {
    if (dateController.text.isEmpty) {
      showCustomSnackBar(
        AppTexts.PLEASE_SELECT_DATE_FIRST,
        SnackbarState.error,
      );
      return;
    }

    final now = TimeOfDay.now();
    DateTime selectedDate;

    try {
      selectedDate = DateFormat('dd MMM yyyy').parse(dateController.text);
    } catch (e) {
      showCustomSnackBar(AppTexts.INVALID_DATE_FORMAT, SnackbarState.error);
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
      );

      if (!isEndTime && selectedDateTime.isBefore(DateTime.now())) {
        await Get.dialog(
          CustomPopup(
            title: AppTexts.INVALID_TIME_POPUP_TITLE,
            message: AppTexts.INVALID_TIME_POPUP_MESSAGE,
            confirmText: AppTexts.OK,
            cancelText: null,
            isProcessing: false.obs,
            onConfirm: () => Get.back(),
          ),
        );
        return;
      }

      final formatted24 = DateFormat('HH:mm:ss').format(selectedDateTime);

      timeController.text = formatted24;
      errorObservable.value = '';
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
