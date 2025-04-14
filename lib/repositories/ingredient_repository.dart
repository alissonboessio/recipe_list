// import 'package:recipe_list/models/ingredient.dart';
// import 'package:recipe_list/services/database_service.dart';
// import 'package:sqflite/sqflite.dart';
//
// class IngredientRepository {
//   IngredientRepository._(this._db);
//
//   static Future<IngredientRepository> start() async {
//     final dbInstance = await DatabaseService().database;
//     return IngredientRepository._(dbInstance);
//   }
//
//   final Database _db;
//   final String _dbTable = 'ingredients';
//
//   // final List<Ingredient> list = [
//   //   Ingredient(id: 1, name: "carne", quantity: 2, recipeId: 1, measure: "kg"),
//   // ];
//
//   Future<List<Ingredient>> findAll() async {
//     final data = await _db.query(_dbTable);
//     return data.map((element) => Ingredient.fromMap(element)).toList();
//   }
//
//   Future<List<Ingredient>> findAllByRecipe(int recipeId) async {
//     final data = await _db.query(
//       _dbTable,
//       where: 'recipeId = ?',
//       whereArgs: [recipeId],
//     );
//     return data.map((element) => Ingredient.fromMap(element)).toList();
//   }
//
//   Future<Ingredient?> findById(int id) async {
//     final data = await _db.query(_dbTable, where: 'id = ?', whereArgs: [id]);
//     return data
//         .map((element) => Ingredient.fromMap(element))
//         .toList()
//         .firstOrNull;
//   }
//
//   Future<int> createOrUpdate(Ingredient obj) async {
//     final id = await _db.insert(
//       _dbTable,
//       obj.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//
//     return id;
//   }
//
//   // void update(Ingredient obj) {
//   //   int index = list.indexWhere((movie) => movie.id == obj.id);
//   //   list[index] = obj;
//   // }
//
//   Future<void> delete(int id) async {
//     await _db.delete(_dbTable, where: 'id = ?', whereArgs: [id]);
//   }
// }
//

