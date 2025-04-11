import 'package:recipe_list/models/recipe.dart';

class RecipeRepository {
  final List<Recipe> list = [
    Recipe(id: 1, name: "Nhoque", rating: 5, preparationTime: 30),
    Recipe(id: 2, name: "Carne de sol", rating: 4, preparationTime: 45),
  ];

  List<Recipe> get findAll => list;

  Recipe? findById(int id) {
    return list.where((obj) => obj.id == id).firstOrNull;
  }

  // void create(Recipe obj) {
  //   final id = list.isNotEmpty ? list.last.id + 1 : 1;
  //   list.add(Recipe(id: id, name: obj.name));
  // }

}