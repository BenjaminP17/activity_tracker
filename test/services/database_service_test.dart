import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:activity_tracker/models/activity_type.dart';
import 'package:activity_tracker/models/goal.dart';
import 'package:activity_tracker/models/run_entry.dart';
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
    name: 'Marathon Challenge',
    targetKm: 100,
    targetDate: DateTime(2026, 12, 31),
    activityType: ActivityType.running,
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
    test('activates only the given goal and deactivates the others', () async {
      final Goal first = await goalService.insert(buildGoal(isActive: true));
      final Goal second = await goalService.insert(buildGoal());

      await goalService.setActive(second.id);
      final List<Goal> goals = await goalService.getAll();
      final List<Goal> activeGoals = goals
          .where((Goal goal) => goal.isActive)
          .toList();

      expect(activeGoals, hasLength(1));
      expect(activeGoals.single.id, second.id);
      expect(
        goals.firstWhere((Goal goal) => goal.id == first.id).isActive,
        isFalse,
      );
    });
  });

  group('DatabaseService.insert healthConnectUuid uniqueness', () {
    RunEntry buildRun({String? healthConnectUuid}) => RunEntry(
      id: 0,
      kilometers: 7,
      date: DateTime(2026, 8, 30),
      healthConnectUuid: healthConnectUuid,
    );

    test('rejects a second run with the same healthConnectUuid', () async {
      await databaseService.insert(buildRun(healthConnectUuid: 'hc-uuid-1'));

      expect(
        () => databaseService.insert(buildRun(healthConnectUuid: 'hc-uuid-1')),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('allows multiple runs with no healthConnectUuid', () async {
      await databaseService.insert(buildRun());
      await databaseService.insert(buildRun());

      final List<RunEntry> runs = await databaseService.getAll();

      expect(runs, hasLength(2));
    });
  });

  group('DatabaseService.existsByHealthConnectUuid', () {
    test('returns true only for a uuid that was already inserted', () async {
      await databaseService.insert(
        RunEntry(
          id: 0,
          kilometers: 7,
          date: DateTime(2026, 8, 30),
          healthConnectUuid: 'hc-uuid-2',
        ),
      );

      expect(
        await databaseService.existsByHealthConnectUuid('hc-uuid-2'),
        isTrue,
      );
      expect(
        await databaseService.existsByHealthConnectUuid('unknown-uuid'),
        isFalse,
      );
    });
  });

  group('DatabaseService migration v3 -> v4', () {
    late String dbPath;

    setUp(() {
      dbPath = join(
        Directory.systemTemp.path,
        'migration_test_${DateTime.now().microsecondsSinceEpoch}.db',
      );
    });

    tearDown(() async {
      final File file = File(dbPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('adds name and activityType columns with sensible defaults', () async {
      final Database legacyDb = await openDatabase(
        dbPath,
        version: 3,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE goals (
              id         INTEGER PRIMARY KEY AUTOINCREMENT,
              targetKm   REAL    NOT NULL,
              targetDate TEXT    NOT NULL,
              isActive   INTEGER NOT NULL,
              createdAt  TEXT    NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE runs (
              id        INTEGER PRIMARY KEY AUTOINCREMENT,
              kilometers REAL    NOT NULL,
              date      TEXT    NOT NULL,
              notes     TEXT,
              goalId    INTEGER REFERENCES goals (id)
            )
          ''');
        },
      );
      final int legacyId = await legacyDb.insert('goals', {
        'targetKm': 100.0,
        'targetDate': DateTime(2026, 12, 31).toIso8601String(),
        'isActive': 1,
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      });
      await legacyDb.close();

      final DatabaseService migratedService = DatabaseService(path: dbPath);
      final GoalService migratedGoalService = GoalService(migratedService);

      final List<Goal> goals = await migratedGoalService.getAll();

      expect(goals, hasLength(1));
      expect(goals.single.id, legacyId);
      expect(goals.single.name, isEmpty);
      expect(goals.single.activityType, ActivityType.running);
      expect(goals.single.targetKm, 100);

      await migratedService.close();
    });
  });

  group('DatabaseService migration v4 -> v5', () {
    late String dbPath;

    setUp(() {
      dbPath = join(
        Directory.systemTemp.path,
        'migration_v5_test_${DateTime.now().microsecondsSinceEpoch}.db',
      );
    });

    tearDown(() async {
      final File file = File(dbPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('adds the healthConnectUuid column, keeps existing runs, and '
        'enforces uniqueness on it', () async {
      final Database legacyDb = await openDatabase(
        dbPath,
        version: 4,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE goals (
              id           INTEGER PRIMARY KEY AUTOINCREMENT,
              name         TEXT    NOT NULL,
              targetKm     REAL    NOT NULL,
              targetDate   TEXT    NOT NULL,
              activityType TEXT    NOT NULL,
              isActive     INTEGER NOT NULL,
              createdAt    TEXT    NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE runs (
              id        INTEGER PRIMARY KEY AUTOINCREMENT,
              kilometers REAL    NOT NULL,
              date      TEXT    NOT NULL,
              notes     TEXT,
              goalId    INTEGER REFERENCES goals (id)
            )
          ''');
        },
      );
      final int legacyRunId = await legacyDb.insert('runs', {
        'kilometers': 5.0,
        'date': DateTime(2026, 8, 1).toIso8601String(),
      });
      await legacyDb.close();

      final DatabaseService migratedService = DatabaseService(path: dbPath);

      final List<RunEntry> runs = await migratedService.getAll();
      expect(runs, hasLength(1));
      expect(runs.single.id, legacyRunId);
      expect(runs.single.healthConnectUuid, isNull);

      await migratedService.insert(
        RunEntry(
          id: 0,
          kilometers: 7,
          date: DateTime(2026, 8, 30),
          healthConnectUuid: 'hc-uuid-migrated',
        ),
      );
      expect(
        () => migratedService.insert(
          RunEntry(
            id: 0,
            kilometers: 3,
            date: DateTime(2026, 8, 30),
            healthConnectUuid: 'hc-uuid-migrated',
          ),
        ),
        throwsA(isA<DatabaseException>()),
      );

      await migratedService.close();
    });
  });

  group('DatabaseService migration v5 -> v6', () {
    late String dbPath;

    setUp(() {
      dbPath = join(
        Directory.systemTemp.path,
        'migration_v6_test_${DateTime.now().microsecondsSinceEpoch}.db',
      );
    });

    tearDown(() async {
      final File file = File(dbPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test(
      'adds the completionStatus and completedAt columns, defaulting '
      'existing goals to active',
      () async {
        final Database legacyDb = await openDatabase(
          dbPath,
          version: 5,
          onCreate: (db, _) async {
            await db.execute('''
              CREATE TABLE goals (
                id           INTEGER PRIMARY KEY AUTOINCREMENT,
                name         TEXT    NOT NULL,
                targetKm     REAL    NOT NULL,
                targetDate   TEXT    NOT NULL,
                activityType TEXT    NOT NULL,
                isActive     INTEGER NOT NULL,
                createdAt    TEXT    NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE runs (
                id        INTEGER PRIMARY KEY AUTOINCREMENT,
                kilometers REAL    NOT NULL,
                date      TEXT    NOT NULL,
                notes     TEXT,
                goalId    INTEGER REFERENCES goals (id),
                healthConnectUuid TEXT
              )
            ''');
          },
        );
        final int legacyGoalId = await legacyDb.insert('goals', {
          'name': 'Marathon Challenge',
          'targetKm': 100.0,
          'targetDate': DateTime(2026, 12, 31).toIso8601String(),
          'activityType': 'running',
          'isActive': 1,
          'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        });
        await legacyDb.close();

        final DatabaseService migratedService = DatabaseService(path: dbPath);
        final GoalService migratedGoalService = GoalService(migratedService);

        final List<Goal> goals = await migratedGoalService.getAll();

        expect(goals, hasLength(1));
        expect(goals.single.id, legacyGoalId);
        expect(goals.single.completionStatus, GoalCompletionStatus.active);
        expect(goals.single.completedAt, isNull);

        await migratedGoalService.update(
          goals.single.copyWith(
            completionStatus: GoalCompletionStatus.completedSuccess,
            completedAt: DateTime(2026, 6, 1),
          ),
        );
        final Goal updated = (await migratedGoalService.getAll()).single;
        expect(updated.completionStatus, GoalCompletionStatus.completedSuccess);
        expect(updated.completedAt, DateTime(2026, 6, 1));

        await migratedService.close();
      },
    );
  });
}
