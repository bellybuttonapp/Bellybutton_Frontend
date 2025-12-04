import 'package:get/get.dart';

import '../controllers/event_invitations_controller.dart';

class EventInvitationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventInvitationsController>(
      () => EventInvitationsController(),
    );
  }
}
