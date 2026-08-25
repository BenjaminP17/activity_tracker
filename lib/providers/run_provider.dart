import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/run_entry.dart';
import '../services/database_service.dart';
import 'providers.dart';

/// Exposes the [DatabaseService] singleton to the rest of the app.
final Provider<DatabaseService> databaseServiceProvider =
    Provider<DatabaseService>((Ref ref) => DatabaseService());

/// Holds the list of runs loaded from the database.
final AsyncNotifierProvider<RunListNotifier, List<RunEntry>> runListProvider =
    AsyncNotifierProvider<RunListNotifier, List<RunEntry>>(
  RunListNotifier.new,
);

class RunListNotifier extends AsyncNotifier<List<RunEntry>> {
  @override
  Future<List<RunEntry>> build() async {
    final DatabaseService db = ref.read(databaseServiceProvider);
    return db.getAll();
  }

  /// Reloads the run list from the database.
  Future<void> refresh() async {
    final DatabaseService db = ref.read(databaseServiceProvider);
    state = const AsyncLoading<List<RunEntry>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => db.getAll());
  }
}

/// Handles inserting a new run and triggers a recalculation of dependent
/// state (the run list, and anything derived from it) once it's done.
final AsyncNotifierProvider<RunInsertNotifier, void> runInsertProvider =
    AsyncNotifierProvider<RunInsertNotifier, void>(RunInsertNotifier.new);

class RunInsertNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> insert(RunEntry entry) async {
    final DatabaseService db = ref.read(databaseServiceProvider);
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await db.insert(entry);
      await _recalculate();
    });
  }

  /// Recalculates dependent state after a run has been inserted.
  Future<void> _recalculate() async {
    await ref.read(runListProvider.notifier).refresh();
    final _ = ref.refresh(dashboardStatsProvider);
  }
}

/// Handles deleting a run and triggers a recalculation of dependent
/// state (the run list, and anything derived from it) once it's done.
final AsyncNotifierProvider<RunDeleteNotifier, void> runDeleteProvider =
    AsyncNotifierProvider<RunDeleteNotifier, void>(RunDeleteNotifier.new);

class RunDeleteNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> delete(int id) async {
    final DatabaseService db = ref.read(databaseServiceProvider);
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await db.delete(id);
      await _recalculate();
    });
  }

  /// Recalculates dependent state after a run has been deleted.
  Future<void> _recalculate() async {
    await ref.read(runListProvider.notifier).refresh();
    final _ = ref.refresh(dashboardStatsProvider);
  }
}
