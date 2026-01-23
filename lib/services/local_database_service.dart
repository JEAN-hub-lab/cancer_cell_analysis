import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cancer_cell_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // สร้างตารางเก็บข้อมูล (Schema ต้องตรงกับที่เรา Save)
    await db.execute('''
      CREATE TABLE experiments ( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        project_id TEXT,
        drug_name TEXT,
        concentration REAL,
        colony_count INTEGER,
        avg_size REAL,
        image_path TEXT,
        timestamp TEXT
      )
    ''');
  }

  // ฟังก์ชันบันทึก (Insert)
  Future<int> insertExperiment(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('experiments', row);
  }

  // ฟังก์ชันดึงข้อมูล (Query) - เผื่อเอาไปโชว์ตอนไม่มีเน็ต
  Future<List<Map<String, dynamic>>> getAllExperiments() async {
    final db = await instance.database;
    return await db.query('experiments', orderBy: 'timestamp DESC');
  }
}