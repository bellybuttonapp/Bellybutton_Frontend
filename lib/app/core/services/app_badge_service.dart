// ignore_for_file: avoid_print

import 'package:get/get.dart';

/// Service to manage app icon badge count across iOS and Android
/// NOTE: Badge functionality temporarily disabled due to flutter_app_badger AGP 8.0+ incompatibility
class AppBadgeService extends GetxService {
  static AppBadgeService get to => Get.find<AppBadgeService>();

  final _badgeCount = 0.obs;
  int get badgeCount => _badgeCount.value;
  bool _isSupported = false;

  Future<AppBadgeService> init() async {
    // Badge functionality disabled - package incompatible with AGP 8.0+
    _isSupported = false;
    print('🔔 AppBadgeService initialized (supported: $_isSupported)');
    return this;
  }

  /// Update the app icon badge count
  Future<void> updateBadge(int count) async {
    if (!_isSupported) return;
    _badgeCount.value = count;
    print('🔔 Badge updated to: $count');
  }

  /// Clear the app icon badge
  Future<void> clearBadge() async {
    if (!_isSupported) return;
    _badgeCount.value = 0;
    print('🔔 Badge cleared');
  }

  /// Increment badge count by a given value
  Future<void> incrementBadge([int by = 1]) async {
    await updateBadge(_badgeCount.value + by);
  }

  /// Decrement badge count by a given value
  Future<void> decrementBadge([int by = 1]) async {
    final newCount = (_badgeCount.value - by).clamp(0, 999);
    await updateBadge(newCount);
  }
}