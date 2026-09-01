import '../models/goal.dart';
import '../models/run_entry.dart';
import 'database_service.dart';
import 'goal_service.dart';

/// Derives and persists a [Goal]'s [GoalCompletionStatus] from its logged
/// distance and deadline.
class GoalCompletionService {
  GoalCompletionService(this._goalService, this._databaseService);

  final GoalService _goalService;
  final DatabaseService _databaseService;

  /// Whether [goal] has been reached, missed, or is still in progress,
  /// given [totalKm] logged against it so far.
  GoalCompletionStatus determineStatus(Goal goal, double totalKm) {
    if (totalKm >= goal.targetKm) {
      return GoalCompletionStatus.completedSuccess;
    }
    if (_isPastDeadline(goal.targetDate)) {
      return GoalCompletionStatus.completedFailure;
    }
    return GoalCompletionStatus.active;
  }

  /// Recomputes [goalId]'s status from its logged runs and, the first time
  /// it leaves [GoalCompletionStatus.active], persists the new status with
  /// a [Goal.completedAt] timestamp. Does nothing once already finalized.
  Future<void> updateGoalStatus(int goalId) async {
    final Goal? goal = await _findGoal(goalId);
    if (goal == null || goal.completionStatus != GoalCompletionStatus.active) {
      return;
    }

    final List<RunEntry> runs = await _databaseService.getAll();
    final double totalKm = runs
        .where((RunEntry run) => run.goalId == goalId)
        .fold(0.0, (double sum, RunEntry run) => sum + run.kilometers);

    final GoalCompletionStatus status = determineStatus(goal, totalKm);
    if (status == GoalCompletionStatus.active) {
      return;
    }

    await _goalService.update(
      goal.copyWith(completionStatus: status, completedAt: DateTime.now()),
    );
  }

  Future<Goal?> _findGoal(int goalId) async {
    final List<Goal> goals = await _goalService.getAll();
    for (final Goal goal in goals) {
      if (goal.id == goalId) {
        return goal;
      }
    }
    return null;
  }

  bool _isPastDeadline(DateTime targetDate) {
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);
    final DateTime targetDateOnly =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    return todayDateOnly.isAfter(targetDateOnly);
  }
}
