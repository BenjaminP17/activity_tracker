import 'package:activity_tracker/models/goal.dart';
import 'package:activity_tracker/services/database_service.dart';
import 'package:activity_tracker/services/goal_service.dart';

/// A [GoalService] fake that keeps goals in memory instead of touching
/// sqflite, so widget tests can run without a platform channel.
class FakeGoalService extends GoalService {
  FakeGoalService({Goal? initialGoal, List<Goal> initialGoals = const []})
      : _goals = [...initialGoals, ?initialGoal],
        super(DatabaseService(path: 'fake'));

  final List<Goal> _goals;

  /// The id passed to the most recent [setActive] call, if any.
  int? activatedId;

  /// The goal passed to the most recent [insert] call, if any.
  Goal? get insertedGoal => _goals.isEmpty ? null : _goals.last;

  @override
  Future<Goal> insert(Goal goal) async {
    _goals.add(goal);
    return goal;
  }

  @override
  Future<List<Goal>> getAll() async => List<Goal>.of(_goals);

  @override
  Future<Goal?> getActive() async {
    for (final Goal goal in _goals) {
      if (goal.isActive) {
        return goal;
      }
    }
    return null;
  }

  @override
  Future<int> update(Goal goal) async {
    final int index = _goals.indexWhere((Goal g) => g.id == goal.id);
    if (index == -1) {
      return 0;
    }
    _goals[index] = goal;
    return 1;
  }

  @override
  Future<void> setActive(int id) async {
    activatedId = id;
    for (int i = 0; i < _goals.length; i++) {
      _goals[i] = _goals[i].copyWith(isActive: _goals[i].id == id);
    }
  }
}
