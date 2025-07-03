import 'dart:io';

import 'package:path/path.dart';
import 'package:recipe_list/models/ingredient.dart';
import 'package:recipe_list/models/instruction.dart';
import 'package:recipe_list/models/recipe.dart';
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
    final path = join(databasePath, 'recipe_list.db');
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
      ..execute('''
        CREATE TABLE recipes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        rating INTEGER,
        preparationTime INTEGER,
        createdAt INTEGER
        )
        ''') // created_at (unix timestamp in seconds) prepare_time (seconds)
      ..execute('''
      CREATE TABLE ingredients(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      quantity INTEGER,
      measure TEXT,
      recipeId INTEGER NOT NULL,
      FOREIGN KEY (recipeId) REFERENCES recipes(id) ON DELETE CASCADE
      )
     ''') // measure can be grams, cups, tablespoons etc
      ..execute('''
      CREATE TABLE instructions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      instructionOrder INTEGER NOT NULL,
      instruction TEXT NOT NULL,
      recipeId INTEGER NOT NULL,
      FOREIGN KEY (recipeId) REFERENCES recipes(id) ON DELETE CASCADE
      )
      ''')
      ..insert(
        'recipes',
        Recipe(
          id: 1,
          name: "Nhoque",
          rating: 5,
          preparationTime: 30,
          createdAt: DateTime.now(),
        ).toMap(),
      )
      ..insert(
        'recipes',
        Recipe(
          id: 2,
          name: "Carne de sol",
          rating: 4,
          preparationTime: 45,
          createdAt: DateTime.now(),
        ).toMap(),
      )
      ..insert(
        'ingredients',
        Ingredient(
          id: 1,
          name: "carne",
          quantity: 2,
          recipeId: 1,
          measure: "kg",
        ).toMap(),
      )
      ..insert(
        'instructions',
        Instruction(
          id: 1,
          instructionOrder: 0,
          instruction: "fazer isso e aquilo",
          recipeId: 1,
        ).toMap(),
      );
  }

  Future<File> getSourceDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final source = File('$dbPath/recipe_list.db');

    return source;
  }
}
