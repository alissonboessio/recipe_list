import 'package:recipe_list/models/base_model.dart';

class Ingredient extends BaseModel {
  static String tableName = 'ingredients';

  int? id;
  int recipeId;
  String name;
  String measure;
  int quantity;

  Ingredient({
    this.id,
    required this.recipeId,
    required this.name,
    required this.measure,
    required this.quantity,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'],
      recipeId: map['recipeId'],
      name: map['name'],
      measure: map['measure'],
      quantity: map['quantity'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'name': name,
      'measure': measure,
      'quantity': quantity,
    };
  }
}
