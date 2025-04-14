import 'package:flutter/material.dart';
import 'package:recipe_list/models/ingredient.dart';
import 'package:recipe_list/repositories/repository.dart';

class IngredientService extends ChangeNotifier {
  // final IngredientRepository repository = IngredientRepository();
  final _repository = GenericRepository<Ingredient>(
    tableName: Ingredient.tableName,
    fromMap: Ingredient.fromMap,
  );

  Future<List<Ingredient>> get findAll => _repository.findAll();

  Future<List<Ingredient>> findAllByRecipe(int recipeId) {
    return _repository.findAllByRecipe(recipeId);
  }

  Future<Ingredient?> findById(int id) {
    return _repository.findById(id);
  }

  Future<int> createOrUpdate(Ingredient obj) async {
    final id = await _repository.createOrUpdate(obj);
    notifyListeners();
    return id;
  }

  // void update(Ingredient obj) {
  //   repository.update(obj);
  //   notifyListeners();
  // }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    notifyListeners();
  }
}

