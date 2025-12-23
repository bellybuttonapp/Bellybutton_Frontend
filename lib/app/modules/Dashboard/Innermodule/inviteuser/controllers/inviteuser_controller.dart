// ignore_for_file: prefer_is_empty

import 'package:bellybutton/app/api/PublicApiService.dart';
import 'package:bellybutton/app/modules/Dashboard/views/dashboard_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../database/models/EventModel.dart';
import 'package:intl/intl.dart';

/// Wrapper for Contact with pre-sanitized display name
class SafeContact {
  final Contact contact;
  final String safeName;

  SafeContact(this.contact, this.safeName);

  String get id => contact.id;
  List<Phone> get phones => contact.phones;
  List<Email> get emails => contact.emails;
  Uint8List? get photo => contact.photo;
  set photo(Uint8List? value) => contact.photo = value;
}

class InviteuserController extends GetxController {
  // Text Controller
  final TextEditingController searchController = TextEditingController();

  // Scroll and Refresh Controllers
  final ScrollController scrollController = ScrollController();
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  // Reactive State
  final searchQuery = ''.obs;
  final searchError = ''.obs;
  final contactsPermissionError = ''.obs;
  final selectedUsers = <SafeContact>[].obs;
  final isLoading = false.obs;
  final isRemovingUser = false.obs;
  final isLoadingContacts = true.obs;
  final contacts = <SafeContact>[].obs;
  final filteredContacts = <SafeContact>[].obs;
  final alreadyInvitedUsers = <Map<String, dynamic>>[].obs;

  // Pagination state
  static const int _pageSize = 10;
  final displayedContacts = <SafeContact>[].obs;
  final isLoadingMore = false.obs;
  final hasMoreContacts = true.obs;

  // Photo caching
  final Map<String, Uint8List?> _photoCache = {};
  final Set<String> _photoFetchingIds = {};

  // Event data
  late EventModel eventData;
  final _apiService = PublicApiService();
  final Set<String> _alreadyInvitedPhones = {};

  //----------------------------------------------------
  // LIFECYCLE
  //----------------------------------------------------
  @override
  void onInit() {
    super.onInit();

    if (Get.arguments == null || Get.arguments is! EventModel) {
      Get.back();
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
      return;
    }

    eventData = Get.arguments as EventModel;
    _loadAlreadyInvitedUsers();
    _extractAlreadyInvitedPhones();

    searchController.addListener(_onSearchChanged);
    fetchContacts();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    scrollController.dispose();
    refreshController.dispose();
    _photoCache.clear();
    super.onClose();
  }

  void _onSearchChanged() {
    final query = searchController.text.trim();
    searchQuery.value = query;
    filterContacts(); // Filter instantly without debounce
  }

  //----------------------------------------------------
  // STRING SANITIZATION (Production-ready)
  //----------------------------------------------------
  String _sanitizeString(String input) {
    if (input.isEmpty) return "?";

    try {
      final buffer = StringBuffer();
      final codeUnits = input.codeUnits;

      for (int i = 0; i < codeUnits.length; i++) {
        final code = codeUnits[i];

        // Handle surrogate pairs
        if (code >= 0xD800 && code <= 0xDBFF) {
          if (i + 1 < codeUnits.length) {
            final next = codeUnits[i + 1];
            if (next >= 0xDC00 && next <= 0xDFFF) {
              buffer.writeCharCode(code);
              buffer.writeCharCode(next);
              i++;
              continue;
            }
          }
          continue; // Skip unpaired high surrogate
        } else if (code >= 0xDC00 && code <= 0xDFFF) {
          continue; // Skip orphan low surrogate
        }

        buffer.writeCharCode(code);
      }

      final result = buffer.toString().trim();
      return result.isEmpty ? "?" : result;
    } catch (_) {
      // Ultimate fallback: ASCII only
      try {
        final ascii = String.fromCharCodes(
          input.codeUnits.where((c) => c >= 0x20 && c <= 0x7E),
        ).trim();
        return ascii.isEmpty ? "?" : ascii;
      } catch (_) {
        return "?";
      }
    }
  }

  /// Public method for view to use
  String sanitizeDisplayName(String name) => _sanitizeString(name);

  //----------------------------------------------------
  // ALREADY INVITED USERS
  //----------------------------------------------------
  void _loadAlreadyInvitedUsers() {
    alreadyInvitedUsers.clear();
    for (final person in eventData.invitedPeople) {
      if (person is Map) {
        alreadyInvitedUsers.add(Map<String, dynamic>.from(person));
      }
    }
  }

  void _extractAlreadyInvitedPhones() {
    _alreadyInvitedPhones.clear();
    for (final person in eventData.invitedPeople) {
      if (person is Map) {
        final phone = person['phone']?.toString() ?? '';
        if (phone.isNotEmpty) {
          final normalized = phone.replaceAll(RegExp(r'[^\d]'), '');
          if (normalized.isNotEmpty) {
            _alreadyInvitedPhones.add(normalized);
          }
        }
      }
    }
  }

  //----------------------------------------------------
  // COMPUTED PROPERTIES
  //----------------------------------------------------
  int get remainingSlots => 4 - alreadyInvitedUsers.length - selectedUsers.length;
  int get alreadyInvitedCount => alreadyInvitedUsers.length;
  bool get isLimitReached => (alreadyInvitedCount + selectedUsers.length) >= 4;

  //----------------------------------------------------
  // FETCH CONTACTS
  //----------------------------------------------------
  Future<void> fetchContacts() async {
    isLoadingContacts.value = true;
    contactsPermissionError.value = '';

    try {
      final status = await Permission.contacts.request();

      if (!status.isGranted) {
        contactsPermissionError.value = AppTexts.NO_CONTACTS_FOUND;
        return;
      }

      final result = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Convert to SafeContact with pre-sanitized names
      final safeContacts = result.map((c) {
        final safeName = _sanitizeString(c.displayName);
        return SafeContact(c, safeName);
      }).toList();

      contacts.assignAll(safeContacts);
      filterContacts(); // Initialize filtered and displayed contacts with pagination
    } catch (e) {
      contactsPermissionError.value = AppTexts.SOMETHING_WENT_WRONG;
      debugPrint('Error fetching contacts: $e');
    } finally {
      isLoadingContacts.value = false;
    }
  }

  //----------------------------------------------------
  // FILTER CONTACTS
  //----------------------------------------------------
  void filterContacts() {
    final q = searchQuery.value.trim();

    // Filter out already invited contacts
    final availableContacts = contacts.where((c) {
      final number = c.phones.isNotEmpty
          ? c.phones.first.number.replaceAll(RegExp(r'[^\d]'), '')
          : '';
      if (number.isNotEmpty && _isAlreadyInvited(number)) {
        return false;
      }
      return true;
    }).toList();

    if (q.isEmpty) {
      // Show all available contacts when search is empty
      filteredContacts.assignAll(availableContacts);
      _resetPagination();
      return;
    }

    final clean = q.toLowerCase().replaceAll(RegExp(r'[^\dA-Za-z]'), '');

    final list = availableContacts.where((c) {
      final name = c.safeName.toLowerCase().replaceAll(RegExp(r'\s+'), '');
      final number = c.phones.isNotEmpty
          ? c.phones.first.number.replaceAll(RegExp(r'[^\d]'), '')
          : '';

      return name.contains(clean) || number.contains(clean);
    }).toList();

    filteredContacts.assignAll(list);
    _resetPagination();
  }

  //----------------------------------------------------
  // PAGINATION
  //----------------------------------------------------
  void _resetPagination() {
    final initialCount = _pageSize.clamp(0, filteredContacts.length);
    displayedContacts.assignAll(filteredContacts.take(initialCount).toList());
    hasMoreContacts.value = filteredContacts.length > initialCount;
  }

  Future<void> loadMoreContacts() async {
    if (isLoadingMore.value || !hasMoreContacts.value) {
      refreshController.loadComplete();
      return;
    }

    isLoadingMore.value = true;

    // Simulate slight delay for smooth UX
    await Future.delayed(const Duration(milliseconds: 300));

    final currentCount = displayedContacts.length;
    final nextBatch = filteredContacts
        .skip(currentCount)
        .take(_pageSize)
        .toList();

    displayedContacts.addAll(nextBatch);
    hasMoreContacts.value = displayedContacts.length < filteredContacts.length;

    isLoadingMore.value = false;

    if (hasMoreContacts.value) {
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
  }

  bool _isAlreadyInvited(String phoneNumber) {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    for (final invited in _alreadyInvitedPhones) {
      final invitedSuffix = invited.length > 10
          ? invited.substring(invited.length - 10)
          : invited;
      final phoneSuffix = normalized.length > 10
          ? normalized.substring(normalized.length - 10)
          : normalized;
      if (invitedSuffix == phoneSuffix) {
        return true;
      }
    }
    return false;
  }

  //----------------------------------------------------
  // FETCH PHOTO (Optimized with caching)
  //----------------------------------------------------
  Future<void> fetchPhoto(SafeContact c) async {
    if (c.photo != null && c.photo!.isNotEmpty) return;

    if (_photoCache.containsKey(c.id)) {
      c.photo = _photoCache[c.id];
      return;
    }

    if (_photoFetchingIds.contains(c.id)) return;

    _photoFetchingIds.add(c.id);

    try {
      final full = await FlutterContacts.getContact(c.id, withPhoto: true);

      if (full?.photo != null && full!.photo!.isNotEmpty) {
        c.photo = full.photo;
        _photoCache[c.id] = full.photo;
      } else {
        _photoCache[c.id] = null;
      }

      filteredContacts.refresh();
    } catch (_) {
      _photoCache[c.id] = null;
    } finally {
      _photoFetchingIds.remove(c.id);
    }
  }

  //----------------------------------------------------
  // SEARCH VALIDATION
  //----------------------------------------------------
  void validateSearch(String value) {
    searchError.value = '';
    searchQuery.value = value.trim();
  }

  //----------------------------------------------------
  // USER SELECTION
  //----------------------------------------------------
  void toggleUserSelection(SafeContact c) {
    final exists = selectedUsers.any((x) => x.id == c.id);

    if (exists) {
      selectedUsers.removeWhere((x) => x.id == c.id);
      HapticFeedback.lightImpact();
      return;
    }

    final totalAfterAdd = alreadyInvitedCount + selectedUsers.length + 1;
    if (totalAfterAdd > 4) {
      final remaining = 4 - alreadyInvitedCount - selectedUsers.length;
      if (remaining <= 0) {
        showCustomSnackBar(
          "Limit Reached\nThis event already has $alreadyInvitedCount invited users (max 4).",
          SnackbarState.error,
        );
      } else {
        showCustomSnackBar(
          "Limit Reached\nYou can only invite $remaining more user${remaining == 1 ? '' : 's'}.",
          SnackbarState.error,
        );
      }
      return;
    }

    selectedUsers.add(c);
    HapticFeedback.mediumImpact();
    searchController.clear();
    filteredContacts.clear();
  }

  //----------------------------------------------------
  // REMOVE INVITED USER
  //----------------------------------------------------
  Future<void> removeInvitedUser(Map<String, dynamic> user) async {
    debugPrint("🔍 Remove user data: $user");
    debugPrint("🔍 Event ID: ${eventData.id}");

    if (eventData.id == null) {
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
      return;
    }

    // Backend requires 'inviteId' - must be included in invitedPeople response
    final inviteId = user['inviteId'] ?? user['id'];
    debugPrint("🔍 Invite ID: $inviteId");

    if (inviteId == null) {
      // inviteId is missing from backend response
      Get.back();
      showCustomSnackBar(
        "Cannot remove user: Missing invite ID from server",
        SnackbarState.error,
      );
      return;
    }

    isRemovingUser.value = true;

    try {
      final response = await _apiService.removeInvitedUser(
        eventId: eventData.id!,
        inviteId: inviteId,
      );

      final ok = response["status"] == "success" || response["success"] == true;
      if (ok) {
        Get.back();

        final phone = user['phone']?.toString() ?? '';
        if (phone.isNotEmpty) {
          final normalized = phone.replaceAll(RegExp(r'[^\d]'), '');
          _alreadyInvitedPhones.remove(normalized);
        }
        alreadyInvitedUsers.removeWhere((u) => (u['inviteId'] ?? u['id']) == inviteId);
        eventData.invitedPeople.removeWhere((p) => p is Map && ((p['inviteId'] ?? p['id']) == inviteId));

        HapticFeedback.mediumImpact();
        showCustomSnackBar(AppTexts.USER_REMOVED_SUCCESSFULLY, SnackbarState.success);
      } else {
        Get.back();
        showCustomSnackBar(AppTexts.REMOVE_USER_FAILED, SnackbarState.error);
      }
    } catch (e) {
      Get.back();
      showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
    } finally {
      isRemovingUser.value = false;
    }
  }

  //----------------------------------------------------
  // GET DISPLAY NAME
  //----------------------------------------------------
  String getInvitedUserDisplayName(Map<String, dynamic> user) {
    final name = user['name']?.toString() ?? '';
    if (name.isNotEmpty) return _sanitizeString(name);

    final email = user['email']?.toString() ?? '';
    if (email.isNotEmpty) return _sanitizeString(email);

    final phone = user['phone']?.toString() ?? '';
    if (phone.isNotEmpty) return phone;

    return 'Unknown';
  }

  //----------------------------------------------------
  // FORMAT PHONE WITH COUNTRY CODE
  //----------------------------------------------------
  String _formatPhoneWithCountryCode(String rawPhone) {
    // Remove spaces, dashes, parentheses but keep + and digits
    String cleaned = rawPhone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // If phone already starts with +, it has country code
    if (cleaned.startsWith('+')) {
      // Return digits only but with + prefix
      return '+${cleaned.substring(1).replaceAll(RegExp(r'[^\d]'), '')}';
    }

    // If phone starts with 00, replace with + (international format)
    if (cleaned.startsWith('00')) {
      return '+${cleaned.substring(2).replaceAll(RegExp(r'[^\d]'), '')}';
    }

    // Extract only digits for further processing
    String digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');

    // If number is 10 digits (typical local number), assume India (+91)
    if (digitsOnly.length == 10) {
      return '+91$digitsOnly';
    }

    // If number already has country code (11+ digits starting with country code)
    if (digitsOnly.length > 10) {
      return '+$digitsOnly';
    }

    // Fallback: return as-is with + prefix if we can't determine
    return digitsOnly.isNotEmpty ? '+91$digitsOnly' : digitsOnly;
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
      final invitedList = selectedUsers.map((c) {
        String? formattedPhone;
        if (c.phones.isNotEmpty) {
          formattedPhone = _formatPhoneWithCountryCode(c.phones.first.number);
        }
        return {
          "email": c.emails.isNotEmpty ? c.emails.first.address.trim() : null,
          "phone": formattedPhone,
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
      } else {
        response = await _apiService.inviteUsersToEvent(
          eventId: eventData.id!,
          invitedPeople: invitedList.cast<Map<String, dynamic>>(),
        );
        final ok = response["status"] == "success";
        if (ok) {
          final invitesAdded = response["invitesAdded"] ?? 0;
          final totalSelected = selectedUsers.length;

          if (invitesAdded == 0) {
            showCustomSnackBar(
              AppTexts.USERS_ALREADY_INVITED,
              SnackbarState.warning,
            );
          } else if (invitesAdded < totalSelected) {
            showCustomSnackBar(
              "${AppTexts.SOME_USERS_ALREADY_INVITED} $invitesAdded",
              SnackbarState.success,
            );
            Get.offAll(() => DashboardView());
          } else {
            showCustomSnackBar(
              AppTexts.USERS_INVITED_SUCCESSFULLY,
              SnackbarState.success,
            );
            Get.offAll(() => DashboardView());
          }
        } else {
          showCustomSnackBar(AppTexts.INVITE_FAILED, SnackbarState.error);
        }
      }
    } catch (e) {
      showCustomSnackBar(AppTexts.NO_INTERNET, SnackbarState.error);
    } finally {
      isLoading.value = false;
    }
  }
}