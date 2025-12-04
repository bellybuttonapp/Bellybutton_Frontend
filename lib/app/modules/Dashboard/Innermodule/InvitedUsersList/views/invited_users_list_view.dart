import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_texts.dart';
import '../../../../../global_widgets/MembersListWidget/MembersListWidget.dart';
import '../../../../../global_widgets/custom_app_bar/custom_app_bar.dart';
import '../controllers/invited_users_list_controller.dart';

class InvitedUsersListView extends GetView<InvitedUsersListController> {
  const InvitedUsersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AppTexts.INVITED_USERS_LIST),
      body: MembersListWidget(controller: controller),
    );
  }
}
