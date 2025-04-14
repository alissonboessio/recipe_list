import 'package:flutter/material.dart';
import 'package:recipe_list/models/instruction.dart';
import 'package:recipe_list/repositories/repository.dart';

class InstructionService extends ChangeNotifier {
  final _repository = GenericRepository<Instruction>(
    tableName: Instruction.tableName,
    fromMap: Instruction.fromMap,
  );

  Future<List<Instruction>> get findAll => _repository.findAll();

  Future<List<Instruction>> findAllByRecipe(int recipeId) async {
    final instructions = await _repository.findAllByRecipe(recipeId);
    instructions.sort(
      (a, b) => a.instructionOrder.compareTo(b.instructionOrder),
    );
    return instructions;
  }

  Future<Instruction?> findById(int id) {
    return _repository.findById(id);
  }

  Future<int> createOrUpdate(Instruction obj) {
    final id = _repository.createOrUpdate(obj);
    notifyListeners();
    return id;
  }

  // void update(Instruction obj) {
  //   repository.update(obj);
  //   notifyListeners();
  // }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    notifyListeners();
  }
}

