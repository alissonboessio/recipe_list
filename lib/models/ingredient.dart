class Ingredient {
  int? id;
  int recipeId;
  String name;
  String measure;
  double quantity;
  
  Ingredient({this.id = null, required this.recipeId, required this.name, required this.measure, required this.quantity});
}