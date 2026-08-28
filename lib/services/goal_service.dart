import 'package:sqflite/sqflite.dart';

import '../models/activity_type.dart';
import '../models/goal.dart';
import 'database_service.dart';

class GoalService {
  GoalService(this._databaseService);

  final DatabaseService _databaseService;

  static const _tableName = 'goals';

  Future<Goal> insert(Goal goal) async {
    final Database db = await _databaseService.database;
    final int id = await db.insert(_tableName, _toRow(goal));
    return goal.copyWith(id: id);
  }

  Future<List<Goal>> getAll() async {
    final Database db = await _databaseService.database;
    final List<Map<String, Object?>> rows =
        await db.query(_tableName, orderBy: 'createdAt DESC');
    return rows.map(_fromRow).toList();
  }

  Future<Goal?> getActive() async {
    final Database db = await _databaseService.database;
    final List<Map<String, Object?>> rows = await db.query(
      _tableName,
      where: 'isActive = ?',
      whereArgs: [1],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<int> update(Goal goal) async {
    final Database db = await _databaseService.database;
    return db.update(
      _tableName,
      _toRow(goal),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> delete(int id) async {
    final Database db = await _databaseService.database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Deactivates every other goal and activates the one identified by [id].
  Future<void> setActive(int id) async {
    final Database db = await _databaseService.database;
    await db.transaction((Transaction txn) async {
      await txn.update(_tableName, {'isActive': 0});
      await txn.update(
        _tableName,
        {'isActive': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Map<String, dynamic> _toRow(Goal goal) => {
        'name': goal.name,
        'targetKm': goal.targetKm,
        'targetDate': goal.targetDate.toIso8601String(),
        'activityType': goal.activityType.name,
        'isActive': goal.isActive ? 1 : 0,
        'createdAt': goal.createdAt.toIso8601String(),
      };

  Goal _fromRow(Map<String, Object?> row) => Goal(
        id: row['id'] as int,
        name: row['name'] as String,
        targetKm: row['targetKm'] as double,
        targetDate: DateTime.parse(row['targetDate'] as String),
        activityType: ActivityType.values.byName(row['activityType'] as String),
        isActive: (row['isActive'] as int) == 1,
        createdAt: DateTime.parse(row['createdAt'] as String),
      );
}
