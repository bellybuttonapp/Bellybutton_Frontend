// ignore_for_file: avoid_print

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
      isLoading.value = true;
      final result = await _apiService.getNotifications();
      notifications.value = result;
      _groupNotificationsByDate();
      _syncBadgeCount();
      print('📬 Fetched ${result.length} notifications');
    } catch (e) {
      print('❌ Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
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
      _groupNotificationsByDate();
      _syncBadgeCount();

      // Call API to persist the change
      try {
        final response = await _apiService.markNotificationAsRead(notificationId);
        print('📬 Mark as read response: $response');
      } catch (e) {
        print('❌ Error marking notification as read: $e');
        // Revert on failure
        notifications[index] = notification;
        _groupNotificationsByDate();
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

