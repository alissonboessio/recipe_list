import 'package:recipe_list/models/ingredient.dart';

class IngredientRepository {
  final List<Ingredient> list = [
    Ingredient(id: 1, name: "carne", quantity: 2, recipeId: 1, measure: "kg"),
  ];

  List<Ingredient> get findAll => list;
  
  List<Ingredient> findAllByRecipe(int recipeId) {
    return list.where((obj) => obj.recipeId == recipeId).toList();
  }
  
  Ingredient? findById(int id) {
    return list.where((obj) => obj.id == id).firstOrNull;
  }

  void create(Ingredient obj) {
    list.add(Ingredient(quantity: obj.quantity, recipeId: obj.recipeId, name: obj.name, measure: obj.measure));
  }

  void update(Ingredient obj) {
    int index = list.indexWhere((movie) => movie.id == obj.id);
    list[index] = obj;
  }
  
  void delete(int id) {
    int index = list.indexWhere((ingredient) => ingredient.id == id);
    list.removeAt(index);
  }

}