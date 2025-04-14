// import 'package:recipe_list/models/instruction.dart';
// import 'package:recipe_list/services/database_service.dart';
// import 'package:sqflite/sqflite.dart';
//
// class InstructionRepository {
//   InstructionRepository._(this._db);
//
//   static Future<InstructionRepository> start() async {
//     final dbInstance = await DatabaseService().database;
//     return InstructionRepository._(dbInstance);
//   }
//
//   final Database _db;
//   final String _dbTable = 'instructions';
//
//   // final List<Instruction> list = [
//   //   Instruction(
//   //     id: 1,
//   //     order: 1,
//   //     instruction: "faer isso e aquilo",
//   //     recipeId: 1,
//   //   ),
//   // ];
//
//   Future<List<Instruction>> findAll() async {
//     final data = await _db.query(_dbTable);
//     return data.map((element) => Ingredient.fromMap(element)).toList();
//   }
//
//   List<Instruction> findAllByRecipe(int recipeId) {
//     return list.where((obj) => obj.recipeId == recipeId).toList();
//   }
//
//   Instruction? findById(int id) {
//     return list.where((obj) => obj.id == id).firstOrNull;
//   }
//
//   void create(Instruction obj) {
//     list.add(
//       Instruction(
//         order: obj.order,
//         instruction: obj.instruction,
//         recipeId: obj.recipeId,
//       ),
//     );
//   }
//
//   void update(Instruction obj) {
//     int index = list.indexWhere((movie) => movie.id == obj.id);
//     list[index] = obj;
//   }
//
//   void delete(int id) {
//     int index = list.indexWhere((instruction) => instruction.id == id);
//     list.removeAt(index);
//   }
// }
//

