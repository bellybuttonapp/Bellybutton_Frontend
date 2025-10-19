// ignore_for_file: prefer_is_empty

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';

class InviteuserController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  var searchQuery = ''.obs;
  var searchError = ''.obs;
  var selectedUsers = <Contact>[].obs;
  var isLoading = false.obs;
  var contacts = <Contact>[].obs;
  var filteredContacts = <Contact>[].obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
      filterContacts();
    });
    fetchContacts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchContacts() async {
    var permissionStatus = await Permission.contacts.request();

    if (permissionStatus.isGranted) {
      // Fetch all contacts with properties AND photos
      final allContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true, // <-- fetch photos
      );
      contacts.assignAll(allContacts);
      filterContacts();
    } else {
      searchError.value = "Permission denied to access contacts";
    }
  }

  Future<void> fetchPhoto(Contact contact) async {
    if (contact.photo == null || contact.photo!.isEmpty) {
      final fullContact = await FlutterContacts.getContact(
        contact.id,
        withPhoto: true,
      );
      contact.photo = fullContact?.photo;
    }
  }

  void filterContacts() {
    final rawQuery = searchQuery.value.trim();
    if (rawQuery.isEmpty) {
      filteredContacts.assignAll([]);
      return;
    }

    // Normalize query: lowercase, remove spaces, dashes, parentheses, etc.
    final query = rawQuery.toLowerCase().replaceAll(
      RegExp(r'[\s\-\(\)\+]'),
      '',
    );

    final results =
        contacts.where((contact) {
          // Normalize name
          final name =
              contact.displayName?.toLowerCase().replaceAll(
                RegExp(r'\s+'),
                '',
              ) ??
              '';

          // Normalize phone numbers
          final numbers = contact.phones
              .map((p) => p.number.replaceAll(RegExp(r'[\s\-\(\)\+]'), ''))
              .join(''); // join all numbers

          // Match query anywhere in name or phone numbers
          return name.contains(query) || numbers.contains(query);
        }).toList();

    filteredContacts.assignAll(results);
  }

  bool validateAllFields() {
    validateSearch(searchController.text);
    return searchError.value.isEmpty;
  }

  void validateSearch(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      searchError.value = "Please enter a user to search";
      return;
    }

    if (trimmedValue.length < 1) {
      searchError.value = "Search term must be at least 1 character";
      return;
    }

    if (trimmedValue.length > 50) {
      searchError.value = "Search term is too long";
      return;
    }

    // Allow any character (letters, numbers, symbols) for flexible phone search
    searchError.value = '';
  }

  void toggleUserSelection(Contact contact) {
    final isSelected = selectedUsers.any((c) => c.id == contact.id);

    if (isSelected) {
      selectedUsers.removeWhere((c) => c.id == contact.id);
      HapticFeedback.lightImpact(); // deselect feedback
    } else {
      if (selectedUsers.length < 5) {
        selectedUsers.add(contact);
        HapticFeedback.mediumImpact(); // select feedback

        // Clear search field after selecting a user
        searchController.clear();
        searchQuery.value = '';
        filteredContacts.assignAll([]);
      } else {
        HapticFeedback.heavyImpact(); // error feedback
        showCustomSnackBar(AppTexts.Limit_Reached, SnackbarState.error);
      }
    }
    update();
  }
}
