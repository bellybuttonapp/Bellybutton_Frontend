import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../../../../database/models/InvitedEventModel.dart';
import '../../../../../database/models/MemberModel.dart';
import '../../../../../api/PublicApiService.dart';

class InvitedAdminsListController extends GetxController {
  late InvitedEventModel event;

  // UI & Search
  final searchController = TextEditingController();
  final searchError = "".obs;

  // Refresh controller for pull-to-refresh
  final refreshController = RefreshController(initialRefresh: false);

  // Data
  final Rx<MemberModel?> adminUser = Rx<MemberModel?>(null);
  final admins = <MemberModel>[].obs;
  final filteredAdmins = <MemberModel>[].obs;

  // UI Loading State
  final isLoading = true.obs;

  // --------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    final data = Get.arguments;

    if (data is InvitedEventModel) {
      event = data;
    } else if (data is Map) {
      event = InvitedEventModel.fromJson(
        Map<String, dynamic>.from(data), // <-- FIX HERE 🔥
      );
    } else {
      throw "❌ Invalid argument passed to InvitedAdminsListController.\nExpected InvitedEventModel or Map<String,dynamic>";
    }

    fetchAdmins(event.eventId);
  }

  // --------------------------------------------------------------
  // 🔥 FETCH ADMIN LIST (API)
  Future<void> fetchAdmins(int eventId) async {
    try {
      isLoading.value = true;

      final response = await PublicApiService().getJoinedAdmins(eventId);

      // Main Admin
      if (response["admin"] != null) {
        adminUser.value = MemberModel.fromJson(response["admin"]);
      }

      // All Admins List
      final adminList = response["admins"] ?? [];
      admins.assignAll(
        adminList.map<MemberModel>((e) => MemberModel.fromJson(e)).toList(),
      );

      // Build Final List (Admin always first)
      filteredAdmins.assignAll([
        if (adminUser.value != null) adminUser.value!,
        ...admins,
      ]);
    } catch (e) {
      Get.snackbar("Error", "Unable to load Admin users");
    } finally {
      isLoading.value = false;
      refreshController.refreshCompleted();
    }
  }

  // --------------------------------------------------------------
  // 🔍 FILTER SEARCH RESULTS
  void validateSearch(String query) {
    final List<MemberModel> combined = [
      if (adminUser.value != null) adminUser.value!,
      ...admins,
    ];

    filteredAdmins.assignAll(
      combined.where((u) => u.name.toLowerCase().contains(query.toLowerCase())),
    );
  }
}
