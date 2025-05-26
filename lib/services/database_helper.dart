import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:veriflow/models/record_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('veriflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            container_code TEXT,
            visual_aid_code TEXT,
            final_label_code TEXT,
            creation_date TEXT,
            status INTEGER,
            is_synced INTEGER DEFAULT 0,
            record_id INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE records ADD COLUMN is_synced INTEGER DEFAULT 0');
        }

        if (oldVersion < 3) {
          await db.execute('ALTER TABLE records ADD COLUMN record_id INTEGER');
        }
      },
    );
  }

  Future<int> insertRecord(RecordModel record) async {
    final db = await instance.database;
    return await db.insert('records', record.toMap());
  }

  Future<int> updateRecordSyncStatus(int id, bool isSynced) async {
    final db = await instance.database;
    return await db.update(
      'records',
      {'is_synced': isSynced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<RecordModel>> getUnsyncedRecords() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'creation_date ASC',
    );
    return List.generate(maps.length, (i) => RecordModel.fromMap(maps[i]));
  }

  Future<List<RecordModel>> getAllRecords() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      orderBy: 'creation_date DESC',
    );
    return List.generate(maps.length, (i) => RecordModel.fromMap(maps[i]));
  }

  Future<int> updateRecordServerId(int localId, int serverRecordId) async {
    final db = await instance.database;
    return await db.update(
      'records',
      {'record_id': serverRecordId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<int> updateRecordReferences(int oldRecordId, int newRecordId) async {
    final db = await instance.database;
    return await db.update(
      'records',
      {'record_id': newRecordId},
      where: 'record_id = ?',
      whereArgs: [oldRecordId],
    );
  }

  Future<List<RecordModel>> getRecordsByServerId(int recordId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      where: 'record_id = ?',
      whereArgs: [recordId],
    );
    return List.generate(maps.length, (i) => RecordModel.fromMap(maps[i]));
  }
}
