
import 'package:flutter/material.dart';
import 'package:recipe_list/models/recipe.dart';
import 'package:recipe_list/repositories/recipe_repository.dart';

class RecipeService extends ChangeNotifier {
  final RecipeRepository repository = RecipeRepository();

  List<Recipe> get findAll => repository.findAll; 

  Recipe? findById(int id) {
    return repository.findById(id);
  }

  void create(Recipe obj) {
    // repository.create(obj);
    notifyListeners();
  }

}