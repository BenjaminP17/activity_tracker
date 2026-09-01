import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import '../services/goal_completion_service.dart';
import '../services/goal_service.dart';
import 'run_provider.dart' show databaseServiceProvider;

/// Exposes the [GoalService] singleton, built from the shared
/// [databaseServiceProvider] connection.
final Provider<GoalService> goalServiceProvider = Provider<GoalService>(
  (Ref ref) => GoalService(ref.watch(databaseServiceProvider)),
);

/// Exposes the [GoalCompletionService] singleton, used to keep each goal's
/// [GoalCompletionStatus] in sync with its logged runs and deadline.
final Provider<GoalCompletionService> goalCompletionServiceProvider =
    Provider<GoalCompletionService>(
  (Ref ref) => GoalCompletionService(
    ref.watch(goalServiceProvider),
    ref.watch(databaseServiceProvider),
  ),
);

/// Which subset of goals [GoalsListScreen] displays.
enum GoalFilter { active, completed, all }

/// The filter currently selected on [GoalsListScreen].
final StateProvider<GoalFilter> goalFilterProvider =
    StateProvider<GoalFilter>((Ref ref) => GoalFilter.active);

/// Holds the currently active goal, if any.
final AsyncNotifierProvider<CurrentGoalNotifier, Goal?> currentGoalProvider =
    AsyncNotifierProvider<CurrentGoalNotifier, Goal?>(
  CurrentGoalNotifier.new,
);

class CurrentGoalNotifier extends AsyncNotifier<Goal?> {
  @override
  Future<Goal?> build() async {
    final GoalService service = ref.watch(goalServiceProvider);
    return service.getActive();
  }

  /// Reloads the active goal from the database.
  Future<void> refresh() async {
    final GoalService service = ref.read(goalServiceProvider);
    state = const AsyncLoading<Goal?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => service.getActive());
  }
}

/// Handles inserting a new goal and triggers a recalculation of dependent
/// state (the current goal, and the goal list) once it's done.
final AsyncNotifierProvider<GoalInsertNotifier, void> goalInsertProvider =
    AsyncNotifierProvider<GoalInsertNotifier, void>(GoalInsertNotifier.new);

class GoalInsertNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> insert(Goal goal) async {
    final GoalService service = ref.read(goalServiceProvider);
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await service.insert(goal);
      await _recalculate();
    });
  }

  /// Recalculates dependent state after a goal has been inserted.
  Future<void> _recalculate() async {
    await ref.read(currentGoalProvider.notifier).refresh();
    await ref.read(activeGoalsProvider.notifier).refresh();
  }
}

/// Holds every goal still in progress, after refreshing each goal's
/// completion status against its logged runs and deadline.
final AsyncNotifierProvider<ActiveGoalsNotifier, List<Goal>>
    activeGoalsProvider = AsyncNotifierProvider<ActiveGoalsNotifier, List<Goal>>(
  ActiveGoalsNotifier.new,
);

class ActiveGoalsNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() => _load();

  /// Reloads the active goal list, refreshing statuses first.
  Future<void> refresh() async {
    state = const AsyncLoading<List<Goal>>().copyWithPrevious(state);
    state = await AsyncValue.guard(_load);
  }

  Future<List<Goal>> _load() async {
    final List<Goal> goals = await _refreshedGoals(ref);
    return goals
        .where(
          (Goal goal) => goal.completionStatus == GoalCompletionStatus.active,
        )
        .toList()
      ..sort((Goal a, Goal b) => a.targetDate.compareTo(b.targetDate));
  }
}

/// Holds every goal that has finished (successfully or not), after
/// refreshing each goal's completion status against its logged runs and
/// deadline.
final AsyncNotifierProvider<CompletedGoalsNotifier, List<Goal>>
    completedGoalsProvider =
    AsyncNotifierProvider<CompletedGoalsNotifier, List<Goal>>(
  CompletedGoalsNotifier.new,
);

class CompletedGoalsNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() => _load();

  /// Reloads the completed goal list, refreshing statuses first.
  Future<void> refresh() async {
    state = const AsyncLoading<List<Goal>>().copyWithPrevious(state);
    state = await AsyncValue.guard(_load);
  }

  Future<List<Goal>> _load() async {
    final List<Goal> goals = await _refreshedGoals(ref);
    return goals
        .where(
          (Goal goal) => goal.completionStatus != GoalCompletionStatus.active,
        )
        .toList()
      ..sort(
        (Goal a, Goal b) => (b.completedAt ?? b.targetDate)
            .compareTo(a.completedAt ?? a.targetDate),
      );
  }
}

/// Refreshes every goal's completion status against its logged runs and
/// deadline, then returns the resulting goal list.
Future<List<Goal>> _refreshedGoals(Ref ref) async {
  final GoalService goalService = ref.watch(goalServiceProvider);
  final GoalCompletionService completionService =
      ref.watch(goalCompletionServiceProvider);
  final List<Goal> goals = await goalService.getAll();
  for (final Goal goal in goals) {
    await completionService.updateGoalStatus(goal.id);
  }
  return goalService.getAll();
}
