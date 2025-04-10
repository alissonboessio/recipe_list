
import 'package:recipe_list/models/sequence.dart';

class SequenceRepository {
  final List<Sequence> list = [
    Sequence(id: 1, order: 1, instruction: "faer isso e aquilo", recipeId: 1),
  ];

  List<Sequence> get findAll => list;
  
  List<Sequence> findAllByRecipe(int recipeId) {
    return list.where((obj) => obj.recipeId == recipeId).toList();
  }
  
  Sequence? findById(int id) {
    return list.where((obj) => obj.id == id).firstOrNull;
  }

  void create(Sequence obj) {
    final id = list.isNotEmpty ? list.last.id + 1 : 1;
    list.add(Sequence(id: id, order: obj.order, instruction: obj.instruction, recipeId: obj.recipeId));
  }

  void update(Sequence obj) {
    int index = list.indexWhere((movie) => movie.id == obj.id);
    list[index] = obj;
  }

}