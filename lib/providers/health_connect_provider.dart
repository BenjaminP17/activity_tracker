import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise_data.dart';
import '../models/goal.dart';
import '../models/run_entry.dart';
import '../services/database_service.dart';
import '../services/health_connect_service.dart';
import 'dashboard_provider.dart' show dashboardStatsProvider;
import 'goal_provider.dart' show currentGoalProvider;
import 'run_provider.dart' show databaseServiceProvider, runListProvider;

/// Exposes the [HealthConnectService] singleton to the rest of the app.
final Provider<HealthConnectService> healthConnectServiceProvider =
    Provider<HealthConnectService>((Ref ref) => HealthConnectService());

/// Whether Health Connect is available on this device and already
/// authorized for READ/WRITE access to exercises.
final FutureProvider<bool> healthConnectAuthorizedProvider =
    FutureProvider<bool>((Ref ref) async {
      final HealthConnectService service = ref.watch(
        healthConnectServiceProvider,
      );
      if (!await service.isHealthConnectAvailable()) {
        return false;
      }
      return service.hasPermissions();
    });

/// Requests Health Connect permissions and syncs exercises into SQLite.
final AsyncNotifierProvider<SyncHealthConnectNotifier, void>
syncHealthConnectProvider =
    AsyncNotifierProvider<SyncHealthConnectNotifier, void>(
      SyncHealthConnectNotifier.new,
    );

class SyncHealthConnectNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Requests permissions (if not already granted) and, once granted,
  /// performs a sync. Returns whether permissions were granted.
  Future<bool> requestPermissionsAndSync() async {
    final HealthConnectService service = ref.read(healthConnectServiceProvider);
    bool granted = false;
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      if (!await service.isHealthConnectAvailable()) {
        throw StateError(
          "Health Connect n'est pas disponible sur cet appareil.",
        );
      }
      granted = await service.requestPermissions();
      if (!granted) {
        throw StateError('Permissions Health Connect refusées.');
      }
      await _sync(service);
    });
    ref.invalidate(healthConnectAuthorizedProvider);
    return granted;
  }

  /// Fetches today's exercises from Health Connect and stores each of them
  /// as a [RunEntry].
  Future<void> sync() async {
    final HealthConnectService service = ref.read(healthConnectServiceProvider);
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      if (!await service.isHealthConnectAvailable()) {
        return;
      }
      await _sync(service);
    });
  }

  Future<void> _sync(HealthConnectService service) async {
    final List<ExerciseData> exercises = await service
        .getExercisesFromHealthConnect();
    debugPrint('Found ${exercises.length} exercises from Health Connect');
    if (exercises.isEmpty) {
      return;
    }

    final DatabaseService db = ref.read(databaseServiceProvider);
    final Goal? goal = await ref.read(currentGoalProvider.future);
    int insertedCount = 0;
    for (final ExerciseData exercise in exercises) {
      final String? uuid = exercise.healthConnectUuid;
      if (uuid != null && await db.existsByHealthConnectUuid(uuid)) {
        debugPrint('Skipping already-imported exercise $uuid');
        continue;
      }
      debugPrint(
        'Converting exercise ${exercise.distanceKm} km on ${exercise.date}',
      );
      final RunEntry run = exerciseToRunEntry(exercise, goalId: goal?.id);
      debugPrint('Inserting RunEntry into SQLite');
      await db.insert(run);
      insertedCount++;
    }

    if (insertedCount > 0) {
      await ref.read(runListProvider.notifier).refresh();
      final _ = ref.refresh(dashboardStatsProvider);
    }
    debugPrint('Sync complete: $insertedCount runs imported');
  }
}
