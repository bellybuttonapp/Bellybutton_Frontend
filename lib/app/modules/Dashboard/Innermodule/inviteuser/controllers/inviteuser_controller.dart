// ignore_for_file: prefer_is_empty

import 'package:bellybutton/app/api/PublicApiService.dart';
import 'package:bellybutton/app/modules/Dashboard/views/dashboard_view.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../database/models/EventModel.dart';
import 'package:intl/intl.dart';

class InviteuserController extends GetxController {
  // Search Field
  final TextEditingController searchController = TextEditingController();

  // Reactive Observables
  var searchQuery = ''.obs;
  var searchError = ''.obs;
  var selectedUsers = <Contact>[].obs;

  var isLoading = false.obs;
  var contacts = <Contact>[].obs;
  var filteredContacts = <Contact>[].obs;

  late EventModel eventData;
  final _apiService = PublicApiService();

  //----------------------------------------------------
  // INIT
  //----------------------------------------------------
  @override
  void onInit() {
    super.onInit();

    // Validate event argument
    if (Get.arguments == null || Get.arguments is! EventModel) {
      Get.back();
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
      return;
    }

    eventData = Get.arguments as EventModel;

    // Debounce search
    debounce(searchQuery, (_) => filterContacts(), time: 300.milliseconds);

    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });

    fetchContacts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  //----------------------------------------------------
  // FETCH CONTACTS
  //----------------------------------------------------
  Future<void> fetchContacts() async {
    var status = await Permission.contacts.request();

    if (!status.isGranted) {
      searchError.value = AppTexts.NO_CONTACTS_FOUND;
      return;
    }

    final result = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    contacts.assignAll(result);
  }

  //----------------------------------------------------
  // FILTER CONTACTS
  //----------------------------------------------------
  void filterContacts() {
    final q = searchQuery.value.trim();

    if (q.isEmpty) {
      filteredContacts.assignAll([]);
      return;
    }

    final clean = q.toLowerCase().replaceAll(RegExp(r'[^\dA-Za-z]'), "");

    final list =
        contacts.where((c) {
          final name = c.displayName.toLowerCase().replaceAll(
            RegExp(r'\s+'),
            '',
          );

          final number =
              c.phones.isNotEmpty
                  ? c.phones.first.number.replaceAll(RegExp(r'[^\d]'), "")
                  : "";

          return name.contains(clean) || number.contains(clean);
        }).toList();

    filteredContacts.assignAll(list);
  }

  //----------------------------------------------------
  // FETCH PHOTO SMOOTHLY
  //----------------------------------------------------
  Future<void> fetchPhoto(Contact c) async {
    try {
      if (c.photo != null && c.photo!.isNotEmpty) return;

      final full = await FlutterContacts.getContact(c.id, withPhoto: true);

      if (full?.photo != null && full!.photo!.isNotEmpty) {
        c.photo = full.photo;
      }
    } catch (_) {}
  }

  //----------------------------------------------------
  // VALIDATE SEARCH SMOOTHLY
  //----------------------------------------------------
  void validateSearch(String value) {
    searchError.value = "";
    searchQuery.value = value.trim();
  }

  //----------------------------------------------------
  // SELECT / REMOVE USERS
  //----------------------------------------------------
  void toggleUserSelection(Contact c) {
    final exists = selectedUsers.any((x) => x.id == c.id);

    if (exists) {
      selectedUsers.removeWhere((x) => x.id == c.id);
      HapticFeedback.lightImpact();
      return;
    }

    if (selectedUsers.length >= 5) {
      showCustomSnackBar(AppTexts.LIMIT_REACHED, SnackbarState.error);
      return;
    }

    selectedUsers.add(c);
    HapticFeedback.mediumImpact();
    searchController.clear();
    filteredContacts.assignAll([]);
  }

  //----------------------------------------------------
  // INVITE USERS
  //----------------------------------------------------
  Future<void> inviteSelectedUsers() async {
    if (selectedUsers.isEmpty) {
      showCustomSnackBar(
        AppTexts.PLEASE_SELECT_AT_LEAST_ONE_USER,
        SnackbarState.error,
      );
      return;
    }

    isLoading.value = true;

    try {
      final invitedList =
          selectedUsers.map((c) {
            return {
              "email":
                  c.emails.isNotEmpty ? c.emails.first.address.trim() : null,
              "phone": c.phones.isNotEmpty ? c.phones.first.number : null,
            };
          }).toList();

      dynamic response;

      if (eventData.id == null) {
        response = await _apiService.createEvent(
          title: eventData.title,
          description: eventData.description,
          eventDate: DateFormat('yyyy-MM-dd').format(eventData.eventDate),
          startTime: eventData.startTime,
          endTime: eventData.endTime,
          invitedPeople: invitedList,
        );
      } else {
        response = await _apiService.updateEvent(
          id: eventData.id!,
          title: eventData.title,
          description: eventData.description,
          eventDate: DateFormat('yyyy-MM-dd').format(eventData.eventDate),
          startTime: eventData.startTime,
          endTime: eventData.endTime,
        );
      }

      final ok = response?["headers"]?["status"] == "success";

      if (ok) {
        showCustomSnackBar(
          AppTexts.USERS_INVITED_SUCCESSFULLY,
          SnackbarState.success,
        );
        Get.offAll(() => DashboardView());
      } else {
        showCustomSnackBar(AppTexts.INVITE_FAILED, SnackbarState.error);
      }
    } catch (e) {
      showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }
}
