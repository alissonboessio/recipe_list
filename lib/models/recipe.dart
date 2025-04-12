class Recipe {
  int id;
  String name;
  int? rating; // (0 - 5 stars)
  DateTime createdAt = DateTime.now();
  int preparationTime; // in minutes
  
  Recipe({required this.id, required this.name, this.rating, required this.preparationTime});
}