import 'package:freezed_annotation/freezed_annotation.dart';

import 'activity_type.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

/// The lifecycle status of a [Goal] relative to its target distance and
/// deadline, computed by `GoalCompletionService.determineStatus`.
enum GoalCompletionStatus { active, completedSuccess, completedFailure }

extension GoalCompletionStatusDisplay on GoalCompletionStatus {
  /// The human-readable, emoji-prefixed label for a finalized status.
  /// Returns an empty string for [GoalCompletionStatus.active], which has
  /// no badge of its own.
  String toLabel() => switch (this) {
        GoalCompletionStatus.active => '',
        GoalCompletionStatus.completedSuccess => '✅ Réussi',
        GoalCompletionStatus.completedFailure => '❌ Échec',
      };
}

@freezed
abstract class Goal with _$Goal {
  const factory Goal({
    required int id,
    required String name,
    required double targetKm,
    required DateTime targetDate,
    required ActivityType activityType,
    required bool isActive,
    required DateTime createdAt,
    @Default(GoalCompletionStatus.active)
    GoalCompletionStatus completionStatus,
    DateTime? completedAt,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
