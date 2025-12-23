import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../../../../api/PublicApiService.dart';
import '../../../../../database/models/EventModel.dart';
import '../../../../../database/models/MemberModel.dart';

/// ===============================================================
/// 🔥 Invited Users List Controller (Final Fixed + Stable)
/// ===============================================================
class InvitedUsersListController extends GetxController {
  late EventModel event; // 📌 Event received from navigation

  // ------------------------------------------------------
  // 🔍 SEARCH + UI STATE
  // ------------------------------------------------------
  final searchController = TextEditingController();
  final searchError = "".obs;

  final RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  // ------------------------------------------------------
  // 👥 USER MANAGEMENT
  // ------------------------------------------------------
  final Rx<MemberModel?> adminUser = Rx<MemberModel?>(null); // Event Admin
  final users = <MemberModel>[].obs; // Joined participants
  final filteredUsers = <MemberModel>[].obs; // Search results
  final isLoading = true.obs; // Loader state

  // ------------------------------------------------------
  // 🚀 INIT — RECEIVE ARGUMENT & FETCH USERS
  // ------------------------------------------------------
  @override
  void onInit() {
    super.onInit();

    final data = Get.arguments;

    // 🔥 Accept EventModel or JSON Map
    if (data is EventModel) {
      event = data;
    } else if (data is Map) {
      event = EventModel.fromJson(Map<String, dynamic>.from(data));
    } else {
      throw "❌ Invalid argument passed to InvitedUsersListController";
    }

    // 🔥 FIX → Correct ID field
    if (event.id != null && event.id != 0) {
      fetchJoinedUsers(event.id!); // API Request
    } else {
      Get.snackbar("Error", "Invalid Event ID received");
      isLoading(false);
    }
  }

  // ------------------------------------------------------
  // 🌍 API: GET ADMIN + INVITED USERS
  // ------------------------------------------------------
  Future<void> fetchJoinedUsers(int eventId) async {
    try {
      isLoading(true);

      final response = await PublicApiService().getJoinedUsers(eventId);

      // Main Admin
      if (response["admin"] != null) {
        adminUser.value = MemberModel.fromJson(response["admin"]);
      }

      // Joined Users List
      final list = response["joinedPeople"] ?? [];
      users.assignAll(
        list.map<MemberModel>((e) => MemberModel.fromJson(e)).toList(),
      );

      // Admin always at top 🔥
      filteredUsers.assignAll([
        if (adminUser.value != null) adminUser.value!,
        ...users,
      ]);
    } catch (e) {
      Get.snackbar("Error", "Failed to load invited users");
    } finally {
      isLoading(false);
      refreshController.refreshCompleted();
    }
  }

  // ------------------------------------------------------
  // 🔍 LIVE SEARCH FILTER
  // ------------------------------------------------------
  void validateSearch(String query) {
    final List<MemberModel> all = [
      if (adminUser.value != null) adminUser.value!,
      ...users,
    ];

    filteredUsers.assignAll(
      all.where((u) => u.name.toLowerCase().contains(query.toLowerCase())),
    );
  }
}
