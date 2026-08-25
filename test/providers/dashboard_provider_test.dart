import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:activity_tracker/models/dashboard_stats.dart';
import 'package:activity_tracker/models/goal.dart';
import 'package:activity_tracker/models/run_entry.dart';
import 'package:activity_tracker/providers/dashboard_provider.dart';
import 'package:activity_tracker/providers/goal_provider.dart';
import 'package:activity_tracker/providers/run_provider.dart';

class _FakeCurrentGoalNotifier extends CurrentGoalNotifier {
  _FakeCurrentGoalNotifier(this._goal);

  final Goal? _goal;

  @override
  Future<Goal?> build() async => _goal;
}

class _FakeRunListNotifier extends RunListNotifier {
  _FakeRunListNotifier(this._runs);

  final List<RunEntry> _runs;

  @override
  Future<List<RunEntry>> build() async => _runs;
}

void main() {
  Goal buildGoal({required double targetKm, required DateTime targetDate}) =>
      Goal(
        id: 1,
        targetKm: targetKm,
        targetDate: targetDate,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
      );

  RunEntry buildRun({
    required int id,
    required double kilometers,
    int? goalId = 1,
  }) =>
      RunEntry(
        id: id,
        kilometers: kilometers,
        date: DateTime(2026, 1, id),
        goalId: goalId,
      );

  ProviderContainer buildContainer({
    required Goal? goal,
    required List<RunEntry> runs,
  }) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        currentGoalProvider
            .overrideWith(() => _FakeCurrentGoalNotifier(goal)),
        runListProvider.overrideWith(() => _FakeRunListNotifier(runs)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
      'computes totalKm, remainingKm, weeksRemaining and weeklyAverageNeeded '
      'from the runs of the active goal', () async {
    final DateTime today = DateTime.now();
    final DateTime targetDate =
        DateTime(today.year, today.month, today.day).add(const Duration(days: 20));
    final Goal goal = buildGoal(targetKm: 100, targetDate: targetDate);
    final List<RunEntry> runs = [
      buildRun(id: 1, kilometers: 10),
      buildRun(id: 2, kilometers: 15),
      buildRun(id: 3, kilometers: 5, goalId: 999), // other goal, excluded
    ];

    final ProviderContainer container =
        buildContainer(goal: goal, runs: runs);
    final DashboardStats stats =
        await container.read(dashboardStatsProvider.future);

    expect(stats.totalKm, 25);
    expect(stats.remainingKm, 75);
    expect(stats.weeksRemaining, 3); // ceil(20 / 7)
    expect(stats.weeklyAverageNeeded, 25); // 75 / 3
  });

  test('progressPercent is clamped between 0 and 100', () async {
    final Goal goal = buildGoal(
      targetKm: 50,
      targetDate: DateTime.now().add(const Duration(days: 7)),
    );
    final List<RunEntry> runs = [buildRun(id: 1, kilometers: 80)];

    final ProviderContainer container =
        buildContainer(goal: goal, runs: runs);
    final DashboardStats stats =
        await container.read(dashboardStatsProvider.future);

    expect(stats.progressPercent, 100);
  });

  test('weeklyAverageNeeded is 0.0 when weeksRemaining is 0', () async {
    final Goal goal = buildGoal(targetKm: 100, targetDate: DateTime.now());
    final List<RunEntry> runs = [buildRun(id: 1, kilometers: 10)];

    final ProviderContainer container =
        buildContainer(goal: goal, runs: runs);
    final DashboardStats stats =
        await container.read(dashboardStatsProvider.future);

    expect(stats.weeksRemaining, 0);
    expect(stats.weeklyAverageNeeded, 0.0);
  });

  test('goalCompleted is true once remainingKm <= 0', () async {
    final Goal goal = buildGoal(
      targetKm: 20,
      targetDate: DateTime.now().add(const Duration(days: 7)),
    );
    final List<RunEntry> runs = [buildRun(id: 1, kilometers: 25)];

    final ProviderContainer container =
        buildContainer(goal: goal, runs: runs);
    final DashboardStats stats =
        await container.read(dashboardStatsProvider.future);

    expect(stats.goalCompleted, isTrue);
    expect(stats.remainingKm, lessThanOrEqualTo(0));
  });

  test('returns empty stats when there is no active goal', () async {
    final ProviderContainer container =
        buildContainer(goal: null, runs: const []);

    final DashboardStats stats =
        await container.read(dashboardStatsProvider.future);

    expect(stats, DashboardStats.empty());
  });
}
