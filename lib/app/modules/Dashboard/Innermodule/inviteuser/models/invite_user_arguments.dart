// ignore_for_file: file_names

import 'package:bellybutton/app/database/models/EventModel.dart';

/// Arguments model for InviteUserView navigation
/// Provides type-safe argument passing between screens
class InviteUserArguments {
  /// The event being created or updated
  final EventModel event;

  /// Whether this is an update flow (true) or create flow (false)
  final bool isUpdate;

  /// Whether to show a success notification after navigation
  final bool showNotification;

  /// Whether this is a reinvite flow from gallery (true) or update after event edit (false)
  final bool isReinvite;

  InviteUserArguments({
    required this.event,
    this.isUpdate = false,
    this.showNotification = false,
    this.isReinvite = false,
  });

  /// Factory for creating new event flow
  factory InviteUserArguments.create(EventModel event) {
    return InviteUserArguments(
      event: event,
      isUpdate: false,
      showNotification: false,
      isReinvite: false,
    );
  }

  /// Factory for updating existing event flow (after editing event details)
  factory InviteUserArguments.update(EventModel event, {bool showNotification = true}) {
    return InviteUserArguments(
      event: event,
      isUpdate: true,
      showNotification: showNotification,
      isReinvite: false,
    );
  }

  /// Factory for reinviting crew from gallery
  factory InviteUserArguments.reinvite(EventModel event) {
    return InviteUserArguments(
      event: event,
      isUpdate: true,
      showNotification: false,
      isReinvite: true,
    );
  }
}
