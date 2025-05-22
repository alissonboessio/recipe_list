import 'dart:math';

import 'package:flutter/material.dart';
import 'package:recipe_list/models/complete_recipe.dart';
import 'package:recipe_list/models/ingredient.dart';
import 'package:recipe_list/models/instruction.dart';
import 'package:recipe_list/models/recipe.dart';
import 'package:recipe_list/repositories/repository.dart';
import 'package:recipe_list/services/api_service.dart';

class RecipeService extends ChangeNotifier {
  final _repository = GenericRepository(
    tableName: Recipe.tableName,
    fromMap: Recipe.fromMap,
  );

  final _apiService = ApiService();

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

  Future<Recipe> createRandomRecipe() async {
    String txt = await _apiService.fetchRandomText();
    var parts = txt.split('.');
    var random = Random();
    int preparationTime = random.nextInt(60) + 1;
    int rating = random.nextInt(5) + 1;

    int partI = 0;

    Recipe recipe = Recipe(name: parts[partI], createdAt: DateTime.now(), preparationTime: preparationTime);
    partI++;
    recipe.rating = rating;

    recipe.id = await create(recipe);    

    final _repoIngredients = GenericRepository(
      tableName: Ingredient.tableName,
      fromMap: Ingredient.fromMap,
    );

    for (; partI < 5; partI++) {
      await _repoIngredients.create(Ingredient(recipeId: recipe.id!, name: parts[partI], measure: parts[partI].split(" ")[0], quantity: random.nextInt(10) + 1));
    }

    final _repoIntructions = GenericRepository(
      tableName: Instruction.tableName,
      fromMap: Instruction.fromMap,
    );

    for (var i = 1; partI < 9; partI++, i++) {
      await _repoIntructions.create(Instruction(recipeId: recipe.id!, instruction: parts[partI], instructionOrder: i));
    }

    return recipe;
  }
}
