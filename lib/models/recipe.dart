import 'package:recipe_list/models/base_model.dart';

class Recipe extends BaseModel {
  static String tableName = 'recipes';

  int? id;
  String name;
  int? rating; // (0 - 5 stars)
  final DateTime createdAt;
  int preparationTime; // in minutes

  Recipe({
    this.id,
    required this.name,
    required this.createdAt,
    required this.preparationTime,
    this.rating,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      rating: map['rating'],
      preparationTime: map['preparationTime'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'preparationTime': preparationTime,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
