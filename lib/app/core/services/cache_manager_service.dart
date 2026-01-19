// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../constants/app_constant.dart';
import '../utils/storage/preference.dart';

/// Central cache management service for the app
/// Handles image cache limits, cache clearing, and orphaned cache cleanup
class CacheManagerService extends GetxService {
  static CacheManagerService get to => Get.find<CacheManagerService>();

  /// Custom cache manager with app-specific limits
  late final CacheManager _imageCacheManager;

  /// Initialize the cache manager
  Future<CacheManagerService> init() async {
    _imageCacheManager = CacheManager(
      Config(
        'bellybutton_image_cache',
        stalePeriod: Duration(hours: AppConstants.CACHE_DURATION_HOURS),
        maxNrOfCacheObjects: 200, // Limit number of cached images
      ),
    );

    print('✅ CacheManagerService initialized');
    return this;
  }

  /// Get the custom image cache manager
  CacheManager get imageCacheManager => _imageCacheManager;

  /// Clear all image cache
  Future<void> clearImageCache() async {
    try {
      await _imageCacheManager.emptyCache();
      // Also clear the default cache manager used by CachedNetworkImage
      await DefaultCacheManager().emptyCache();
      print('🗑️ Image cache cleared');
    } catch (e) {
      print('❌ Error clearing image cache: $e');
    }
  }

  /// Clear all caches (images + local storage)
  Future<void> clearAllCache() async {
    try {
      // Clear image cache
      await clearImageCache();

      // Clear event gallery cache
      clearEventGalleryCache();

      print('🗑️ All cache cleared');
    } catch (e) {
      print('❌ Error clearing all cache: $e');
    }
  }

  /// Clear event-specific gallery cache
  void clearEventGalleryCache() {
    try {
      final box = Preference.box;
      final keysToRemove = <String>[];

      // Find all event-specific cache keys
      for (final key in box.keys) {
        if (key is String) {
          if (key.startsWith('event_sync_done_') ||
              key.startsWith('uploaded_hashes_') ||
              key.startsWith('event_gallery_')) {
            keysToRemove.add(key);
          }
        }
      }

      // Remove them
      for (final key in keysToRemove) {
        box.delete(key);
      }

      print('🗑️ Cleared ${keysToRemove.length} event cache entries');
    } catch (e) {
      print('❌ Error clearing event gallery cache: $e');
    }
  }

  /// Clear cache for a specific event (when event is deleted)
  void clearEventCache(int eventId) {
    try {
      final box = Preference.box;

      // Remove sync status
      box.delete('${Preference.EVENT_SYNC_DONE}_$eventId');

      // Remove uploaded hashes
      box.delete('${Preference.EVENT_UPLOADED_HASHES}_$eventId');

      print('🗑️ Cleared cache for event $eventId');
    } catch (e) {
      print('❌ Error clearing event $eventId cache: $e');
    }
  }

  /// Clean up orphaned cache entries for events that no longer exist
  /// Call this periodically or on app startup
  Future<void> cleanupOrphanedCache(List<int> activeEventIds) async {
    try {
      final box = Preference.box;
      final keysToRemove = <String>[];

      for (final key in box.keys) {
        if (key is String) {
          // Check sync done keys
          if (key.startsWith('event_sync_done_')) {
            final eventIdStr = key.replaceFirst('event_sync_done_', '');
            final eventId = int.tryParse(eventIdStr);
            if (eventId != null && !activeEventIds.contains(eventId)) {
              keysToRemove.add(key);
            }
          }

          // Check uploaded hashes keys
          if (key.startsWith('uploaded_hashes_')) {
            final eventIdStr = key.replaceFirst('uploaded_hashes_', '');
            final eventId = int.tryParse(eventIdStr);
            if (eventId != null && !activeEventIds.contains(eventId)) {
              keysToRemove.add(key);
            }
          }
        }
      }

      // Remove orphaned entries
      for (final key in keysToRemove) {
        box.delete(key);
      }

      if (keysToRemove.isNotEmpty) {
        print('🧹 Cleaned up ${keysToRemove.length} orphaned cache entries');
      }
    } catch (e) {
      print('❌ Error cleaning orphaned cache: $e');
    }
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    final box = Preference.box;
    int syncDoneCount = 0;
    int uploadedHashesCount = 0;
    int otherCount = 0;

    for (final key in box.keys) {
      if (key is String) {
        if (key.startsWith('event_sync_done_')) {
          syncDoneCount++;
        } else if (key.startsWith('uploaded_hashes_')) {
          uploadedHashesCount++;
        } else {
          otherCount++;
        }
      }
    }

    return {
      'totalKeys': box.keys.length,
      'syncDoneEntries': syncDoneCount,
      'uploadedHashesEntries': uploadedHashesCount,
      'otherEntries': otherCount,
    };
  }

  /// Log cache statistics (for debugging)
  void logCacheStats() {
    if (kDebugMode) {
      final stats = getCacheStats();
      print('📊 Cache Stats: $stats');
    }
  }
}
