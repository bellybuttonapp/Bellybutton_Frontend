// ignore_for_file: prefer_is_empty, avoid_print

import 'dart:ui' as ui;
import 'package:bellybutton/app/api/PublicApiService.dart';
import 'package:bellybutton/app/modules/Dashboard/views/dashboard_view.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/local_notification_service.dart';
import '../../Past_Event/controllers/past_event_controller.dart';
import '../../Upcomming_Event/controllers/upcomming_event_controller.dart';
import '../../../../../global_widgets/CustomSnackbar/CustomSnackbar.dart';
import '../../../../../global_widgets/CustomPopup/CustomPopup.dart';
import '../../../../../database/models/EventModel.dart';
import '../models/invite_user_arguments.dart';
import '../../../../../routes/app_pages.dart';
import 'package:intl/intl.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

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
  final Set<String> _alreadyInvitedEmails = {};

  // Flow context - tracks whether this is update or create flow
  final isUpdateFlow = false.obs;

  // Flow context - tracks whether this is reinvite from gallery
  final isReinviteFlow = false.obs;

  // Flag to show notification after successful invite (update flow only)
  bool showUpdateNotification = false;

  //----------------------------------------------------
  // LIFECYCLE
  //----------------------------------------------------
  @override
  void onInit() {
    super.onInit();

    // Handle new InviteUserArguments model (type-safe) with backward compatibility
    if (Get.arguments is InviteUserArguments) {
      // ✅ NEW: Type-safe arguments model
      final args = Get.arguments as InviteUserArguments;
      eventData = args.event;
      isUpdateFlow.value = args.isUpdate;
      isReinviteFlow.value = args.isReinvite;
      showUpdateNotification = args.showNotification;
    } else if (Get.arguments is EventModel) {
      // 🔄 LEGACY: Direct EventModel (create flow)
      eventData = Get.arguments as EventModel;
      isUpdateFlow.value = false;
    } else if (Get.arguments is Map<String, dynamic>) {
      // 🔄 LEGACY: Map format (update flow)
      final args = Get.arguments as Map<String, dynamic>;
      if (args['event'] is EventModel) {
        eventData = args['event'] as EventModel;
        isUpdateFlow.value = true;
        showUpdateNotification = args['showUpdateNotification'] == true;
      } else {
        Get.back();
        showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
        return;
      }
    } else {
      Get.back();
      showCustomSnackBar(AppTexts.SOMETHING_WENT_WRONG, SnackbarState.error);
      return;
    }

    _loadAlreadyInvitedUsers();
    _extractAlreadyInvitedPhones();

    searchController.addListener(_onSearchChanged);
    fetchContacts();
  }

  /// Show local notification for event update (called after navigation)
  void _showEventUpdatedNotification() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Show event details with local time in notification
      final localStartTime = eventData.getLocalStartTimeString();
      final localDate = eventData.getLocalDateString();

      await LocalNotificationService.show(
        title: AppTexts.NOTIFY_SHOOT_UPDATED_TITLE,
        body: "📅 $localDate at $localStartTime\n${eventData.title}",
      );
    });
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

    // Debug: Check what data we're receiving
    print("📋 Loading invited users from eventData");
    print("📋 Event ID: ${eventData.id}");
    print("📋 Event Title: ${eventData.title}");
    print("📋 InvitedPeople length: ${eventData.invitedPeople.length}");
    print("📋 InvitedPeople data: ${eventData.invitedPeople}");

    for (final person in eventData.invitedPeople) {
      if (person is Map) {
        final role = person['role']?.toString().toUpperCase() ?? '';
        final status = person['status']?.toString().toUpperCase() ?? '';

        // 🎯 CAMERA CREW FILTER:
        // Show ALL invited users (PENDING + ACCEPTED), but exclude Admin
        // Admin is the creator, not an invitee
        if (role != 'ADMIN') {
          alreadyInvitedUsers.add(Map<String, dynamic>.from(person));
          print("✅ Added invited user to Camera Crew: ${person['name']} (status: $status)");
        } else {
          print("⏭️ Skipped Admin: ${person['name']}");
        }
      }
    }

    print("📋 Final Camera Crew (all invited users): ${alreadyInvitedUsers.length}");
  }

  void _extractAlreadyInvitedPhones() {
    _alreadyInvitedPhones.clear();
    _alreadyInvitedEmails.clear();

    for (final person in eventData.invitedPeople) {
      if (person is Map) {
        print("🔍 Extracting phone/email from: $person");

        // Extract phone
        final phone = person['phone']?.toString() ?? '';
        print("🔍 Phone extracted: '$phone'");
        if (phone.isNotEmpty) {
          final normalized = phone.replaceAll(RegExp(r'[^\d]'), '');
          if (normalized.isNotEmpty) {
            _alreadyInvitedPhones.add(normalized);
            print("✅ Added phone to filter: $normalized");
          }
        }

        // Extract email (for admin who has email but no phone)
        final email = person['email']?.toString().toLowerCase().trim() ?? '';
        print("🔍 Email extracted: '$email'");
        if (email.isNotEmpty) {
          _alreadyInvitedEmails.add(email);
          print("✅ Added email to filter: $email");
        }

        if (phone.isEmpty && email.isEmpty) {
          print("⚠️ No phone or email found for: ${person['name'] ?? 'Unknown'}");
        }
      }
    }
    print("📋 Total phones to filter: ${_alreadyInvitedPhones.length}");
    print("📋 Phones: $_alreadyInvitedPhones");
    print("📋 Total emails to filter: ${_alreadyInvitedEmails.length}");
    print("📋 Emails: $_alreadyInvitedEmails");
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

    // Filter out already invited contacts (by phone or email)
    final availableContacts = contacts.where((c) {
      // Check phone
      final number = c.phones.isNotEmpty
          ? c.phones.first.number.replaceAll(RegExp(r'[^\d]'), '')
          : '';
      if (number.isNotEmpty && _isAlreadyInvited(number)) {
        return false;
      }

      // Check email
      final email = c.emails.isNotEmpty
          ? c.emails.first.address.toLowerCase().trim()
          : '';
      if (email.isNotEmpty && _isEmailAlreadyInvited(email)) {
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

  bool _isEmailAlreadyInvited(String email) {
    final normalized = email.toLowerCase().trim();
    return _alreadyInvitedEmails.contains(normalized);
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
  // FORMAT PHONE WITH COUNTRY CODE (Global Support)
  //----------------------------------------------------

  /// Cache for device's default country to avoid repeated lookups
  Country? _deviceCountry;

  /// Timezone to country mapping for global detection
  /// Maps IANA timezone names to country codes (more reliable than abbreviations)
  /// Note: Abbreviations like IST, CST, BST are ambiguous (used by multiple countries)
  static const Map<String, String> _timezoneToCountry = {
    // Asia
    'Asia/Kolkata': 'IN',
    'Asia/Colombo': 'LK',
    'Asia/Kathmandu': 'NP',
    'Asia/Dhaka': 'BD',
    'Asia/Karachi': 'PK',
    'Asia/Dubai': 'AE',
    'Asia/Tehran': 'IR',
    'Asia/Kabul': 'AF',
    'Asia/Yangon': 'MM',
    'Asia/Bangkok': 'TH',
    'Asia/Jakarta': 'ID',
    'Asia/Singapore': 'SG',
    'Asia/Kuala_Lumpur': 'MY',
    'Asia/Manila': 'PH',
    'Asia/Hong_Kong': 'HK',
    'Asia/Shanghai': 'CN',
    'Asia/Tokyo': 'JP',
    'Asia/Seoul': 'KR',
    'Asia/Taipei': 'TW',
    'Asia/Ho_Chi_Minh': 'VN',
    'Asia/Jerusalem': 'IL',
    'Asia/Riyadh': 'SA',
    'Asia/Qatar': 'QA',
    'Asia/Kuwait': 'KW',

    // Europe
    'Europe/London': 'GB',
    'Europe/Paris': 'FR',
    'Europe/Berlin': 'DE',
    'Europe/Rome': 'IT',
    'Europe/Madrid': 'ES',
    'Europe/Amsterdam': 'NL',
    'Europe/Brussels': 'BE',
    'Europe/Vienna': 'AT',
    'Europe/Zurich': 'CH',
    'Europe/Stockholm': 'SE',
    'Europe/Oslo': 'NO',
    'Europe/Copenhagen': 'DK',
    'Europe/Helsinki': 'FI',
    'Europe/Warsaw': 'PL',
    'Europe/Prague': 'CZ',
    'Europe/Athens': 'GR',
    'Europe/Istanbul': 'TR',
    'Europe/Moscow': 'RU',
    'Europe/Dublin': 'IE',
    'Europe/Lisbon': 'PT',

    // Americas
    'America/New_York': 'US',
    'America/Los_Angeles': 'US',
    'America/Chicago': 'US',
    'America/Denver': 'US',
    'America/Toronto': 'CA',
    'America/Vancouver': 'CA',
    'America/Mexico_City': 'MX',
    'America/Sao_Paulo': 'BR',
    'America/Buenos_Aires': 'AR',
    'America/Lima': 'PE',
    'America/Bogota': 'CO',
    'America/Santiago': 'CL',

    // Oceania
    'Australia/Sydney': 'AU',
    'Australia/Melbourne': 'AU',
    'Australia/Perth': 'AU',
    'Pacific/Auckland': 'NZ',

    // Africa
    'Africa/Cairo': 'EG',
    'Africa/Lagos': 'NG',
    'Africa/Johannesburg': 'ZA',
    'Africa/Nairobi': 'KE',
    'Africa/Casablanca': 'MA',

    // Unique timezone abbreviations (only those that are unambiguous)
    'JST': 'JP',    // Japan Standard Time
    'KST': 'KR',    // Korea Standard Time
    'NPT': 'NP',    // Nepal Time
    'AFT': 'AF',    // Afghanistan Time
    'IRST': 'IR',   // Iran Standard Time
    'PKT': 'PK',    // Pakistan Time
    'MSK': 'RU',    // Moscow Time
    'AEST': 'AU',   // Australian Eastern Standard Time
    'AEDT': 'AU',   // Australian Eastern Daylight Time
    'NZST': 'NZ',   // New Zealand Standard Time
    'NZDT': 'NZ',   // New Zealand Daylight Time
  };

  /// Unique timezone offsets that identify specific countries
  /// Only includes offsets that are unique to one country/region
  static const Map<int, String> _uniqueOffsetToCountry = {
    330: 'IN',   // UTC+5:30 - India (Sri Lanka also uses this but India is more common)
    345: 'NP',   // UTC+5:45 - Nepal (unique)
    210: 'IR',   // UTC+3:30 - Iran (unique)
    270: 'AF',   // UTC+4:30 - Afghanistan (unique)
    390: 'MM',   // UTC+6:30 - Myanmar (unique)
    525: 'AU',   // UTC+8:45 - Australia (Eucla) - rare
    570: 'AU',   // UTC+9:30 - Australia (Central)
    -210: 'CA',  // UTC-3:30 - Newfoundland, Canada (unique)
  };

  /// Get the device's country based on multiple detection methods (Global Support)
  /// Priority: 1. All system locales → 2. Timezone name → 3. Unique timezone offset → 4. Primary locale → 5. Fallback
  Country _getDeviceCountry() {
    if (_deviceCountry != null) return _deviceCountry!;

    try {
      final platformDispatcher = ui.PlatformDispatcher.instance;
      String? detectedCountryCode;

      // ═══════════════════════════════════════════════════════════════
      // METHOD 1: Check all system locales for country hints
      // User might have added regional languages (e.g., Hindi for India)
      // ═══════════════════════════════════════════════════════════════
      for (final locale in platformDispatcher.locales) {
        final code = locale.countryCode;
        if (code != null && code.isNotEmpty && code != 'US') {
          // Prefer non-US country codes (US is often default)
          detectedCountryCode = code;
          debugPrint('🌍 [Method 1] Found country from locales: $detectedCountryCode');
          break;
        }
      }

      // ═══════════════════════════════════════════════════════════════
      // METHOD 2: Detect from timezone NAME (most reliable for many countries)
      // Works globally using IANA timezone database
      // ═══════════════════════════════════════════════════════════════
      if (detectedCountryCode == null) {
        final timezoneName = DateTime.now().timeZoneName;
        debugPrint('🕐 [Method 2] Timezone name: $timezoneName');

        // Direct timezone name lookup
        if (_timezoneToCountry.containsKey(timezoneName)) {
          detectedCountryCode = _timezoneToCountry[timezoneName];
          debugPrint('🌍 [Method 2] Detected country from timezone name: $detectedCountryCode');
        }
      }

      // ═══════════════════════════════════════════════════════════════
      // METHOD 3: Detect from UNIQUE timezone offsets
      // Only works for countries with unique offsets (India, Nepal, Iran, etc.)
      // ═══════════════════════════════════════════════════════════════
      if (detectedCountryCode == null) {
        final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
        debugPrint('🕐 [Method 3] Timezone offset: $offsetMinutes minutes');

        if (_uniqueOffsetToCountry.containsKey(offsetMinutes)) {
          detectedCountryCode = _uniqueOffsetToCountry[offsetMinutes];
          debugPrint('🌍 [Method 3] Detected country from unique offset: $detectedCountryCode');
        }
      }

      // ═══════════════════════════════════════════════════════════════
      // METHOD 4: Fallback to primary locale
      // ═══════════════════════════════════════════════════════════════
      if (detectedCountryCode == null) {
        final primaryLocale = platformDispatcher.locale;
        detectedCountryCode = primaryLocale.countryCode;
        debugPrint('🌍 [Method 4] Primary locale: ${primaryLocale.languageCode}_$detectedCountryCode');
      }

      // ═══════════════════════════════════════════════════════════════
      // FINAL FALLBACK
      // ═══════════════════════════════════════════════════════════════
      detectedCountryCode ??= 'US';
      debugPrint('🌍 Final detected country: $detectedCountryCode');

      // Find country from country_picker library
      final countries = CountryService().getAll();
      _deviceCountry = countries.firstWhere(
        (c) => c.countryCode.toUpperCase() == detectedCountryCode!.toUpperCase(),
        orElse: () => Country.parse('US'),
      );

      debugPrint('📱 Using phone code: +${_deviceCountry!.phoneCode} (${_deviceCountry!.name})');
    } catch (e) {
      debugPrint('❌ Error detecting device country: $e');
      _deviceCountry = Country.parse('US');
    }

    return _deviceCountry!;
  }

  /// Format phone number with appropriate country code using Google's libphonenumber
  /// This provides 99.9% accuracy for phone number parsing and validation
  String _formatPhoneWithCountryCode(String rawPhone) {
    debugPrint('📞 [Format] Raw input: "$rawPhone"');

    // Clean the phone number - remove spaces, dashes, parentheses
    String cleaned = rawPhone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    debugPrint('📞 [Format] After cleaning: "$cleaned"');

    // If phone already starts with +, validate and return
    if (cleaned.startsWith('+')) {
      final digits = cleaned.substring(1).replaceAll(RegExp(r'[^\d]'), '');
      if (digits.isNotEmpty) {
        debugPrint('📞 [Format] ✅ Already has +, returning: +$digits');
        return '+$digits';
      }
    }

    // If phone starts with 00, replace with + (international format)
    if (cleaned.startsWith('00')) {
      final digits = cleaned.substring(2).replaceAll(RegExp(r'[^\d]'), '');
      if (digits.isNotEmpty) {
        debugPrint('📞 [Format] ✅ Starts with 00, returning: +$digits');
        return '+$digits';
      }
    }

    // Extract only digits for processing
    String digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return '';

    debugPrint('📞 [Format] Digits only: $digitsOnly (${digitsOnly.length} digits)');

    // ═══════════════════════════════════════════════════════════════════════
    // CHECK FOR US NUMBER WITH COUNTRY CODE PREFIX (11 digits starting with 1)
    // Example: 17709403445 = +1 (770) 940-3445
    // ═══════════════════════════════════════════════════════════════════════
    if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      final withoutCountryCode = digitsOnly.substring(1); // Remove leading 1
      if (_isValidNanpNumber(withoutCountryCode)) {
        debugPrint('📞 [Format] ✅ US number with country code: +$digitsOnly');
        return '+$digitsOnly';
      }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // CHECK FOR INDIAN NUMBER WITH COUNTRY CODE PREFIX (12 digits starting with 91)
    // Example: 919876543210 = +91 98765 43210
    // ═══════════════════════════════════════════════════════════════════════
    if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      final withoutCountryCode = digitsOnly.substring(2); // Remove leading 91
      if (RegExp(r'^[6-9]\d{9}$').hasMatch(withoutCountryCode)) {
        debugPrint('📞 [Format] ✅ Indian number with country code: +$digitsOnly');
        return '+$digitsOnly';
      }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // Get device country first - needed for smart detection
    // ═══════════════════════════════════════════════════════════════════════
    final deviceCountry = _getDeviceCountry();
    final deviceIsoCode = IsoCode.values.cast<IsoCode?>().firstWhere(
      (iso) => iso?.name.toUpperCase() == deviceCountry.countryCode.toUpperCase(),
      orElse: () => IsoCode.US,
    ) ?? IsoCode.US;

    debugPrint('📞 [Format] Device country: ${deviceCountry.countryCode} ($deviceIsoCode)');

    // ═══════════════════════════════════════════════════════════════════════
    // SMART DETECTION FOR US/INDIA AMBIGUITY
    // Problem: 10-digit numbers starting with 6-9 are valid for BOTH countries
    // - India: Mobile numbers start with 6, 7, 8, or 9
    // - US: Area codes can be 6xx, 7xx, 8xx, 9xx (e.g., 770, 904, 650, 808)
    //
    // Solution: Check if number has UNIQUE US area codes that DON'T overlap with
    // common Indian mobile prefixes. Area codes 2xx-5xx are ONLY US (not Indian).
    // For 6xx-9xx area codes, trust the device country.
    // ═══════════════════════════════════════════════════════════════════════
    if (digitsOnly.length == 10 && _isValidNanpNumber(digitsOnly)) {
      final areaCode = digitsOnly.substring(0, 3);
      final firstDigit = digitsOnly[0];

      // Area codes starting with 2, 3, 4, 5 are UNIQUE to US/Canada
      // Indian mobiles NEVER start with these digits
      final isUniqueUsAreaCode = RegExp(r'^[2-5]').hasMatch(firstDigit);

      if (isUniqueUsAreaCode) {
        // CLEAR US CASE: Number starts with 2-5, definitely NOT Indian
        debugPrint('📞 [Format] ✅ UNIQUE US area code $areaCode (starts with $firstDigit, not valid for India)');
        final usNumber = _tryParsePhoneNumber(digitsOnly, IsoCode.US);
        if (usNumber != null && usNumber.isValid()) {
          final formatted = usNumber.international.replaceAll(RegExp(r'[^\d+]'), '');
          debugPrint('📞 [Format] ✅ Confirmed as US number: $formatted');
          return formatted;
        }
      } else {
        // AMBIGUOUS: Area code starts with 6-9 (valid for both US and India)
        // Trust the device country
        debugPrint('📞 [Format] ⚠️ Ambiguous: NANP area code $areaCode starts with $firstDigit (valid for both US & India)');
        debugPrint('📞 [Format] → Using device country: ${deviceCountry.countryCode}');
        // Fall through to device country parsing below
      }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // STEP 1: Try parsing with libphonenumber using device's country as hint
    // ═══════════════════════════════════════════════════════════════════════
    debugPrint('📞 [Format] Trying device country hint: ${deviceCountry.countryCode}');

    // Try parsing with device country as default
    PhoneNumber? parsedNumber = _tryParsePhoneNumber(digitsOnly, deviceIsoCode);

    // ═══════════════════════════════════════════════════════════════════════
    // STEP 2: If parsing failed or invalid, try ALL countries (240+)
    // ═══════════════════════════════════════════════════════════════════════
    if (parsedNumber == null || !parsedNumber.isValid()) {
      debugPrint('📞 [Format] Device country parse failed, trying ALL countries...');

      // Try ALL 240+ countries for maximum accuracy
      // IsoCode.values contains every country code in the world
      for (final country in IsoCode.values) {
        if (country == deviceIsoCode) continue; // Already tried

        parsedNumber = _tryParsePhoneNumber(digitsOnly, country);
        if (parsedNumber != null && parsedNumber.isValid()) {
          debugPrint('📞 [Format] ✅ Valid number found for country: ${country.name}');
          break;
        }
      }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // STEP 3: Return the formatted number
    // ═══════════════════════════════════════════════════════════════════════
    if (parsedNumber != null && parsedNumber.isValid()) {
      final international = parsedNumber.international;
      // Remove any non-digit except + from the result
      final formatted = international.replaceAll(RegExp(r'[^\d+]'), '');
      debugPrint('📞 [Format] ✅ libphonenumber result: $formatted');
      return formatted;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // STEP 4: Fallback - use our pattern-based detection
    // ═══════════════════════════════════════════════════════════════════════
    debugPrint('📞 [Format] ⚠️ libphonenumber failed, using pattern fallback');
    final patternCountryCode = _detectCountryFromLocalNumber(digitsOnly);
    if (patternCountryCode != null) {
      debugPrint('📞 [Format] Pattern detected country: +$patternCountryCode');
      return '+$patternCountryCode$digitsOnly';
    }

    // Final fallback: use device country
    debugPrint('📞 [Format] ⚠️ Final fallback to device country: +${deviceCountry.phoneCode}');

    // Validate: Phone number should have minimum length for validity
    final formatted = '+${deviceCountry.phoneCode}$digitsOnly';
    if (digitsOnly.length < 7) {
      debugPrint('📞 [Format] ⚠️ WARNING: Number too short ($digitsOnly), might be invalid');
    }
    if (digitsOnly.length > 15) {
      debugPrint('📞 [Format] ⚠️ WARNING: Number too long ($digitsOnly), might be invalid');
    }

    return formatted;
  }

  /// Try to parse a phone number with a specific country hint
  /// Returns null if parsing fails
  PhoneNumber? _tryParsePhoneNumber(String digits, IsoCode countryHint) {
    try {
      final phone = PhoneNumber.parse(digits, callerCountry: countryHint);
      debugPrint('📞 [Parse] Trying $countryHint: ${phone.international} (valid: ${phone.isValid()})');
      return phone;
    } catch (e) {
      debugPrint('📞 [Parse] Failed for $countryHint: $e');
      return null;
    }
  }

  /// NANP (North American Numbering Plan) area codes - covers US, Canada, Caribbean
  /// These are 3-digit codes that identify geographic regions
  /// Source: https://en.wikipedia.org/wiki/List_of_North_American_Numbering_Plan_area_codes
  static final Set<String> _nanpAreaCodes = {
    // Major US area codes (comprehensive list)
    // Alabama
    '205', '251', '256', '334', '938',
    // Alaska
    '907',
    // Arizona
    '480', '520', '602', '623', '928',
    // Arkansas
    '479', '501', '870',
    // California
    '209', '213', '310', '323', '341', '369', '408', '415', '424', '442',
    '510', '530', '559', '562', '619', '626', '628', '650', '657', '661',
    '669', '707', '714', '747', '760', '805', '818', '831', '858', '909',
    '916', '925', '949', '951',
    // Colorado
    '303', '719', '720', '970',
    // Connecticut
    '203', '475', '860', '959',
    // Delaware
    '302',
    // Florida
    '239', '305', '321', '352', '386', '407', '561', '727', '754', '772',
    '786', '813', '850', '863', '904', '941', '954',
    // Georgia
    '229', '404', '470', '478', '678', '706', '762', '770', '912', '943',
    // Hawaii
    '808',
    // Idaho
    '208', '986',
    // Illinois
    '217', '224', '309', '312', '331', '618', '630', '708', '773', '779',
    '815', '847', '872',
    // Indiana
    '219', '260', '317', '463', '574', '765', '812', '930',
    // Iowa
    '319', '515', '563', '641', '712',
    // Kansas
    '316', '620', '785', '913',
    // Kentucky
    '270', '364', '502', '606', '859',
    // Louisiana
    '225', '318', '337', '504', '985',
    // Maine
    '207',
    // Maryland
    '240', '301', '410', '443', '667',
    // Massachusetts
    '339', '351', '413', '508', '617', '774', '781', '857', '978',
    // Michigan
    '231', '248', '269', '313', '517', '586', '616', '734', '810', '906',
    '947', '989',
    // Minnesota
    '218', '320', '507', '612', '651', '763', '952',
    // Mississippi
    '228', '601', '662', '769',
    // Missouri
    '314', '417', '573', '636', '660', '816',
    // Montana
    '406',
    // Nebraska
    '308', '402', '531',
    // Nevada
    '702', '725', '775',
    // New Hampshire
    '603',
    // New Jersey
    '201', '551', '609', '732', '848', '856', '862', '908', '973',
    // New Mexico
    '505', '575',
    // New York
    '212', '315', '332', '347', '516', '518', '585', '607', '631', '646',
    '680', '716', '718', '838', '845', '914', '917', '929', '934',
    // North Carolina
    '252', '336', '704', '743', '828', '910', '919', '980', '984',
    // North Dakota
    '701',
    // Ohio
    '216', '220', '234', '283', '330', '380', '419', '440', '513', '567',
    '614', '740', '937',
    // Oklahoma
    '405', '539', '580', '918',
    // Oregon
    '458', '503', '541', '971',
    // Pennsylvania
    '215', '223', '267', '272', '412', '445', '484', '570', '582', '610',
    '717', '724', '814', '835', '878',
    // Rhode Island
    '401',
    // South Carolina
    '803', '839', '843', '854', '864',
    // South Dakota
    '605',
    // Tennessee
    '423', '615', '629', '731', '865', '901', '931',
    // Texas
    '210', '214', '254', '281', '325', '346', '361', '409', '430', '432',
    '469', '512', '682', '713', '737', '806', '817', '830', '832', '903',
    '915', '936', '940', '956', '972', '979',
    // Utah
    '385', '435', '801',
    // Vermont
    '802',
    // Virginia
    '276', '434', '540', '571', '703', '757', '804',
    // Washington
    '206', '253', '360', '425', '509', '564',
    // Washington DC
    '202',
    // West Virginia
    '304', '681',
    // Wisconsin
    '262', '414', '534', '608', '715', '920',
    // Wyoming
    '307',
    // Canada
    '204', '226', '236', '249', '250', '289', '306', '343', '365', '367',
    '403', '416', '418', '431', '437', '438', '450', '506', '514', '519',
    '548', '579', '581', '587', '604', '613', '639', '647', '705', '709',
    '778', '780', '782', '807', '819', '825', '867', '873', '902', '905',
  };

  /// Check if a 10-digit number is a valid NANP (US/Canada) number
  /// NANP format: NXX-NXX-XXXX where N=2-9 and X=0-9
  bool _isValidNanpNumber(String digits) {
    if (digits.length != 10) return false;

    final areaCode = digits.substring(0, 3);
    final exchangeCode = digits.substring(3, 6);

    // Area code must start with 2-9 (not 0 or 1)
    if (areaCode[0] == '0' || areaCode[0] == '1') return false;

    // Exchange code must start with 2-9 (not 0 or 1)
    if (exchangeCode[0] == '0' || exchangeCode[0] == '1') return false;

    // Check if it's a known NANP area code
    return _nanpAreaCodes.contains(areaCode);
  }

  //----------------------------------------------------
  // AMBIGUOUS PHONE NUMBER DETECTION
  //----------------------------------------------------

  /// Map to store manually selected country codes for ambiguous contacts
  final Map<String, String> _selectedCountryCodes = {};

  /// Check if a phone number is AMBIGUOUS (valid for both US and India)
  /// Returns true ONLY for 10-digit numbers starting with 6-9 that have valid NANP area codes
  bool isAmbiguousPhoneNumber(String rawPhone) {
    // Clean the phone number
    String digits = rawPhone.replaceAll(RegExp(r'[^\d]'), '');

    // If already has country code indicator, NOT ambiguous
    if (rawPhone.contains('+')) return false;
    if (digits.length == 11 && digits.startsWith('1')) return false; // US with code
    if (digits.length == 12 && digits.startsWith('91')) return false; // India with code

    // Only 10-digit numbers can be ambiguous
    if (digits.length != 10) return false;

    // Must start with 6-9 (valid for India mobile)
    final firstDigit = digits[0];
    if (!RegExp(r'^[6-9]').hasMatch(firstDigit)) return false;

    // Must also be valid NANP (valid for US)
    if (!_isValidNanpNumber(digits)) return false;

    // This number is AMBIGUOUS - valid for both US and India
    debugPrint('📞 [Ambiguous] Number $digits is valid for BOTH US (area ${digits.substring(0, 3)}) and India (mobile starting with $firstDigit)');
    return true;
  }

  /// Store the user's country selection for an ambiguous contact
  void setSelectedCountryCode(String contactId, String countryCode) {
    _selectedCountryCodes[contactId] = countryCode;
    debugPrint('📞 [Manual] Stored country +$countryCode for contact $contactId');
  }

  /// Get stored country code for a contact (if manually selected)
  String? getSelectedCountryCode(String contactId) => _selectedCountryCodes[contactId];

  /// Format phone with manually selected country code
  String formatPhoneWithSelectedCountry(String rawPhone, String countryCode) {
    String digits = rawPhone.replaceAll(RegExp(r'[^\d]'), '');
    return '+$countryCode$digits';
  }

  /// Get formatted phone preview for display
  String getFormattedPhonePreview(String rawPhone, String countryCode) {
    String digits = rawPhone.replaceAll(RegExp(r'[^\d]'), '');
    if (countryCode == '1') {
      // US format: +1 (XXX) XXX-XXXX
      if (digits.length == 10) {
        return '+1 (${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
      }
    } else if (countryCode == '91') {
      // India format: +91 XXXXX XXXXX
      if (digits.length == 10) {
        return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
      }
    }
    return '+$countryCode $digits';
  }

  /// Fallback pattern-based detection for when libphonenumber fails
  /// Returns the phone code (e.g., "91" for India) or null if not detected
  String? _detectCountryFromLocalNumber(String digits) {
    final length = digits.length;

    // ═══════════════════════════════════════════════════════════════
    // CHECK US/CANADA FIRST using comprehensive area code list
    // This catches numbers like 770-940-3445 (Georgia, US)
    // ═══════════════════════════════════════════════════════════════
    if (length == 10 && _isValidNanpNumber(digits)) {
      debugPrint('📞 [Pattern] Detected as US/Canada (NANP area code: ${digits.substring(0, 3)})');
      return '1';
    }

    // INDIA (91): 10 digits, starts with 6, 7, 8, or 9
    // BUT only if not a valid NANP number (already checked above)
    if (length == 10 && RegExp(r'^[6-9]').hasMatch(digits)) {
      return '91';
    }

    // UK (44): 10-11 digits, starts with 0
    if ((length == 10 || length == 11) && digits.startsWith('0')) {
      if (digits.startsWith('07') || digits.startsWith('01') ||
          digits.startsWith('02') || digits.startsWith('03')) {
        return '44';
      }
    }

    // SINGAPORE (65): 8 digits, starts with 8 or 9
    if (length == 8 && RegExp(r'^[89]').hasMatch(digits)) {
      return '65';
    }

    // UAE (971): 9 digits, starts with 5
    if (length == 9 && digits.startsWith('5')) {
      return '971';
    }

    // CHINA (86): 11 digits, starts with 1 (not 01)
    if (length == 11 && digits.startsWith('1') && !digits.startsWith('01')) {
      return '86';
    }

    return null;
  }

  //----------------------------------------------------
  // SHOW UPGRADE REQUIRED POPUP
  //----------------------------------------------------
  final _upgradePopupProcessing = false.obs;

  void _showUpgradeRequiredPopup() {
    Get.dialog(
      barrierDismissible: false,
      CustomPopup(
        title: AppTexts.UPGRADE_REQUIRED_TITLE,
        message: AppTexts.UPGRADE_REQUIRED_MESSAGE,
        confirmText: AppTexts.OK,
        isProcessing: _upgradePopupProcessing,
        barrierDismissible: false,
        confirmButtonColor: AppColors.primaryColor,
        onConfirm: () {
          Get.back(); // Close dialog
          Get.offAllNamed(Routes.DASHBOARD); // Navigate to dashboard
        },
      ),
    );
  }

  //----------------------------------------------------
  // SHOW TIME CONFLICT POPUP
  //----------------------------------------------------
  final _timeConflictPopupProcessing = false.obs;

  void _showTimeConflictPopup() {
    Get.dialog(
      barrierDismissible: false,
      CustomPopup(
        title: AppTexts.TIME_CONFLICT_TITLE,
        message: AppTexts.TIME_CONFLICT_CREATE_MESSAGE,
        confirmText: "OK",
        // cancelText: AppTexts.CANCEL,
        isProcessing: _timeConflictPopupProcessing,
        barrierDismissible: false,
        cancelButtonColor: AppColors.error,
        confirmButtonColor: AppColors.primaryColor,
        onConfirm: () => Get.back(), // Close dialog
      ),
    );
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
          final rawPhone = c.phones.first.number;

          // Check if user manually selected a country code for this contact
          final manualCountryCode = getSelectedCountryCode(c.id);
          if (manualCountryCode != null) {
            // Use manually selected country code
            formattedPhone = formatPhoneWithSelectedCountry(rawPhone, manualCountryCode);
            debugPrint('📞 [Invite] Using manual country +$manualCountryCode for ${c.safeName}: $formattedPhone');
          } else {
            // Use auto-detection
            formattedPhone = _formatPhoneWithCountryCode(rawPhone);
          }
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
          timezone: eventData.timezone,           // Creator's timezone for global support
          timezoneOffset: eventData.timezoneOffset, // Creator's offset for global support
        );

        // Debug: Log the full response
        debugPrint("📦 Create Event Response: $response");

        // ✅ Check for event limit error (400 status with specific message)
        // API service wraps error as: { "success": false, "message": "You can create only 4 events per month", "status": "error" }
        final errorMessage = response["message"]?.toString().toLowerCase() ?? "";
        final isErrorResponse = response["status"] == "error" || response["success"] == false;

        // Check for event limit error
        if (isErrorResponse &&
            response["message"] != null &&
            (errorMessage.contains("can create only") ||
             errorMessage.contains("events per month") ||
             errorMessage.contains("4 events"))) {
          debugPrint("🚫 Event limit reached - showing upgrade popup");
          debugPrint("🚫 Error message: ${response["message"]}");
          _showUpgradeRequiredPopup();
          return;
        }

        // ✅ Check for time conflict error
        // API service wraps error as: { "success": false, "message": "You already have another event at this time", "status": "error" }
        if (isErrorResponse &&
            response["message"] != null &&
            (errorMessage.contains("already have another event") ||
             errorMessage.contains("at this time") ||
             errorMessage.contains("time conflict"))) {
          debugPrint("⏰ Time conflict detected - showing conflict popup");
          debugPrint("⏰ Error message: ${response["message"]}");
          _showTimeConflictPopup();
          return;
        }

        final ok = response?["headers"]?["status"] == "success";
        if (ok) {
          // Show success notification with event details in user's local time
          final localStartTime = eventData.getLocalStartTimeString();
          final localDate = eventData.getLocalDateString();

          showCustomSnackBar(
            "${AppTexts.USERS_INVITED_SUCCESSFULLY}\n📅 $localDate at $localStartTime",
            SnackbarState.success,
          );
          _navigateToDashboardWithRefresh();
        } else {
          // Double-check for event limit error before showing generic error
          final errorMsg = response["message"]?.toString().toLowerCase() ?? "";
          if (errorMsg.contains("can create only") ||
              errorMsg.contains("events per month") ||
              errorMsg.contains("4 events")) {
            debugPrint("🚫 Event limit reached (in else block) - showing upgrade popup");
            _showUpgradeRequiredPopup();
            return;
          }
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
            // Show success notification with event details in user's local time
            final localStartTime = eventData.getLocalStartTimeString();
            final localDate = eventData.getLocalDateString();

            showCustomSnackBar(
              "${AppTexts.SOME_USERS_ALREADY_INVITED} $invitesAdded\n📅 $localDate at $localStartTime",
              SnackbarState.success,
            );
            // Show local notification if this is update flow
            if (showUpdateNotification) {
              _showEventUpdatedNotification();
            }
            _navigateToDashboardWithRefresh();
          } else {
            // Show success notification with event details in user's local time
            final localStartTime = eventData.getLocalStartTimeString();
            final localDate = eventData.getLocalDateString();

            showCustomSnackBar(
              "${AppTexts.USERS_INVITED_SUCCESSFULLY}\n📅 $localDate at $localStartTime",
              SnackbarState.success,
            );
            // Show local notification if this is update flow
            if (showUpdateNotification) {
              
              _showEventUpdatedNotification();
            }
            _navigateToDashboardWithRefresh();
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

  /// Navigate to dashboard with fresh event controllers
  /// Deletes old controllers to ensure fresh data is fetched
  void _navigateToDashboardWithRefresh() {
    // Delete old event controllers if they exist to force fresh data
    if (Get.isRegistered<UpcommingEventController>()) {
      Get.delete<UpcommingEventController>();
    }
    if (Get.isRegistered<PastEventController>()) {
      Get.delete<PastEventController>();
    }
    // Navigate to dashboard - new controllers will fetch fresh data
    Get.offAll(() => DashboardView());
  }
}