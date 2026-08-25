import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import '../services/goal_service.dart';
import 'run_provider.dart' show databaseServiceProvider;

/// Exposes the [GoalService] singleton, built from the shared
/// [databaseServiceProvider] connection.
final Provider<GoalService> goalServiceProvider = Provider<GoalService>(
  (Ref ref) => GoalService(ref.watch(databaseServiceProvider)),
);

/// Holds the list of goals loaded from the database.
final AsyncNotifierProvider<GoalListNotifier, List<Goal>> goalListProvider =
    AsyncNotifierProvider<GoalListNotifier, List<Goal>>(GoalListNotifier.new);

class GoalListNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    final GoalService service = ref.watch(goalServiceProvider);
    return service.getAll();
  }

  /// Reloads the goal list from the database.
  Future<void> refresh() async {
    final GoalService service = ref.read(goalServiceProvider);
    state = const AsyncLoading<List<Goal>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => service.getAll());
  }
}

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
    await ref.read(goalListProvider.notifier).refresh();
  }
}
