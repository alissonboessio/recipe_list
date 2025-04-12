
import 'package:flutter/material.dart';
import 'package:recipe_list/models/instruction.dart';
import 'package:recipe_list/repositories/instruction_repository.dart';

class InstructionService extends ChangeNotifier {
  final InstructionRepository repository = InstructionRepository();

  List<Instruction> get findAll => repository.findAll; 


  List<Instruction> findAllByRecipe(int recipeId) {
    var instructions = repository.findAllByRecipe(recipeId);
    instructions.sort((a, b) => a.order.compareTo(b.order));
    return instructions;
  }

  Instruction? findById(int id) {
    return repository.findById(id);
  }

  void create(Instruction obj) {
    repository.create(obj);
    notifyListeners();
  }

  void update(Instruction obj) {
    repository.update(obj);
    notifyListeners();
  }

  void delete(int id) {
    repository.delete(id);
    notifyListeners();
  }

}