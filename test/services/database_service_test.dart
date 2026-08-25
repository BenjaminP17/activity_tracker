import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:activity_tracker/models/goal.dart';
import 'package:activity_tracker/services/database_service.dart';
import 'package:activity_tracker/services/goal_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseService databaseService;
  late GoalService goalService;

  setUp(() {
    databaseService = DatabaseService(path: inMemoryDatabasePath);
    goalService = GoalService(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
  });

  Goal buildGoal({bool isActive = false}) => Goal(
        id: 0,
        targetKm: 100,
        targetDate: DateTime(2026, 12, 31),
        isActive: isActive,
        createdAt: DateTime(2026, 1, 1),
      );

  group('GoalService CRUD', () {
    test('insert returns the goal with a generated id', () async {
      final Goal inserted = await goalService.insert(buildGoal());

      expect(inserted.id, greaterThan(0));
    });

    test('getAll returns every inserted goal', () async {
      await goalService.insert(buildGoal());
      await goalService.insert(buildGoal());

      final List<Goal> goals = await goalService.getAll();

      expect(goals, hasLength(2));
    });

    test('getActive returns only the active goal', () async {
      await goalService.insert(buildGoal());
      final Goal active = await goalService.insert(buildGoal(isActive: true));

      final Goal? result = await goalService.getActive();

      expect(result?.id, active.id);
    });

    test('update persists changes to a goal', () async {
      final Goal inserted = await goalService.insert(buildGoal());

      await goalService.update(inserted.copyWith(targetKm: 250));
      final List<Goal> goals = await goalService.getAll();

      expect(goals.single.targetKm, 250);
    });

    test('delete removes the goal', () async {
      final Goal inserted = await goalService.insert(buildGoal());

      await goalService.delete(inserted.id);
      final List<Goal> goals = await goalService.getAll();

      expect(goals, isEmpty);
    });
  });

  group('GoalService.setActive', () {
    test('activates only the given goal and deactivates the others',
        () async {
      final Goal first = await goalService.insert(buildGoal(isActive: true));
      final Goal second = await goalService.insert(buildGoal());

      await goalService.setActive(second.id);
      final List<Goal> goals = await goalService.getAll();
      final List<Goal> activeGoals =
          goals.where((Goal goal) => goal.isActive).toList();

      expect(activeGoals, hasLength(1));
      expect(activeGoals.single.id, second.id);
      expect(
        goals.firstWhere((Goal goal) => goal.id == first.id).isActive,
        isFalse,
      );
    });
  });
}
