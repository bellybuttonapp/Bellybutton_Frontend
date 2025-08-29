import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class CreateEventController extends GetxController {
  // Controllers for TextFields
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final searchController = TextEditingController();
  final dateController = TextEditingController();

  // Reactive error messages
  var titleError = ''.obs;
  var descriptionError = ''.obs;
  var dateError = ''.obs;
  var searchError = ''.obs;
  var isConfirmLoading = false.obs;

  // Other reactive states
  var searchQuery = ''.obs;
  var selectedUsers = <int>[].obs;
  var isLoading = false.obs;

  /// 🔑 Calendar State
  var focusedDay = DateTime.now().obs;
  var selectedDay = DateTime.now().obs;
  var calendarFormat = CalendarFormat.month.obs;

  /// 🔑 Events
  var events = <DateTime, List<String>>{}.obs;

  /// 🔑 Selected time for Cupertino pickers
  var fromTime = DateTime.now().obs;
  var toTime = DateTime.now().add(const Duration(hours: 1)).obs;

  /// ✅ Sample user list for suggestions
  final sampleUsers = [
    "Alice",
    "Bob",
    "Charlie",
    "David",
    "Eve",
    "Frank",
    "Grace",
  ];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });

    // Initialize From-To times
    fromTime.value = DateTime(
      selectedDay.value.year,
      selectedDay.value.month,
      selectedDay.value.day,
      9, // default from 9 AM
      0,
    );

    toTime.value = DateTime(
      selectedDay.value.year,
      selectedDay.value.month,
      selectedDay.value.day,
      17, // default to 5 PM
      0,
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    dateController.dispose();
    super.onClose();
  }

  /// Validation methods
  void validateTitle(String value) {
    titleError.value =
        value.trim().isEmpty
            ? "Title cannot be empty"
            : value.trim().length < 3
            ? "Title must be at least 3 characters"
            : '';
  }

  void validateDescription(String value) {
    descriptionError.value =
        value.trim().isEmpty
            ? "Description cannot be empty"
            : value.trim().length < 5
            ? "Description must be at least 5 characters"
            : '';
  }

  void validateDate(String value) {
    dateError.value = value.trim().isEmpty ? "Please select date and time" : '';
  }

  void validateSearch(String value) {
    searchError.value =
        value.trim().isEmpty ? "Please enter at least one user to search" : '';
  }

  /// 🔑 Select Day Method
  void selectDay(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;

    // Update From-To times to selected day
    fromTime.value = DateTime(
      selected.year,
      selected.month,
      selected.day,
      fromTime.value.hour,
      fromTime.value.minute,
    );

    toTime.value = DateTime(
      selected.year,
      selected.month,
      selected.day,
      toTime.value.hour,
      toTime.value.minute,
    );
  }

  /// Save changes
  void saveChanges() {
    validateTitle(titleController.text);
    validateDescription(descriptionController.text);
    validateDate(dateController.text);
    validateSearch(searchController.text);

    if (titleError.value.isEmpty &&
        descriptionError.value.isEmpty &&
        dateError.value.isEmpty &&
        searchError.value.isEmpty) {
      isLoading.value = true;

      Future.delayed(const Duration(seconds: 1), () {
        isLoading.value = false;
        debugPrint("Title: ${titleController.text}");
        debugPrint("Description: ${descriptionController.text}");
        debugPrint("Date: ${dateController.text}");
        debugPrint("Search: ${searchController.text}");
        debugPrint("From: ${fromTime.value}");
        debugPrint("To: ${toTime.value}");
        Get.snackbar("Success", "Event saved successfully");
      });
    }
  }
}
