import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:activity_tracker/models/activity_type.dart';
import 'package:activity_tracker/models/dashboard_stats.dart';
import 'package:activity_tracker/models/exercise_data.dart';
import 'package:activity_tracker/models/goal.dart';
import 'package:activity_tracker/models/run_entry.dart';
import 'package:activity_tracker/providers/dashboard_provider.dart';
import 'package:activity_tracker/providers/goal_provider.dart';
import 'package:activity_tracker/providers/health_connect_provider.dart';
import 'package:activity_tracker/providers/run_provider.dart';
import 'package:activity_tracker/services/health_connect_service.dart';

import '../support/fake_database_service.dart';

/// A [HealthConnectService] fake that returns canned exercises instead of
/// going through the `health` plugin's platform channel, so it can run in a
/// plain Dart test environment.
class _FakeHealthConnectService extends HealthConnectService {
  _FakeHealthConnectService(this._exercises);

  final List<ExerciseData> _exercises;

  @override
  Future<bool> isHealthConnectAvailable() async => true;

  @override
  Future<List<ExerciseData>> getExercisesFromHealthConnect() async =>
      _exercises;
}

class _FakeCurrentGoalNotifier extends CurrentGoalNotifier {
  _FakeCurrentGoalNotifier(this._goal);

  final Goal? _goal;

  @override
  Future<Goal?> build() async => _goal;
}

void main() {
  final Goal goal = Goal(
    id: 1,
    name: 'Marathon Challenge',
    targetKm: 100,
    targetDate: DateTime.now().add(const Duration(days: 30)),
    activityType: ActivityType.running,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  );

  ProviderContainer buildContainer({
    required List<ExerciseData> exercises,
    Goal? activeGoal,
    List<RunEntry> existingRuns = const [],
  }) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        healthConnectServiceProvider.overrideWithValue(
          _FakeHealthConnectService(exercises),
        ),
        databaseServiceProvider.overrideWithValue(
          FakeDatabaseService(initialRuns: existingRuns),
        ),
        currentGoalProvider.overrideWith(
          () => _FakeCurrentGoalNotifier(activeGoal),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('sync() reads exercises from Health Connect, inserts a RunEntry per '
      'exercise attached to the active goal, and refreshes runListProvider '
      'and dashboardStatsProvider', () async {
    final DateTime runDate = DateTime(2026, 8, 20, 8);
    final List<ExerciseData> exercises = [
      ExerciseData(
        distanceKm: 7,
        date: runDate,
        duration: const Duration(minutes: 40),
      ),
    ];
    final ProviderContainer container = buildContainer(
      exercises: exercises,
      activeGoal: goal,
    );

    // Prime the dependent providers before syncing, so a stale read after
    // sync() would prove they were never invalidated.
    final List<RunEntry> runsBefore = await container.read(
      runListProvider.future,
    );
    final DashboardStats statsBefore = await container.read(
      dashboardStatsProvider.future,
    );
    expect(runsBefore, isEmpty);
    expect(statsBefore.totalKm, 0);

    await container.read(syncHealthConnectProvider.notifier).sync();

    final List<RunEntry> runsAfter = await container.read(
      runListProvider.future,
    );
    expect(runsAfter, hasLength(1));
    expect(runsAfter.single.kilometers, 7.0);
    expect(runsAfter.single.date, runDate);
    expect(runsAfter.single.goalId, goal.id);

    final DashboardStats statsAfter = await container.read(
      dashboardStatsProvider.future,
    );
    expect(statsAfter.totalKm, 7.0);
  });

  test(
    'sync() inserts one RunEntry per exercise returned by Health Connect',
    () async {
      final List<ExerciseData> exercises = [
        ExerciseData(distanceKm: 7, date: DateTime(2026, 8, 20)),
        ExerciseData(distanceKm: 3, date: DateTime(2026, 8, 21)),
      ];
      final ProviderContainer container = buildContainer(
        exercises: exercises,
        activeGoal: goal,
      );

      await container.read(syncHealthConnectProvider.notifier).sync();

      final List<RunEntry> runs = await container.read(runListProvider.future);
      expect(runs, hasLength(2));
      expect(
        runs.map((RunEntry run) => run.kilometers),
        containsAll(<double>[7.0, 3.0]),
      );
    },
  );

  test('sync() leaves the run list untouched when Health Connect has no '
      'new exercises', () async {
    final ProviderContainer container = buildContainer(
      exercises: const [],
      activeGoal: goal,
    );

    await container.read(syncHealthConnectProvider.notifier).sync();

    final List<RunEntry> runs = await container.read(runListProvider.future);
    expect(runs, isEmpty);
  });

  test('sync() skips an exercise whose healthConnectUuid was already '
      'imported, instead of re-inserting it', () async {
    final RunEntry alreadyImported = RunEntry(
      id: 1,
      kilometers: 7,
      date: DateTime(2026, 8, 20),
      goalId: goal.id,
      healthConnectUuid: 'hc-uuid-dup',
    );
    final List<ExerciseData> exercises = [
      ExerciseData(
        distanceKm: 7,
        date: DateTime(2026, 8, 20),
        healthConnectUuid: 'hc-uuid-dup',
      ),
      ExerciseData(
        distanceKm: 3,
        date: DateTime(2026, 8, 21),
        healthConnectUuid: 'hc-uuid-new',
      ),
    ];
    final ProviderContainer container = buildContainer(
      exercises: exercises,
      activeGoal: goal,
      existingRuns: [alreadyImported],
    );

    await container.read(syncHealthConnectProvider.notifier).sync();

    final List<RunEntry> runs = await container.read(runListProvider.future);
    expect(runs, hasLength(2));
    expect(
      runs.map((RunEntry run) => run.healthConnectUuid),
      containsAll(<String>['hc-uuid-dup', 'hc-uuid-new']),
    );
  });

  test(
    'sync() inserts runs with a null goalId when there is no active goal',
    () async {
      final List<ExerciseData> exercises = [
        ExerciseData(distanceKm: 7, date: DateTime(2026, 8, 20)),
      ];
      final ProviderContainer container = buildContainer(
        exercises: exercises,
        activeGoal: null,
      );

      await container.read(syncHealthConnectProvider.notifier).sync();

      final List<RunEntry> runs = await container.read(runListProvider.future);
      expect(runs.single.goalId, isNull);
    },
  );
}
