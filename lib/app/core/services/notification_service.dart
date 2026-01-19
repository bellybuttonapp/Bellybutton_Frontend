// ignore_for_file: avoid_print

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../../api/PublicApiService.dart';
import '../../database/models/NotificationModel.dart';
import 'app_badge_service.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final PublicApiService _apiService = PublicApiService();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;

  // Grouped notifications by date
  final todayNotifications = <NotificationModel>[].obs;
  final yesterdayNotifications = <NotificationModel>[].obs;
  final olderNotifications = <NotificationModel>[].obs;

  // Pagination state
  static const int _pageSize = 10;
  final displayedNotifications = <NotificationModel>[].obs;
  final displayedTodayNotifications = <NotificationModel>[].obs;
  final displayedYesterdayNotifications = <NotificationModel>[].obs;
  final displayedOlderNotifications = <NotificationModel>[].obs;
  final isLoadingMore = false.obs;
  final hasMoreNotifications = true.obs;

  int get unreadCount => notifications.where((n) => !n.read).length;
  bool get hasNotifications => notifications.isNotEmpty;

  // Badge service reference
  AppBadgeService get _badgeService => AppBadgeService.to;

  Future<NotificationService> init() async {
    await fetchNotifications();
    return this;
  }

  Future<void> fetchNotifications() async {
    try {
      // Use post-frame callback to safely update loading state
      // This prevents setState during build errors
      _safeSetLoading(true);
      final result = await _apiService.getNotifications();
      notifications.value = result;
      _groupNotificationsByDate();
      _resetPagination();
      _syncBadgeCount();
      print('📬 Fetched ${result.length} notifications');
    } catch (e) {
      print('❌ Error fetching notifications: $e');
    } finally {
      _safeSetLoading(false);
    }
  }

  /// Safely set loading state, avoiding setState during build
  void _safeSetLoading(bool value) {
    // Check if we're in a build phase by using SchedulerBinding
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      // We're during build, defer the state change
      SchedulerBinding.instance.addPostFrameCallback((_) {
        isLoading.value = value;
      });
    } else {
      // Safe to update immediately
      isLoading.value = value;
    }
  }

  // ============================================================
  // 📄 PAGINATION
  // ============================================================
  void _resetPagination() {
    final initialCount = _pageSize.clamp(0, notifications.length);
    displayedNotifications.assignAll(notifications.take(initialCount).toList());
    _updateDisplayedGroups();
    hasMoreNotifications.value = notifications.length > initialCount;

    print('📄 Pagination Reset:');
    print('   - Total: ${notifications.length}');
    print('   - Displayed: ${displayedNotifications.length}');
    print('   - Today: ${displayedTodayNotifications.length}');
    print('   - Yesterday: ${displayedYesterdayNotifications.length}');
    print('   - Older: ${displayedOlderNotifications.length}');
    print('   - Has More: ${hasMoreNotifications.value}');
  }

  void _updateDisplayedGroups() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    displayedTodayNotifications.value = displayedNotifications.where((n) {
      final localDate = n.localCreatedAt;
      final date = DateTime(localDate.year, localDate.month, localDate.day);
      return date == today;
    }).toList();

    displayedYesterdayNotifications.value = displayedNotifications.where((n) {
      final localDate = n.localCreatedAt;
      final date = DateTime(localDate.year, localDate.month, localDate.day);
      return date == yesterday;
    }).toList();

    displayedOlderNotifications.value = displayedNotifications.where((n) {
      final localDate = n.localCreatedAt;
      final date = DateTime(localDate.year, localDate.month, localDate.day);
      return date.isBefore(yesterday);
    }).toList();
  }

  Future<void> loadMoreNotifications() async {
    print('📄 Load More Called - isLoading: ${isLoadingMore.value}, hasMore: ${hasMoreNotifications.value}');

    if (isLoadingMore.value || !hasMoreNotifications.value) {
      print('📄 Load More Skipped');
      return;
    }

    isLoadingMore.value = true;

    // Simulate slight delay for smooth UX
    await Future.delayed(const Duration(milliseconds: 300));

    final currentCount = displayedNotifications.length;
    final nextBatch = notifications
        .skip(currentCount)
        .take(_pageSize)
        .toList();

    print('📄 Loading ${nextBatch.length} more notifications (from $currentCount)');

    displayedNotifications.addAll(nextBatch);
    _updateDisplayedGroups();
    hasMoreNotifications.value = displayedNotifications.length < notifications.length;

    print('📄 After Load More:');
    print('   - Displayed: ${displayedNotifications.length}');
    print('   - Today: ${displayedTodayNotifications.length}');
    print('   - Yesterday: ${displayedYesterdayNotifications.length}');
    print('   - Older: ${displayedOlderNotifications.length}');
    print('   - Has More: ${hasMoreNotifications.value}');

    isLoadingMore.value = false;
  }

  /// Sync app icon badge with unread notification count
  void _syncBadgeCount() {
    _badgeService.updateBadge(unreadCount);
  }

  /// Groups notifications by date using LOCAL timezone
  /// This ensures "Today" and "Yesterday" are accurate for the user's timezone
  void _groupNotificationsByDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Use localCreatedAt for proper timezone-aware date grouping
    todayNotifications.value = notifications.where((n) {
      final localDate = n.localCreatedAt;
      final date = DateTime(localDate.year, localDate.month, localDate.day);
      return date == today;
    }).toList();

    yesterdayNotifications.value = notifications.where((n) {
      final localDate = n.localCreatedAt;
      final date = DateTime(localDate.year, localDate.month, localDate.day);
      return date == yesterday;
    }).toList();

    olderNotifications.value = notifications.where((n) {
      final localDate = n.localCreatedAt;
      final date = DateTime(localDate.year, localDate.month, localDate.day);
      return date.isBefore(yesterday);
    }).toList();
  }

  Future<void> markAsRead(int notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      // Optimistically update UI
      final notification = notifications[index];
      notifications[index] = notification.copyWith(read: true);

      // Also update displayed notifications
      final displayedIndex = displayedNotifications.indexWhere((n) => n.id == notificationId);
      if (displayedIndex != -1) {
        displayedNotifications[displayedIndex] = displayedNotifications[displayedIndex].copyWith(read: true);
      }

      _groupNotificationsByDate();
      _updateDisplayedGroups();
      _syncBadgeCount();

      // Call API to persist the change
      try {
        final response = await _apiService.markNotificationAsRead(notificationId);
        print('📬 Mark as read response: $response');
      } catch (e) {
        print('❌ Error marking notification as read: $e');
        // Revert on failure
        notifications[index] = notification;
        if (displayedIndex != -1) {
          displayedNotifications[displayedIndex] = notification;
        }
        _groupNotificationsByDate();
        _updateDisplayedGroups();
        _syncBadgeCount();
      }
    }
  }

  /// Mark all unread notifications as read (calls API for each)
  Future<void> markAllAsRead() async {
    final unreadNotifications = notifications.where((n) => !n.read).toList();

    if (unreadNotifications.isEmpty) return;

    // Optimistically update UI first
    notifications.value = notifications.map((n) => n.copyWith(read: true)).toList();
    _groupNotificationsByDate();
    _badgeService.clearBadge();

    // Call API for each unread notification
    for (final notification in unreadNotifications) {
      try {
        await _apiService.markNotificationAsRead(notification.id);
        print('📬 Marked notification ${notification.id} as read');
      } catch (e) {
        print('❌ Error marking notification ${notification.id} as read: $e');
      }
    }
  }

  Future<void> refresh() async {
    await fetchNotifications();
  }
}

