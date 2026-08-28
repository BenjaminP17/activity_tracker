import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_stats.dart';
import '../models/goal.dart';
import '../models/run_entry.dart';
import 'providers.dart';

/// Holds the dashboard stats derived from the active goal and its runs.
final AsyncNotifierProvider<DashboardStatsNotifier, DashboardStats>
    dashboardStatsProvider =
    AsyncNotifierProvider<DashboardStatsNotifier, DashboardStats>(
  DashboardStatsNotifier.new,
);

class DashboardStatsNotifier extends AsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() async {
    final Goal? goal = await ref.watch(currentGoalProvider.future);
    if (goal == null) {
      return DashboardStats.empty();
    }
    final List<RunEntry> runs = await ref.watch(runListProvider.future);
    return _computeStats(goal, runs);
  }

  /// Recomputes the dashboard stats from the current goal and run list.
  Future<void> refresh() async {
    state = const AsyncLoading<DashboardStats>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final Goal? goal = await ref.read(currentGoalProvider.future);
      if (goal == null) {
        return DashboardStats.empty();
      }
      final List<RunEntry> runs = await ref.read(runListProvider.future);
      return _computeStats(goal, runs);
    });
  }
}

DashboardStats _computeStats(Goal goal, List<RunEntry> runs) {
  final double totalKm = runs
      .where((RunEntry run) => run.goalId == goal.id)
      .fold(0.0, (double sum, RunEntry run) => sum + run.kilometers);

  final double remainingKm = goal.targetKm - totalKm;
  final int weeksRemaining = _weeksRemaining(goal.targetDate, DateTime.now());
  final double weeklyAverageNeeded =
      weeksRemaining == 0 ? 0.0 : remainingKm / weeksRemaining;
  final double progressPercent = goal.targetKm <= 0
      ? 0.0
      : (totalKm / goal.targetKm * 100).clamp(0, 100).toDouble();

  return DashboardStats(
    totalKm: totalKm,
    remainingKm: remainingKm,
    weeksRemaining: weeksRemaining,
    weeklyAverageNeeded: weeklyAverageNeeded,
    goalCompleted: remainingKm <= 0,
    progressPercent: progressPercent,
    targetKm: goal.targetKm,
    targetDate: goal.targetDate,
  );
}

/// Number of whole weeks between [now] and [targetDate], rounded up.
/// Returns 0 once [targetDate] has been reached (or passed).
int _weeksRemaining(DateTime targetDate, DateTime now) {
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime target =
      DateTime(targetDate.year, targetDate.month, targetDate.day);
  final int days = target.difference(today).inDays;
  if (days <= 0) {
    return 0;
  }
  return (days / 7).ceil();
}
