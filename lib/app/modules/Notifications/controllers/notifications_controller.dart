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
  RxList<NotificationModel> get todayNotifications => _service.displayedTodayNotifications;
  RxList<NotificationModel> get yesterdayNotifications => _service.displayedYesterdayNotifications;
  RxList<NotificationModel> get olderNotifications => _service.displayedOlderNotifications;

  // Pagination state
  RxBool get isLoadingMore => _service.isLoadingMore;
  RxBool get hasMoreNotifications => _service.hasMoreNotifications;

  bool get hasNotifications => _service.hasNotifications;
  int get unreadCount => _service.unreadCount;

  // Load more notifications for pagination
  Future<void> loadMoreNotifications() async {
    await _service.loadMoreNotifications();
    if (_service.hasMoreNotifications.value) {
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Defer fetch to avoid setState during build
    Future.microtask(() => _service.fetchNotifications());

    // Add scroll listener for pagination (backup for SmartRefresher)
    scrollController.addListener(_onScroll);
  }

  /// Trigger load more when user scrolls near bottom
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      // Near bottom, load more
      if (!isLoadingMore.value && hasMoreNotifications.value) {
        print('📄 Scroll triggered load more');
        loadMoreNotifications();
      }
    }
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

  /// Handle notification tap - just mark as read
  void onNotificationTap(NotificationModel notification) {
    // Mark notification as read when tapped
    if (!notification.read) {
      _service.markAsRead(notification.id);
      print('🔔 Marked notification ${notification.id} as read');
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
