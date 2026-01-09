// ignore_for_file: file_names

import 'EventModel.dart';
import 'InvitedEventModel.dart';

/// Enum to identify the type of event
enum EventType { owned, invited }

/// Unified wrapper to hold either an EventModel (owned) or InvitedEventModel (invited)
/// This allows mixing both types in a single sorted list
class UnifiedEventModel {
  final EventType type;
  final EventModel? ownedEvent;
  final InvitedEventModel? invitedEvent;

  UnifiedEventModel._({
    required this.type,
    this.ownedEvent,
    this.invitedEvent,
  });

  /// Create from an owned event
  factory UnifiedEventModel.fromOwned(EventModel event) {
    return UnifiedEventModel._(
      type: EventType.owned,
      ownedEvent: event,
    );
  }

  /// Create from an invited event
  factory UnifiedEventModel.fromInvited(InvitedEventModel event) {
    return UnifiedEventModel._(
      type: EventType.invited,
      invitedEvent: event,
    );
  }

  /// Check if this is an owned event
  bool get isOwned => type == EventType.owned;

  /// Check if this is an invited event
  bool get isInvited => type == EventType.invited;

  /// Get the local start DateTime for sorting
  DateTime get localStartDateTime {
    if (isOwned) {
      return ownedEvent!.localStartDateTime;
    } else {
      return invitedEvent!.localStartDateTime;
    }
  }

  /// Get the local end DateTime for sorting
  DateTime get localEndDateTime {
    if (isOwned) {
      return ownedEvent!.localEndDateTime;
    } else {
      return invitedEvent!.localEndDateTime;
    }
  }

  /// Get the title for display
  String get title {
    if (isOwned) {
      return ownedEvent!.title;
    } else {
      return invitedEvent!.title;
    }
  }

  /// Get event ID
  int get eventId {
    if (isOwned) {
      return ownedEvent!.id ?? 0;
    } else {
      return invitedEvent!.eventId;
    }
  }
}
