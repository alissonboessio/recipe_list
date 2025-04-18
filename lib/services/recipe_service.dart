import 'package:flutter/material.dart';
import 'package:recipe_list/models/recipe.dart';
import 'package:recipe_list/repositories/repository.dart';

class RecipeService extends ChangeNotifier {
  final _repository = GenericRepository(
    tableName: Recipe.tableName,
    fromMap: Recipe.fromMap,
  );

  Future<List<Recipe>> get findAll => _repository.findAll();

  Future<Recipe?> findById(int id) {
    return _repository.findById(id);
  }

  Future<int> create(Recipe obj) {
    final id = _repository.create(obj);
    notifyListeners();
    return id;
  }

  Future<int> update(Recipe obj) {
    final id = _repository.update(obj);
    notifyListeners();
    return id;
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    notifyListeners();
  }
}
