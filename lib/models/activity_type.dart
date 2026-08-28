import 'package:flutter/material.dart';

/// The kind of activity a [Goal] tracks. Extensible: new sports are added
/// here and wired into the UI (icon, label, availability) independently.
enum ActivityType { running, cycling, swimming, hiking }

extension ActivityTypeDisplay on ActivityType {
  /// The icon representing this activity type.
  Icon toIcon() {
    final IconData data = switch (this) {
      ActivityType.running => Icons.directions_run,
      ActivityType.cycling => Icons.directions_bike,
      ActivityType.swimming => Icons.pool,
      ActivityType.hiking => Icons.terrain,
    };
    return Icon(data);
  }

  /// The human-readable label for this activity type.
  String toLabel() => switch (this) {
        ActivityType.running => 'Running',
        ActivityType.cycling => 'Cycling',
        ActivityType.swimming => 'Swimming',
        ActivityType.hiking => 'Hiking',
      };
}
