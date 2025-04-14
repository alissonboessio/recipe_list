import 'package:recipe_list/models/ingredient.dart';
import 'package:recipe_list/models/instruction.dart';
import 'package:recipe_list/models/recipe.dart';

class CompleteRecipe {
  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<Instruction> instructions;

  CompleteRecipe({
    required this.recipe,
    required this.ingredients,
    required this.instructions,
  });
}
