import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';

import 'package:activity_tracker/models/exercise_data.dart';
import 'package:activity_tracker/models/run_entry.dart';
import 'package:activity_tracker/services/health_connect_service.dart';

/// A [HealthConnectService] fake that returns canned exercises instead of
/// going through the `health` plugin's platform channel, so it can run in a
/// plain Dart test environment.
class _FakeHealthConnectService extends HealthConnectService {
  _FakeHealthConnectService(this._exercises);

  final List<ExerciseData> _exercises;

  @override
  Future<List<ExerciseData>> getExercisesFromHealthConnect() async =>
      _exercises;
}

/// A [Health] fake that records the time range it was queried with instead
/// of going through the platform channel, so the date-range filtering logic
/// in [HealthConnectService.getExercisesFromHealthConnect] can be verified.
class _FakeHealth extends Health {
  DateTime? capturedStartTime;
  DateTime? capturedEndTime;

  @override
  Future<List<HealthDataPoint>> getHealthDataFromTypes({
    required List<HealthDataType> types,
    Map<HealthDataType, HealthDataUnit>? preferredUnits,
    required DateTime startTime,
    required DateTime endTime,
    List<RecordingMethod> recordingMethodsToFilter = const [],
  }) async {
    capturedStartTime = startTime;
    capturedEndTime = endTime;
    return <HealthDataPoint>[];
  }
}

HealthDataPoint _buildWorkoutPoint({
  required DateTime dateFrom,
  required DateTime dateTo,
  required int totalDistanceMeters,
}) {
  return HealthDataPoint(
    uuid: 'test-uuid',
    value: WorkoutHealthValue(
      workoutActivityType: HealthWorkoutActivityType.RUNNING,
      totalDistance: totalDistanceMeters,
      totalDistanceUnit: HealthDataUnit.METER,
    ),
    type: HealthDataType.WORKOUT,
    unit: HealthDataUnit.NO_UNIT,
    dateFrom: dateFrom,
    dateTo: dateTo,
    sourcePlatform: HealthPlatformType.googleHealthConnect,
    sourceDeviceId: 'device-1',
    sourceId: 'source-1',
    sourceName: 'Health Connect',
  );
}

HealthDataPoint _buildDistancePoint({
  required DateTime dateFrom,
  required DateTime dateTo,
  required num distanceMeters,
}) {
  return HealthDataPoint(
    uuid: 'test-uuid-distance',
    value: NumericHealthValue(numericValue: distanceMeters),
    type: HealthDataType.DISTANCE_DELTA,
    unit: HealthDataUnit.METER,
    dateFrom: dateFrom,
    dateTo: dateTo,
    sourcePlatform: HealthPlatformType.googleHealthConnect,
    sourceDeviceId: 'device-1',
    sourceId: 'source-1',
    sourceName: 'Health Connect',
  );
}

void main() {
  group('exerciseFromHealthDataPoint', () {
    test('converts a DistanceRecord data point into ExerciseData', () {
      final DateTime start = DateTime(2026, 8, 20, 7);
      final DateTime end = start.add(const Duration(minutes: 40));

      final ExerciseData exercise = exerciseFromHealthDataPoint(
        _buildDistancePoint(dateFrom: start, dateTo: end, distanceMeters: 7000),
      );

      expect(exercise.distanceKm, 7.0);
      expect(exercise.date, start);
      expect(exercise.healthConnectUuid, 'test-uuid-distance');
    });

    test('converts a workout data point into ExerciseData', () {
      final DateTime start = DateTime(2026, 8, 1, 7);
      final DateTime end = start.add(const Duration(minutes: 30));

      final ExerciseData exercise = exerciseFromHealthDataPoint(
        _buildWorkoutPoint(
          dateFrom: start,
          dateTo: end,
          totalDistanceMeters: 5000,
        ),
      );

      expect(exercise.distanceKm, 5.0);
      expect(exercise.date, start);
      expect(exercise.duration, const Duration(minutes: 30));
      expect(exercise.healthConnectUuid, 'test-uuid');
    });

    test('defaults distance to 0 when the point has no distance', () {
      final HealthDataPoint point = HealthDataPoint(
        uuid: 'test-uuid-2',
        value: WorkoutHealthValue(
          workoutActivityType: HealthWorkoutActivityType.RUNNING,
        ),
        type: HealthDataType.WORKOUT,
        unit: HealthDataUnit.NO_UNIT,
        dateFrom: DateTime(2026, 8, 1),
        dateTo: DateTime(2026, 8, 1, 0, 45),
        sourcePlatform: HealthPlatformType.googleHealthConnect,
        sourceDeviceId: 'device-1',
        sourceId: 'source-1',
        sourceName: 'Health Connect',
      );

      final ExerciseData exercise = exerciseFromHealthDataPoint(point);

      expect(exercise.distanceKm, 0.0);
    });
  });

  group('getExercisesFromHealthConnect (via fake)', () {
    test('reads exercises correctly', () async {
      final List<ExerciseData> exercises = [
        ExerciseData(
          distanceKm: 10,
          date: DateTime(2026, 8, 20, 8),
          duration: const Duration(hours: 1),
        ),
      ];
      final HealthConnectService service = _FakeHealthConnectService(exercises);

      final List<ExerciseData> result = await service
          .getExercisesFromHealthConnect();

      expect(result, exercises);
    });
  });

  group('getExercisesFromHealthConnect (via fake Health)', () {
    test(
      'queries Health Connect for today only, midnight to end of day',
      () async {
        final _FakeHealth fakeHealth = _FakeHealth();
        final HealthConnectService service = HealthConnectService(
          health: fakeHealth,
        );

        await service.getExercisesFromHealthConnect();

        final DateTime now = DateTime.now();
        expect(
          fakeHealth.capturedStartTime,
          DateTime(now.year, now.month, now.day),
        );
        expect(
          fakeHealth.capturedEndTime,
          DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
        );
      },
    );
  });

  group('exerciseToRunEntry', () {
    test('converts an ExerciseData into a RunEntry with the given goal', () {
      final ExerciseData exercise = ExerciseData(
        distanceKm: 7.5,
        date: DateTime(2026, 8, 20, 8),
        duration: const Duration(minutes: 45),
        healthConnectUuid: 'exercise-uuid',
      );

      final RunEntry run = exerciseToRunEntry(exercise, goalId: 3);

      expect(run.kilometers, 7.5);
      expect(run.date, exercise.date);
      expect(run.goalId, 3);
      expect(run.healthConnectUuid, 'exercise-uuid');
    });

    test('leaves goalId null when no goal is provided', () {
      final ExerciseData exercise = ExerciseData(
        distanceKm: 2,
        date: DateTime(2026, 8, 20),
      );

      final RunEntry run = exerciseToRunEntry(exercise);

      expect(run.goalId, isNull);
    });
  });
}
