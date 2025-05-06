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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            container_code TEXT,
            visual_aid_code TEXT,
            final_label_code TEXT,
            creation_date TEXT,
            status INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertRecord(RecordModel record) async {
    final db = await instance.database;
    return await db.insert('records', record.toMap());
  }

  Future<List<RecordModel>> getAllRecords() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      orderBy: 'creation_date DESC',
    );
    return List.generate(maps.length, (i) => RecordModel.fromMap(maps[i]));
  }
}
