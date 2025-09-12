import 'package:get/get.dart';
import 'package:flutter/material.dart';

class InviteuserController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  var searchQuery = ''.obs;
  var searchError = ''.obs;
  var selectedUsers = <int>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void validateSearch(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      searchError.value = "Please enter a user to search";
      return;
    }

    if (trimmedValue.length < 2) {
      searchError.value = "Search term must be at least 2 characters";
      return;
    }

    if (trimmedValue.length > 30) {
      searchError.value = "Search term is too long";
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(trimmedValue)) {
      searchError.value = "Only letters and numbers are allowed";
      return;
    }

    searchError.value = '';
  }

  bool validateAllFields() {
    validateSearch(searchController.text);
    return searchError.value.isEmpty;
  }

  void toggleUserSelection(int userId) {
    if (selectedUsers.contains(userId)) {
      selectedUsers.remove(userId);
    } else {
      selectedUsers.add(userId);
    }
  }
}
