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

    // ถ้ามีการแก้ Structure Table อาจจะต้องเพิ่ม version เป็น 2 แต่ถ้าเพิ่งเริ่ม dev ใช้ 1 ได้ครับ
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. ตารางเก็บผลการทดลอง (อันเดิมของคุณ)
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

    // 2. ✅ เพิ่มตารางเก็บรูปโปรไฟล์ (อันใหม่สำหรับ Hybrid Mode)
    await db.execute('''
      CREATE TABLE user_images (
        uid TEXT PRIMARY KEY,
        image_path TEXT
      )
    ''');
  }

  // ====================================================
  // 🔬 ส่วนจัดการ Experiment Data (ของเดิม)
  // ====================================================

  Future<int> insertExperiment(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('experiments', row);
  }

  Future<List<Map<String, dynamic>>> getAllExperiments() async {
    final db = await instance.database;
    return await db.query('experiments', orderBy: 'timestamp DESC');
  }

  // ====================================================
  // 👤 ส่วนจัดการ User Profile Image (เพิ่มใหม่)
  // ====================================================

  // บันทึก Path รูปภาพ (ถ้ามี UID นี้อยู่แล้วให้ทับเลย)
  Future<void> saveProfileImage(String uid, String path) async {
    final db = await instance.database;
    await db.insert(
      'user_images',
      {'uid': uid, 'image_path': path},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ดึง Path รูปภาพ
  Future<String?> getProfileImage(String uid) async {
    final db = await instance.database;
    final maps = await db.query(
      'user_images',
      columns: ['image_path'],
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return maps.first['image_path'] as String;
    } else {
      return null;
    }
  }
}