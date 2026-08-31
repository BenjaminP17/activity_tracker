import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../models/exercise_data.dart';
import '../models/run_entry.dart';

/// The Health Connect data types this app reads and writes exercises as.
///
/// [HealthDataType.DISTANCE_DELTA] maps to Health Connect's DistanceRecord,
/// which is where Strava's synced kilometers actually land — a workout
/// session doesn't always carry its own distance.
const List<HealthDataType> _exerciseTypes = <HealthDataType>[
  HealthDataType.WORKOUT,
  HealthDataType.DISTANCE_DELTA,
];

/// Minimum duration written for an exercise with no known duration, since
/// Health Connect requires a workout's end time to be after its start time.
const Duration _fallbackDuration = Duration(minutes: 1);

/// Reads and writes running exercises from/to Google Health Connect.
class HealthConnectService {
  HealthConnectService({Health? health}) : _health = health ?? Health();

  final Health _health;

  /// Whether Health Connect is installed and usable on this device.
  Future<bool> isHealthConnectAvailable() async {
    await _health.configure();
    return _health.isHealthConnectAvailable();
  }

  /// Whether READ/WRITE access to exercises has already been granted.
  Future<bool> hasPermissions() async {
    await _health.configure();
    final bool? granted = await _health.hasPermissions(
      _exerciseTypes,
      permissions: List<HealthDataAccess>.filled(
        _exerciseTypes.length,
        HealthDataAccess.READ_WRITE,
      ),
    );
    return granted ?? false;
  }

  /// Requests READ and WRITE access to exercise data. Returns whether the
  /// user granted the permissions.
  Future<bool> requestPermissions() async {
    await _health.configure();
    return _health.requestAuthorization(
      _exerciseTypes,
      permissions: List<HealthDataAccess>.filled(
        _exerciseTypes.length,
        HealthDataAccess.READ_WRITE,
      ),
    );
  }

  /// Reads exercises recorded in Health Connect today, from midnight to
  /// the end of the day, so a sync never re-imports prior days' runs.
  Future<List<ExerciseData>> getExercisesFromHealthConnect() async {
    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);
    final DateTime endOfToday = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
      999,
    );
    final List<HealthDataPoint> points = await _health.getHealthDataFromTypes(
      types: _exerciseTypes,
      startTime: startOfToday,
      endTime: endOfToday,
    );
    return points
        .where(
          (HealthDataPoint point) =>
              point.value is WorkoutHealthValue ||
              point.value is NumericHealthValue,
        )
        .map(exerciseFromHealthDataPoint)
        .toList();
  }

  /// Writes a run to Health Connect as a running workout.
  Future<bool> writeExerciseToHealthConnect(
    double distanceKm,
    DateTime date, {
    Duration? duration,
  }) {
    return _health.writeWorkoutData(
      activityType: HealthWorkoutActivityType.RUNNING,
      start: date,
      end: date.add(duration ?? _fallbackDuration),
      totalDistance: (distanceKm * 1000).round(),
      totalDistanceUnit: HealthDataUnit.METER,
    );
  }
}

/// Converts a Health Connect workout or DistanceRecord data point into
/// [ExerciseData].
///
/// Exposed for testing: constructing a [HealthDataPoint] directly lets the
/// conversion logic be verified without touching the platform channel that
/// [HealthConnectService.getExercisesFromHealthConnect] relies on.
@visibleForTesting
ExerciseData exerciseFromHealthDataPoint(HealthDataPoint point) {
  final double distanceKm = switch (point.value) {
    WorkoutHealthValue(:final int? totalDistance) =>
      (totalDistance ?? 0) / 1000,
    NumericHealthValue(:final numericValue) => numericValue / 1000,
    _ => 0,
  };
  return ExerciseData(
    distanceKm: distanceKm,
    date: point.dateFrom,
    duration: point.dateTo.difference(point.dateFrom),
    healthConnectUuid: point.uuid,
  );
}

/// Converts an [ExerciseData] read from Health Connect into a [RunEntry],
/// optionally attached to [goalId].
RunEntry exerciseToRunEntry(ExerciseData exercise, {int? goalId}) => RunEntry(
  id: exercise.date.millisecondsSinceEpoch,
  kilometers: exercise.distanceKm,
  date: exercise.date,
  goalId: goalId,
  healthConnectUuid: exercise.healthConnectUuid,
);
