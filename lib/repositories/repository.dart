import 'package:recipe_list/models/base_model.dart';
import 'package:recipe_list/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class GenericRepository<T extends BaseModel> {
  final String tableName;
  final T Function(Map<String, dynamic> map) fromMap;

  GenericRepository({required this.tableName, required this.fromMap});

  Future<Database> get _databaseInstance => DatabaseService().database;

  Future<int> create(T item) async {
    final db = await _databaseInstance;

    final val = await db.insert(
      tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return val;
  }

  Future<T?> findById(int id) async {
    final db = await _databaseInstance;
    final data = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (data.isNotEmpty) {
      return fromMap(data.first);
    }
    return null;
  }

  Future<List<T>> findAll() async {
    final db = await _databaseInstance;
    final data = await db.query(tableName);
    return data.map(fromMap).toList();
  }

  Future<List<T>> findAllByRecipe(int id) async {
    final db = await _databaseInstance;
    final data = await db.query(
      tableName,
      where: 'recipeId = ?',
      whereArgs: [id],
    );
    return data.map(fromMap).toList();
  }

  Future<int> update(T item, {bool backUpNow = true}) async {
    final db = await _databaseInstance;
    final val = await db.update(
      tableName,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );

    return val;
  }

  Future<int> delete(int id) async {
    final db = await _databaseInstance;
    final val = await db.delete(tableName, where: 'id = ?', whereArgs: [id]);

    return val;
  }
}
