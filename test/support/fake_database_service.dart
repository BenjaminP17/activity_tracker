import 'package:activity_tracker/models/run_entry.dart';
import 'package:activity_tracker/services/database_service.dart';

/// A [DatabaseService] fake that keeps runs in memory instead of touching
/// sqflite, so widget tests can run without a platform channel.
class FakeDatabaseService extends DatabaseService {
  FakeDatabaseService({List<RunEntry> initialRuns = const []})
    : _runs = List<RunEntry>.of(initialRuns),
      super(path: 'fake');

  final List<RunEntry> _runs;

  /// The run passed to the most recent [insert] call, if any.
  RunEntry? get insertedRun => _runs.isEmpty ? null : _runs.last;

  @override
  Future<RunEntry> insert(RunEntry entry) async {
    _runs.add(entry);
    return entry;
  }

  @override
  Future<List<RunEntry>> getAll() async => List<RunEntry>.of(_runs);

  @override
  Future<int> delete(int id) async {
    final int before = _runs.length;
    _runs.removeWhere((RunEntry run) => run.id == id);
    return before - _runs.length;
  }

  @override
  Future<bool> existsByHealthConnectUuid(String uuid) async =>
      _runs.any((RunEntry run) => run.healthConnectUuid == uuid);
}
