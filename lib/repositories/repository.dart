import 'package:recipe_list/models/base_model.dart';
import 'package:recipe_list/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class GenericRepository<T extends BaseModel> {
  final String tableName;
  final T Function(Map<String, dynamic> map) fromMap;

  GenericRepository({required this.tableName, required this.fromMap});

  Future<Database> get _databaseInstance => DatabaseService().database;

  Future<int> createOrUpdate(T item) async {
    final db = await _databaseInstance;
    return await db.insert(
      tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  // Future<int> update(T item) async {
  //   final db = await _databaseInstance;
  //   return await db.update(
  //     tableName,
  //     item.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [item.id],
  //   );
  // }

  Future<int> delete(int id) async {
    final db = await _databaseInstance;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
