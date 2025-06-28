import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicine.dart';
import '../models/dose_history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medicine_reminder.db');
    // Bumping the version to 2 to trigger the onUpgrade method
    return await openDatabase(path, version: 2, onCreate: _createDb, onUpgrade: _onUpgrade);
  }

  // Handles database creation
  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        type TEXT NOT NULL,
        stock INTEGER NOT NULL,
        scheduleType TEXT NOT NULL,
        days TEXT,
        times TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE dose_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineId INTEGER NOT NULL,
        takenAt TEXT NOT NULL,
        FOREIGN KEY (medicineId) REFERENCES medicines (id) ON DELETE CASCADE
      )
    ''');
  }

  // Handles database upgrade. This simple migration will clear all existing data.
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS medicines');
    await db.execute('DROP TABLE IF EXISTS dose_history');
    _createDb(db, newVersion);
  }

  Future<int> insertMedicine(Medicine medicine) async {
    final db = await database;
    return await db.insert('medicines', medicine.toMap());
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medicines', orderBy: 'name ASC');
    return List.generate(maps.length, (i) {
      return Medicine.fromMap(maps[i]);
    });
  }

  Future<int> updateMedicine(Medicine medicine) async {
    final db = await database;
    return await db.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  Future<int> deleteMedicine(int id) async {
    final db = await database;
    // Also delete associated dose history
    await db.delete('dose_history', where: 'medicineId = ?', whereArgs: [id]);
    return await db.delete(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Dose History Methods ---

  Future<int> addDoseRecord(DoseHistory dose) async {
    final db = await database;
    return await db.insert('dose_history', dose.toMap());
  }

  Future<List<DoseHistory>> getDosesForDay(int medicineId, DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'dose_history',
      where: 'medicineId = ? AND takenAt >= ? AND takenAt <= ?',
      whereArgs: [medicineId, startOfDay, endOfDay],
    );

    return List.generate(maps.length, (i) => DoseHistory.fromMap(maps[i]));
  }

  Future<Map<DateTime, int>> getAdherenceForLastWeek() async {
    final db = await database;
    Map<DateTime, int> adherence = {};
    for (int i = 6; i >= 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      
      final allMeds = await getMedicines();
      int totalDosesForDay = 0;
      for (var med in allMeds) {
        // This logic needs to be improved to handle specific days of the week
        totalDosesForDay += med.times.length;
      }

      final takenDosesResult = await db.rawQuery('''
        SELECT COUNT(*) as count FROM dose_history
        WHERE takenAt >= ? AND takenAt < ?
      ''', [startOfDay.toIso8601String(), startOfDay.add(Duration(days: 1)).toIso8601String()]);

      int takenDoses = Sqflite.firstIntValue(takenDosesResult) ?? 0;

      if (totalDosesForDay == 0) {
        adherence[startOfDay] = 100; // Or 0, depending on desired behavior
      } else {
        adherence[startOfDay] = ((takenDoses / totalDosesForDay) * 100).round();
      }
    }
    return adherence;
  }
}
