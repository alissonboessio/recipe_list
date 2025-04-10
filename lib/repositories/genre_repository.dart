import 'package:recipe_list/models/genre.dart';

class GenreRepository {
  final List<Genre> list = [
    Genre(id: 1, description: "Ação"),
    Genre(id: 2, description: "Terror"),
  ];

  List<Genre> get findAll => list;

  Genre? findById(int id) {
    return list.where((obj) => obj.id == id).firstOrNull;
  }

  void create(Genre obj) {
    final id = list.isNotEmpty ? list.last.id + 1 : 1;
    list.add(Genre(id: id, description: obj.description));
  }

}