import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/score.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('snake_game.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertScore(Score score) async {
    final db = await instance.database;
    return await db.insert('scores', score.toMap());
  }

  Future<List<Score>> getTopScores({int limit = 10}) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scores',
      orderBy: 'score DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Score.fromMap(maps[i]));
  }

  Future<void> deleteScore(int id) async {
    final db = await instance.database;
    await db.delete(
      'scores',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}