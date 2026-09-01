import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_data.freezed.dart';

/// A single exercise session read from (or written to) Health Connect.
@freezed
abstract class ExerciseData with _$ExerciseData {
  const factory ExerciseData({
    required double distanceKm,
    required DateTime date,
    Duration? duration,
    String? healthConnectUuid,
  }) = _ExerciseData;
}
