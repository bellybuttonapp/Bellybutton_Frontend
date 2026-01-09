import 'package:get/get.dart';

import '../../../core/services/app_badge_service.dart';
import '../../../core/services/event_invitations_service.dart';
import '../../../core/services/notification_service.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AppBadgeService is registered before other services
    if (!Get.isRegistered<AppBadgeService>()) {
      Get.put(AppBadgeService(), permanent: true);
    }

    // Ensure NotificationService is registered before Dashboard loads
    if (!Get.isRegistered<NotificationService>()) {
      Get.put(NotificationService(), permanent: true);
    }

    // Ensure EventInvitationsService is registered before Dashboard loads
    if (!Get.isRegistered<EventInvitationsService>()) {
      Get.put(EventInvitationsService(), permanent: true);
    }

    Get.lazyPut<DashboardController>(
      () => DashboardController(),
    );
  }
}