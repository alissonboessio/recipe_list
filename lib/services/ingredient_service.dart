
import 'package:flutter/material.dart';
import 'package:recipe_list/models/ingredient.dart';
import 'package:recipe_list/repositories/ingredient_repository.dart';

class IngredientService extends ChangeNotifier {
  final IngredientRepository repository = IngredientRepository();

  List<Ingredient> get findAll => repository.findAll; 


  List<Ingredient> findAllByRecipe(int recipeId) {
    return repository.findAllByRecipe(recipeId);
  }

  Ingredient? findById(int id) {
    return repository.findById(id);
  }

  void create(Ingredient obj) {
    repository.create(obj);
    notifyListeners();
  }

  void update(Ingredient obj) {
    repository.update(obj);
    notifyListeners();
  }
  
  void delete(int id) {
    repository.delete(id);
    notifyListeners();
  }

}