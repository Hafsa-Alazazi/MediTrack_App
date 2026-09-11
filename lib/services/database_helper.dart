import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medication.dart';
import '../models/dose_log.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medi_track.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        reminderTimes TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
    await _createDoseLogsTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createDoseLogsTable(db);
    }
  }

  Future<void> _createDoseLogsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dose_logs (
        id TEXT PRIMARY KEY,
        medicationId TEXT NOT NULL,
        medicationName TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertMedication(Medication medication) async {
    final db = await database;
    await db.insert(
      'medications',
      medication.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Medication>> getAllMedications() async {
    final db = await database;
    final maps = await db.query('medications', orderBy: 'createdAt DESC');
    return maps.map((map) => Medication.fromDbMap(map)).toList();
  }

  Future<void> updateMedication(Medication medication) async {
    final db = await database;
    await db.update(
      'medications',
      medication.toDbMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  Future<void> deleteMedication(String id) async {
    final db = await database;
    await db.delete('dose_logs', where: 'medicationId = ?', whereArgs: [id]);
    await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertDoseLog(DoseLog log) async {
    final db = await database;
    await db.insert(
      'dose_logs',
      log.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DoseLog>> getAllDoseLogs() async {
    final db = await database;
    final maps = await db.query('dose_logs', orderBy: 'timestamp DESC');
    return maps.map((map) => DoseLog.fromDbMap(map)).toList();
  }

  Future<void> updateDoseLog(DoseLog log) async {
    final db = await database;
    await db.update(
      'dose_logs',
      log.toDbMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<void> deleteDoseLog(String id) async {
    final db = await database;
    await db.delete('dose_logs', where: 'id = ?', whereArgs: [id]);
  }
}
