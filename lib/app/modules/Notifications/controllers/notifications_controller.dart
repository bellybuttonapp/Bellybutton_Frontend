// ignore_for_file: unnecessary_overrides, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../../core/services/notification_service.dart';
import '../../../database/models/NotificationModel.dart';

class NotificationsController extends GetxController {
  // Access the shared notification service
  NotificationService get _service => NotificationService.to;

  // ScrollController for the notification list
  final ScrollController scrollController = ScrollController();

  // RefreshController for SmartRefresher
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  // Expose data from the shared service
  RxBool get isLoading => _service.isLoading;
  RxList<NotificationModel> get notifications => _service.notifications;
  RxList<NotificationModel> get todayNotifications => _service.todayNotifications;
  RxList<NotificationModel> get yesterdayNotifications => _service.yesterdayNotifications;
  RxList<NotificationModel> get olderNotifications => _service.olderNotifications;

  bool get hasNotifications => _service.hasNotifications;
  int get unreadCount => _service.unreadCount;

  @override
  void onInit() {
    super.onInit();
    // Refresh notifications when entering the view
    _service.fetchNotifications().then((_) {
      // Mark all notifications as read when user enters the view
      _service.markAllAsRead();
    });
  }

  void goToBack() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 200));
      Get.back();
      print('Button tapped, proceed to next step');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await _service.refresh();
    refreshController.refreshCompleted();
  }

  @override
  void onClose() {
    scrollController.dispose();
    refreshController.dispose();
    super.onClose();
  }
}