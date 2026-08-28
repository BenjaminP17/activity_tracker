import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/run_entry.dart';

class DatabaseService {
  DatabaseService({this._path});

  static const _dbName = 'activity_tracker.db';
  static const _tableName = 'runs';
  static const _goalsTableName = 'goals';
  static const _dbVersion = 4;

  final String? _path;
  Database? _db;

  /// The underlying database connection, shared with other services (e.g.
  /// [GoalService]) so they operate on the same schema and file.
  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = _path ?? join(await getDatabasesPath(), _dbName);
    return openDatabase(
      dbPath,
      version: _dbVersion,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_goalsTableName (
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
          CREATE TABLE $_tableName (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            kilometers REAL    NOT NULL,
            date      TEXT    NOT NULL,
            notes     TEXT,
            goalId    INTEGER REFERENCES $_goalsTableName (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE $_goalsTableName (
              id         INTEGER PRIMARY KEY AUTOINCREMENT,
              targetKm   REAL    NOT NULL,
              targetDate TEXT    NOT NULL,
              isActive   INTEGER NOT NULL,
              createdAt  TEXT    NOT NULL
            )
          ''');
          await db.execute(
            'ALTER TABLE $_tableName ADD COLUMN goalId INTEGER REFERENCES $_goalsTableName (id)',
          );
        }
        if (oldVersion < 4) {
          await db.execute(
            "ALTER TABLE $_goalsTableName ADD COLUMN name TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE $_goalsTableName ADD COLUMN activityType TEXT NOT NULL DEFAULT 'running'",
          );
        }
      },
    );
  }

  Future<RunEntry> insert(RunEntry entry) async {
    final db = await database;
    final id = await db.insert(_tableName, _toRow(entry));
    return entry.copyWith(id: id);
  }

  Future<List<RunEntry>> getAll() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'date DESC');
    return rows.map(_fromRow).toList();
  }

  Future<RunEntry?> getById(int id) async {
    final db = await database;
    final rows =
        await db.query(_tableName, where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<int> update(RunEntry entry) async {
    final db = await database;
    return db.update(
      _tableName,
      _toRow(entry),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> _toRow(RunEntry entry) => {
        'kilometers': entry.kilometers,
        'date': entry.date.toIso8601String(),
        'notes': entry.notes,
        'goalId': entry.goalId,
      };

  RunEntry _fromRow(Map<String, dynamic> row) => RunEntry(
        id: row['id'] as int,
        kilometers: row['kilometers'] as double,
        date: DateTime.parse(row['date'] as String),
        notes: row['notes'] as String?,
        goalId: row['goalId'] as int?,
      );

  Future<void> close() async => _db?.close();
}
