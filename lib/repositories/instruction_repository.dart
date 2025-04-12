
import 'package:recipe_list/models/instruction.dart';

class InstructionRepository {
  final List<Instruction> list = [
    Instruction(id: 1, order: 1, instruction: "faer isso e aquilo", recipeId: 1),
  ];

  List<Instruction> get findAll => list;
  
  List<Instruction> findAllByRecipe(int recipeId) {
    return list.where((obj) => obj.recipeId == recipeId).toList();
  }
  
  Instruction? findById(int id) {
    return list.where((obj) => obj.id == id).firstOrNull;
  }

  void create(Instruction obj) {
    list.add(Instruction(order: obj.order, instruction: obj.instruction, recipeId: obj.recipeId));
  }

  void update(Instruction obj) {
    int index = list.indexWhere((movie) => movie.id == obj.id);
    list[index] = obj;
  }

  void delete(int id) {
    int index = list.indexWhere((instruction) => instruction.id == id);
    list.removeAt(index);
  }

}