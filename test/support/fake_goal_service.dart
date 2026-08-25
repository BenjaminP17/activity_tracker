import 'package:activity_tracker/models/goal.dart';
import 'package:activity_tracker/services/database_service.dart';
import 'package:activity_tracker/services/goal_service.dart';

/// A [GoalService] fake that keeps a single goal in memory instead of
/// touching sqflite, so widget tests can run without a platform channel.
class FakeGoalService extends GoalService {
  FakeGoalService({Goal? initialGoal})
      : _goal = initialGoal,
        super(DatabaseService(path: 'fake'));

  Goal? _goal;

  /// The goal passed to the most recent [insert] call, if any.
  Goal? get insertedGoal => _goal;

  @override
  Future<Goal> insert(Goal goal) async {
    _goal = goal;
    return goal;
  }

  @override
  Future<List<Goal>> getAll() async => _goal == null ? [] : [_goal!];

  @override
  Future<Goal?> getActive() async => _goal;
}
