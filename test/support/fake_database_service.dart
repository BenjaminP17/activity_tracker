import 'package:activity_tracker/models/run_entry.dart';
import 'package:activity_tracker/services/database_service.dart';

/// A [DatabaseService] fake that returns an empty run list instead of
/// touching sqflite, so widget tests can run without a platform channel.
class FakeDatabaseService extends DatabaseService {
  FakeDatabaseService() : super(path: 'fake');

  @override
  Future<List<RunEntry>> getAll() async => [];
}
