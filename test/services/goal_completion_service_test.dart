import 'package:flutter_test/flutter_test.dart';

import 'package:activity_tracker/models/activity_type.dart';
import 'package:activity_tracker/models/goal.dart';
import 'package:activity_tracker/models/run_entry.dart';
import 'package:activity_tracker/services/goal_completion_service.dart';

import '../support/fake_database_service.dart';
import '../support/fake_goal_service.dart';

void main() {
  Goal buildGoal({
    required double targetKm,
    required DateTime targetDate,
    GoalCompletionStatus completionStatus = GoalCompletionStatus.active,
    DateTime? completedAt,
  }) =>
      Goal(
        id: 1,
        name: 'Marathon Challenge',
        targetKm: targetKm,
        targetDate: targetDate,
        activityType: ActivityType.running,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        completionStatus: completionStatus,
        completedAt: completedAt,
      );

  group('determineStatus', () {
    final GoalCompletionService service =
        GoalCompletionService(FakeGoalService(), FakeDatabaseService());

    test('returns completedSuccess once the target distance is reached', () {
      final Goal goal = buildGoal(
        targetKm: 100,
        targetDate: DateTime.now().add(const Duration(days: 10)),
      );

      expect(
        service.determineStatus(goal, 100),
        GoalCompletionStatus.completedSuccess,
      );
      expect(
        service.determineStatus(goal, 150),
        GoalCompletionStatus.completedSuccess,
      );
    });

    test(
      'returns completedFailure once the deadline has passed short of the target',
      () {
        final Goal goal = buildGoal(
          targetKm: 100,
          targetDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(
          service.determineStatus(goal, 40),
          GoalCompletionStatus.completedFailure,
        );
      },
    );

    test(
      'returns active while the deadline has not passed and the target is unmet',
      () {
        final Goal goal = buildGoal(
          targetKm: 100,
          targetDate: DateTime.now().add(const Duration(days: 10)),
        );

        expect(service.determineStatus(goal, 40), GoalCompletionStatus.active);
      },
    );
  });

  group('updateGoalStatus', () {
    test('persists completedSuccess with a completedAt timestamp', () async {
      final FakeGoalService goalService = FakeGoalService();
      final Goal goal = await goalService.insert(
        buildGoal(
          targetKm: 100,
          targetDate: DateTime.now().add(const Duration(days: 10)),
        ),
      );
      final FakeDatabaseService databaseService = FakeDatabaseService(
        initialRuns: [
          RunEntry(
            id: 1,
            kilometers: 100,
            date: DateTime.now(),
            goalId: goal.id,
          ),
        ],
      );
      final GoalCompletionService service = GoalCompletionService(
        goalService,
        databaseService,
      );

      await service.updateGoalStatus(goal.id);

      final Goal updated = (await goalService.getAll()).single;
      expect(updated.completionStatus, GoalCompletionStatus.completedSuccess);
      expect(updated.completedAt, isNotNull);
    });

    test('persists completedFailure once the deadline has passed', () async {
      final FakeGoalService goalService = FakeGoalService();
      final Goal goal = await goalService.insert(
        buildGoal(
          targetKm: 100,
          targetDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );
      final GoalCompletionService service = GoalCompletionService(
        goalService,
        FakeDatabaseService(),
      );

      await service.updateGoalStatus(goal.id);

      final Goal updated = (await goalService.getAll()).single;
      expect(updated.completionStatus, GoalCompletionStatus.completedFailure);
      expect(updated.completedAt, isNotNull);
    });

    test('does nothing once a goal is already finalized', () async {
      final FakeGoalService goalService = FakeGoalService();
      final DateTime firstCompletedAt = DateTime(2026, 1, 5);
      final Goal goal = await goalService.insert(
        buildGoal(
          targetKm: 100,
          targetDate: DateTime.now().add(const Duration(days: 10)),
          completionStatus: GoalCompletionStatus.completedFailure,
          completedAt: firstCompletedAt,
        ),
      );
      final GoalCompletionService service = GoalCompletionService(
        goalService,
        FakeDatabaseService(),
      );

      await service.updateGoalStatus(goal.id);

      final Goal unchanged = (await goalService.getAll()).single;
      expect(unchanged.completionStatus, GoalCompletionStatus.completedFailure);
      expect(unchanged.completedAt, firstCompletedAt);
    });

    test('leaves an in-progress goal untouched', () async {
      final FakeGoalService goalService = FakeGoalService();
      final Goal goal = await goalService.insert(
        buildGoal(
          targetKm: 100,
          targetDate: DateTime.now().add(const Duration(days: 10)),
        ),
      );
      final FakeDatabaseService databaseService = FakeDatabaseService(
        initialRuns: [
          RunEntry(id: 1, kilometers: 20, date: DateTime.now(), goalId: goal.id),
        ],
      );
      final GoalCompletionService service = GoalCompletionService(
        goalService,
        databaseService,
      );

      await service.updateGoalStatus(goal.id);

      final Goal unchanged = (await goalService.getAll()).single;
      expect(unchanged.completionStatus, GoalCompletionStatus.active);
      expect(unchanged.completedAt, isNull);
    });
  });
}
