import 'package:freezed_annotation/freezed_annotation.dart';

import 'activity_type.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

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
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
