// ignore_for_file: file_names, avoid_print, use_build_context_synchronously, unnecessary_null_comparison, unused_field, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/utils/helpers/validation_utils.dart';
import '../../../../../database/models/EventModel.dart';
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../core/utils/helpers/date_converter.dart';
import '../../../../../routes/app_pages.dart';
import '../../inviteuser/controllers/inviteuser_controller.dart';
import '../../inviteuser/models/invite_user_arguments.dart';
import '../../inviteuser/views/inviteuser_view.dart';

/// Helper class for device locale settings
class DeviceLocaleHelper {
  /// Check if device uses 24-hour format
  static bool is24HourFormat(BuildContext context) {
    return MediaQuery.of(context).alwaysUse24HourFormat;
  }

  /// Get device locale
  static Locale getDeviceLocale(BuildContext context) {
    return Localizations.localeOf(context);
  }

  /// Get locale string (e.g., "en_US", "hi_IN")
  static String getLocaleString(BuildContext context) {
    final locale = getDeviceLocale(context);
    return '${locale.languageCode}_${locale.countryCode ?? ''}';
  }
}

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
  RxBool hasChanges = false.obs;

  EventModel? editingEvent;

  /// ---------------- VALIDATION ----------------
  var titleError = ''.obs;
  var descriptionError = ''.obs;
  var dateError = ''.obs;
  var startTimeError = ''.obs;
  var endTimeError = ''.obs;

  /// Track when times were selected to avoid showing "time passed" errors
  /// while user stays on page (time was valid when selected)
  DateTime? _startTimeSelectedAt;
  DateTime? _endTimeSelectedAt;

  /// ---------------- CALENDAR ----------------
  var showCalendar = false.obs;
  var selectedDay = DateTime.now().obs;
  var focusedDay = DateTime.now().obs;
  var calendarFormat = CalendarFormat.month.obs;

  bool _isInitializing = false;

  /// ---------------- ROTATING SUGGESTIONS ----------------
  var currentTitleSuggestionIndex = 0.obs;
  var currentDescriptionSuggestionIndex = 0.obs;
  Timer? _suggestionTimer;

  String get currentTitleSuggestion =>
      AppTexts.TITLE_SUGGESTIONS[currentTitleSuggestionIndex.value];
  String get currentDescriptionSuggestion =>
      AppTexts.DESCRIPTION_SUGGESTIONS[currentDescriptionSuggestionIndex.value];

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    _startSuggestionTimer();
  }

  void _startSuggestionTimer() {
    _suggestionTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      // Only rotate if fields are empty
      if (titleController.text.isEmpty) {
        currentTitleSuggestionIndex.value =
            (currentTitleSuggestionIndex.value + 1) % AppTexts.TITLE_SUGGESTIONS.length;
      }
      if (descriptionController.text.isEmpty) {
        currentDescriptionSuggestionIndex.value =
            (currentDescriptionSuggestionIndex.value + 1) %
                AppTexts.DESCRIPTION_SUGGESTIONS.length;
      }
    });
  }

  void _initControllers() {
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    dateController = TextEditingController();
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();

    // Add listeners to detect changes
    titleController.addListener(_checkForChanges);
    descriptionController.addListener(_checkForChanges);
    dateController.addListener(_checkForChanges);
    startTimeController.addListener(_checkForChanges);
    endTimeController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    if (_isInitializing) return;

    final hasTitle = titleController.text.isNotEmpty;
    final hasDescription = descriptionController.text.isNotEmpty;
    final hasDate = dateController.text.isNotEmpty;
    final hasStartTime = startTimeController.text.isNotEmpty;
    final hasEndTime = endTimeController.text.isNotEmpty;

    hasChanges.value = hasTitle || hasDescription || hasDate || hasStartTime || hasEndTime;
  }

  /// Discard all unsaved changes and go back
  void discardChanges() {
    if (!hasChanges.value) {
      Get.back();
      return;
    }

    Get.dialog(
      CustomPopup(
        title: AppTexts.DISCARD_CHANGES_TITLE,
        message: AppTexts.DISCARD_CHANGES_SUBTITLE,
        confirmText: AppTexts.DISCARD,
        cancelText: AppTexts.CANCEL,
        isProcessing: false.obs,
        onConfirm: () {
          clearForm();
          Get.back(); // Close dialog
          Get.back(); // Go back to previous screen
        },
      ),
    );
  }

  @override
  void onReady() {
    super.onReady();
    _loadEventData();
  }

  /// Load data safely when editing
  /// Converts UTC stored times to user's local timezone for display
  void _loadEventData() {
    _isInitializing = true;
    final args = Get.arguments;

    if (args is EventModel) {
      isEditMode.value = true;
      editingEvent = args;

      titleController.text = args.title;
      descriptionController.text = args.description;

      // Convert UTC date/time to local timezone for display
      // This ensures users see times in their local timezone
      dateController.text = args.getLocalDateString();
      startTimeController.text = args.getLocalStartTimeString();
      endTimeController.text = args.getLocalEndTimeString();

      // Update selected day to local date
      selectedDay.value = args.localEventDate;
      focusedDay.value = args.localEventDate;
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

    // For final submission, force fresh validation (reset selection timestamps)
    // This ensures we catch any times that became invalid while user was on page
    _startTimeSelectedAt = null;
    _endTimeSelectedAt = null;
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

  void validateStartTime(String value, {bool isFromTimePicker = false}) {
    // Basic empty check
    final basicError = Validation.validateEventStart(value);
    if (basicError != null) {
      startTimeError.value = basicError;
      return;
    }

    // Skip past-time validation in edit mode (existing events may have past start times)
    if (isEditMode.value) {
      startTimeError.value = '';
      return;
    }

    // Skip past-time validation if time was recently selected (within 10 minutes)
    // This prevents "time passed" errors while user stays on page
    if (_startTimeSelectedAt != null && !isFromTimePicker) {
      final timeSinceSelection = DateTime.now().difference(_startTimeSelectedAt!);
      if (timeSinceSelection.inMinutes < 10) {
        // Time was valid when selected, don't show past-time errors while user is on page
        startTimeError.value = '';
        return;
      }
    }

    // If called from time picker, update the selection timestamp
    if (isFromTimePicker) {
      _startTimeSelectedAt = DateTime.now();
    }

    // Comprehensive validation with date context
    if (dateController.text.isNotEmpty) {
      final error = Validation.validateStartTimeWithContext(
        startTime: value,
        eventDate: dateController.text,
        bufferMinutes: 0,
      );
      startTimeError.value = error ?? '';

      // Re-validate end time if it exists (start time change may affect end time validity)
      if (endTimeController.text.isNotEmpty && error == null) {
        _validateEndTimeOnly(endTimeController.text);
      }
    } else {
      startTimeError.value = '';
    }
  }

  void validateEndTime(String value, {bool isFromTimePicker = false}) {
    _validateEndTimeOnly(value, isFromTimePicker: isFromTimePicker);
  }

  void _validateEndTimeOnly(String value, {bool isFromTimePicker = false}) {
    // Basic empty check
    final basicError = Validation.validateEventEnd(value);
    if (basicError != null) {
      endTimeError.value = basicError;
      return;
    }

    // Need both start time and date for comprehensive validation
    if (startTimeController.text.isEmpty || dateController.text.isEmpty) {
      endTimeError.value = '';
      return;
    }

    // Skip past-time validation if times were recently selected (within 10 minutes)
    // This prevents "time passed" errors while user stays on page
    final hasRecentStartSelection = _startTimeSelectedAt != null &&
        DateTime.now().difference(_startTimeSelectedAt!).inMinutes < 10;
    final hasRecentEndSelection = _endTimeSelectedAt != null &&
        DateTime.now().difference(_endTimeSelectedAt!).inMinutes < 10;

    // If called from time picker, update the selection timestamp
    if (isFromTimePicker) {
      _endTimeSelectedAt = DateTime.now();
    }

    // Comprehensive validation with context
    // Skip past-time check if time was recently selected OR in edit mode
    final error = Validation.validateEndTimeWithContext(
      endTime: value,
      startTime: startTimeController.text,
      eventDate: dateController.text,
      minDurationMinutes: 15,
      maxDurationMinutes: 120,
      skipPastCheck: isEditMode.value || hasRecentStartSelection || hasRecentEndSelection,
    );
    endTimeError.value = error ?? '';
  }

  void selectDay(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    // Use locale-aware date formatting for display
    dateController.text = DateConverter.formatDateLocale(selected);

    // Re-validate times when date changes (affects past-time validation)
    if (startTimeController.text.isNotEmpty) {
      validateStartTime(startTimeController.text);
    }
    if (endTimeController.text.isNotEmpty) {
      validateEndTime(endTimeController.text);
    }
  }

  Future<void> createEvent() async {
    isLoading.value = true;

    try {
      // Parse date from locale-aware format
      final localDate = DateConverter.parseDate(dateController.text);

      if (localDate == null) {
        showCustomSnackBar(AppTexts.INVALID_DATE_FORMAT, SnackbarState.error);
        return;
      }

      // Convert local times to UTC for global timezone support
      // This ensures events work correctly across all countries
      final startUtcData = DateConverter.getUtcDateTimeForStorage(
        dateController.text,
        startTimeController.text,
      );
      final endUtcData = DateConverter.getUtcDateTimeForStorage(
        dateController.text,
        endTimeController.text,
      );

      if (startUtcData == null || endUtcData == null) {
        showCustomSnackBar(AppTexts.INVALID_DATE_FORMAT, SnackbarState.error);
        return;
      }

      // Store in UTC - this will be converted to local time when displayed
      final utcEventDate = startUtcData['utcDate'] as DateTime;
      final utcStartTime = startUtcData['utcTime'] as String;
      final utcEndTime = endUtcData['utcTime'] as String;

      // Store creator's timezone info
      final timezoneName = startUtcData['creatorTimezone'] as String;
      final timezoneOffset = startUtcData['creatorOffset'] as String;

      // 🔍 DEBUG: Print timezone conversion details
      print('═══════════════════════════════════════════════════════');
      print('🌍 TIMEZONE CONVERSION DEBUG:');
      print('───────────────────────────────────────────────────────');
      print('📝 User Input:');
      print('   Date: ${dateController.text}');
      print('   Start Time: ${startTimeController.text}');
      print('   End Time: ${endTimeController.text}');
      print('───────────────────────────────────────────────────────');
      print('🌐 Device Timezone:');
      print('   Name: $timezoneName');
      print('   Offset: $timezoneOffset');
      print('───────────────────────────────────────────────────────');
      print('✅ Converted to UTC:');
      print('   UTC Date: ${DateFormat('yyyy-MM-dd').format(utcEventDate)}');
      print('   UTC Start Time: $utcStartTime');
      print('   UTC End Time: $utcEndTime');
      print('───────────────────────────────────────────────────────');
      print('📤 Sending to Backend:');
      print('   eventDate: "${DateFormat('yyyy-MM-dd').format(utcEventDate)}"');
      print('   startTime: "$utcStartTime"');
      print('   endTime: "$utcEndTime"');
      print('   timezone: "$timezoneName"');
      print('   timezoneOffset: "$timezoneOffset"');
      print('═══════════════════════════════════════════════════════');

      final newEvent = EventModel(
        id: null,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        eventDate: utcEventDate,
        startTime: utcStartTime,
        endTime: utcEndTime,
        invitedPeople: [],
        timezone: timezoneName,
        timezoneOffset: timezoneOffset,
      );

      // Navigate to invite users screen with type-safe arguments
      Get.off(
        () {
          // Initialize controller with fresh instance
          Get.delete<InviteuserController>();
          Get.put(InviteuserController());
          return InviteuserView();
        },
        arguments: InviteUserArguments.create(newEvent),
      );
    } catch (e) {
      showCustomSnackBar(
        "${AppTexts.ERROR_PREPARING_SHOOT} $e",
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
      // Parse date from locale-aware format
      final parsedDate = DateConverter.parseDate(dateController.text);

      if (parsedDate == null) {
        showCustomSnackBar(AppTexts.INVALID_DATE_FORMAT, SnackbarState.error);
        return;
      }

      // Convert local times to UTC for global timezone support
      final startUtcData = DateConverter.getUtcDateTimeForStorage(
        dateController.text,
        startTimeController.text,
      );
      final endUtcData = DateConverter.getUtcDateTimeForStorage(
        dateController.text,
        endTimeController.text,
      );

      if (startUtcData == null || endUtcData == null) {
        showCustomSnackBar(AppTexts.INVALID_DATE_FORMAT, SnackbarState.error);
        return;
      }

      // Get UTC values for API
      final utcEventDate = startUtcData['utcDate'] as DateTime;
      final utcStartTime = startUtcData['utcTime'] as String;
      final utcEndTime = endUtcData['utcTime'] as String;
      final timezoneName = startUtcData['creatorTimezone'] as String;
      final timezoneOffset = startUtcData['creatorOffset'] as String;

      // Format UTC date for API (ISO 8601 standard: yyyy-MM-dd)
      final apiDateFormat = DateConverter.formatDateForApi(utcEventDate);

      // 🔍 DEBUG: Print timezone conversion details for UPDATE
      print('═══════════════════════════════════════════════════════');
      print('🌍 UPDATE TIMEZONE CONVERSION DEBUG:');
      print('───────────────────────────────────────────────────────');
      print('📝 User Input:');
      print('   Date: ${dateController.text}');
      print('   Start Time: ${startTimeController.text}');
      print('   End Time: ${endTimeController.text}');
      print('───────────────────────────────────────────────────────');
      print('🌐 Device Timezone:');
      print('   Name: $timezoneName');
      print('   Offset: $timezoneOffset');
      print('───────────────────────────────────────────────────────');
      print('✅ Converted to UTC:');
      print('   UTC Date: $apiDateFormat');
      print('   UTC Start Time: $utcStartTime');
      print('   UTC End Time: $utcEndTime');
      print('───────────────────────────────────────────────────────');
      print('📤 Sending to Backend:');
      print('   eventDate: "$apiDateFormat"');
      print('   startTime: "$utcStartTime"');
      print('   endTime: "$utcEndTime"');
      print('   timezone: "$timezoneName"');
      print('   timezoneOffset: "$timezoneOffset"');
      print('═══════════════════════════════════════════════════════');

      final response = await _apiService.updateEvent(
        id: editingEvent!.id!,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        eventDate: apiDateFormat,
        startTime: utcStartTime,
        endTime: utcEndTime,
        timezone: timezoneName,           // Creator's timezone for global support
        timezoneOffset: timezoneOffset,   // Creator's offset for global support
      );

      final headers = response["headers"];
      final data = response["data"];
      final success = headers?["status"] == "success";

      if (success && data != null) {
        // Show success message
        showCustomSnackBar(
          AppTexts.SHOOT_UPDATED,
          SnackbarState.success,
        );

        clearForm();

        // Navigate to dashboard and clear the navigation stack
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        showCustomSnackBar(
          AppTexts.FAILED_TO_UPDATE_SHOOT,
          SnackbarState.error,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        "${AppTexts.ERROR_UPDATING_SHOOT} $e",
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
    // Reset time selection timestamps
    _startTimeSelectedAt = null;
    _endTimeSelectedAt = null;
  }

  void showEventConfirmationDialog() {
    _showConfirmationDialog(
      title:
          isEditMode.value
              ? AppTexts.CONFIRM_SHOOT_UPDATE
              : AppTexts.CONFIRM_SHOOT_CREATION,
      confirmText: AppTexts.OK,
      messageWidget: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text:
                  isEditMode.value
                      ? AppTexts.CONFIRM_SHOOT_UPDATE_MESSAGE
                      : AppTexts.CONFIRM_SHOOT_CREATION_MESSAGE,
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

    // Parse date using locale-aware parser
    final selectedDate = DateConverter.parseDate(dateController.text);
    if (selectedDate == null) {
      showCustomSnackBar(AppTexts.INVALID_DATE_FORMAT, SnackbarState.error);
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Respect device's 24-hour format setting
    final use24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;

    // Use previously selected time if available, otherwise use current time
    // For start time on today: use the later of (previous selection, current time)
    TimeOfDay initialTime = now;
    if (timeController.text.isNotEmpty) {
      final time24 = DateConverter.convertTo24Hour(timeController.text);
      final timeParts = time24.split(':');
      if (timeParts.length >= 2) {
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour != null && minute != null) {
          final previousTime = TimeOfDay(hour: hour, minute: minute);

          // For start time: check if previous selection is in the past (today only)
          final isToday = selectedDate.year == DateTime.now().year &&
                          selectedDate.month == DateTime.now().month &&
                          selectedDate.day == DateTime.now().day;

          if (!isEndTime && isToday && !isEditMode.value) {
            // Use the later time: previous selection or current time
            final previousMinutes = previousTime.hour * 60 + previousTime.minute;
            final nowMinutes = now.hour * 60 + now.minute;
            initialTime = previousMinutes >= nowMinutes ? previousTime : now;
          } else {
            // For end time, future dates, or edit mode: use previous selection
            initialTime = previousTime;
          }
        }
      }
    }

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              hourMinuteColor: isDark ? Colors.grey[800] : AppColors.primaryColor.withOpacity(0.1),
              hourMinuteTextColor: isDark ? Colors.white : AppColors.primaryColor,
              dialHandColor: AppColors.primaryColor,
              dialBackgroundColor: isDark ? Colors.grey[800] : AppColors.primaryColor.withOpacity(0.1),
              dialTextColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : (isDark ? Colors.white : AppColors.primaryColor)),
              entryModeIconColor: isDark ? Colors.white : AppColors.primaryColor,
              dayPeriodColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? AppColors.primaryColor
                      : (isDark ? Colors.grey[800]! : AppColors.primaryColor.withOpacity(0.1))),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : (isDark ? Colors.white : AppColors.primaryColor)),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white : AppColors.primaryColor,
              ),
            ),
          ),
          // Respect user's device 24-hour format preference
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24HourFormat),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      var selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        picked.hour,
        picked.minute,
      );

      // Auto-correct start time if too soon (only for start time, not edit mode)
      bool wasAutoCorrected = false;
      if (!isEndTime && !isEditMode.value) {
        final now = DateTime.now();
        final minAllowedTime = now.add(const Duration(minutes: 1));

        // Check if selected time is in the past or too soon
        if (selectedDateTime.isBefore(minAllowedTime)) {
          // Round up to nearest 5 minutes from minAllowedTime
          final roundedDateTime = DateTime(
            minAllowedTime.year,
            minAllowedTime.month,
            minAllowedTime.day,
            minAllowedTime.hour,
            ((minAllowedTime.minute / 5).ceil() * 5),
          );

          // If rounding pushed minutes to 60, DateTime automatically adjusts the hour
          selectedDateTime = roundedDateTime;
          picked = TimeOfDay(hour: selectedDateTime.hour, minute: selectedDateTime.minute);
          wasAutoCorrected = true;
        }
      }

      // Use locale-aware time formatting based on device preference
      final formattedTime = DateConverter.timeOfDayToLocaleString(
        picked,
        use24Hour: use24HourFormat,
      );
      timeController.text = formattedTime;

      // Show snackbar if time was auto-corrected
      if (wasAutoCorrected) {
        showCustomSnackBar(
          "Time adjusted to $formattedTime (earliest available)",
          SnackbarState.warning,
        );
      }

      // Validate and show error inline (no popup)
      // Pass isFromTimePicker: true to record selection timestamp
      if (isEndTime) {
        validateEndTime(formattedTime, isFromTimePicker: true);
      } else {
        // Auto-fill end time ONLY if it's empty (don't overwrite user's selection)
        if (endTimeController.text.isEmpty) {
          final endDateTime = selectedDateTime.add(const Duration(hours: 2));
          final endTimeOfDay = TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);
          final formattedEndTime = DateConverter.timeOfDayToLocaleString(
            endTimeOfDay,
            use24Hour: use24HourFormat,
          );
          endTimeController.text = formattedEndTime;
          // Mark end time as selected via time picker (auto-filled counts as selected)
          _endTimeSelectedAt = DateTime.now();
          validateEndTime(formattedEndTime, isFromTimePicker: true);
        } else {
          // End time already set by user - just validate it with new start time
          validateEndTime(endTimeController.text);
        }

        // Validate start time and record selection timestamp
        validateStartTime(formattedTime, isFromTimePicker: true);
      }
    }
  }

  @override
  void onClose() {
    _suggestionTimer?.cancel();
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