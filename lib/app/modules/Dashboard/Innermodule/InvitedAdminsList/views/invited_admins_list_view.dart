import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/MembersListWidget/MembersListWidget.dart';
import '../../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../controllers/invited_admins_list_controller.dart';

class InvitedAdminsListView extends GetView<InvitedAdminsListController> {
  const InvitedAdminsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: AppTexts.INVITED_ADMINS_LIST,
      ), // Same styling
      body: MembersListWidget(controller: controller), // ⭐ Reusable widget
    );
  }
}
