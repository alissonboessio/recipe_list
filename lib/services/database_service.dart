import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // singleton
  factory DatabaseService() => _instance;
  DatabaseService.internal();
  static final DatabaseService _instance = DatabaseService.internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/recipe_list.db';
    // await deleteDatabase(path);
    return openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final batch = db.batch();
    await batch.commit();
  }

  void _onConfigure(Database db) {
    db.execute('PRAGMA foreign_keys = ON');
  }

  // Create tables and perform initial setup
  void _onCreate(Database db, int version) {
    db
      ..execute(
        'CREATE TABLE recipes(id INTEGER PRIMARY KEY, name TEXT, grade INTEGER, prepare_time INTEGER, created_at INTEGER)',
      ) // created_at (unix timestamp in seconds) prepare_time (seconds)
      ..execute(''' 
        CREATE TABLE ingredients(
        id INTEGER PRIMARY KEY,
        name TEXT,
        quantity INTEGER,
        measure TEXT,
        recipe_id INTEGER,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id)
        )
       ''') // measure can be grams, cups, tablespoons etc
      ..execute('''
        CREATE TABLE instructions(
        id INTEGER PRIMARY KEY,
        order INTEGER,
        instruction TEXT,
        recipe_id INTEGER,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id)
        )
        ''');
  }
}
