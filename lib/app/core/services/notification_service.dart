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

  void _groupNotificationsByDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    todayNotifications.value = notifications.where((n) {
      final date = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      return date == today;
    }).toList();

    yesterdayNotifications.value = notifications.where((n) {
      final date = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      return date == yesterday;
    }).toList();

    olderNotifications.value = notifications.where((n) {
      final date = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      return date.isBefore(yesterday);
    }).toList();
  }

  void markAsRead(int notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = notifications[index];
      notifications[index] = notification.copyWith(read: true);
      _groupNotificationsByDate();
      _syncBadgeCount();
    }
  }

  void markAllAsRead() {
    notifications.value = notifications.map((n) => n.copyWith(read: true)).toList();
    _groupNotificationsByDate();
    _badgeService.clearBadge();
  }

  Future<void> refresh() async {
    await fetchNotifications();
  }
}

