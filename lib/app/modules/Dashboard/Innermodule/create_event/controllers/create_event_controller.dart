import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  // Other reactive states
  var searchQuery = ''.obs;
  var selectedUsers = <int>[].obs;
  var isLoading = false.obs;

  // Sample user list for suggestions
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
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    dateController.dispose();
    super.onClose();
  }

  /// Reactive validation methods
  void validateTitle(String value) {
    titleError.value =
        value.trim().isEmpty
            ? "Title cannot be empty"
            : value.trim().length < 3
            ? "Title must be at least 3 characters"
            : '';
  }

  var searchError = ''.obs;

  void validateSearch(String value) {
    searchError.value =
        value.trim().isEmpty ? "Please enter at least one user to search" : '';
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

  void saveChanges() {
    validateTitle(titleController.text);
    validateDescription(descriptionController.text);
    validateDate(dateController.text);

    if (titleError.value.isEmpty &&
        descriptionError.value.isEmpty &&
        dateError.value.isEmpty) {
      isLoading.value = true;

      Future.delayed(const Duration(seconds: 1), () {
        isLoading.value = false;
        debugPrint("Title: ${titleController.text}");
        debugPrint("Description: ${descriptionController.text}");
        debugPrint("Date: ${dateController.text}");
        debugPrint("Search: ${searchController.text}");
        Get.snackbar("Success", "Event saved successfully");
      });
    }
  }
}
