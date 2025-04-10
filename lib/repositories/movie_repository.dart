import 'package:recipe_list/models/movie.dart';

class MovieRepository {
  final List<Movie> list = [
    Movie(id: 1, title: "O Resgate do Soldado Ryan", director: "Steven Spielberg", genreId: 1),
  ];

  List<Movie> get findAll => list;
  
  List<Movie> findAllByGenre(int genreId) {
    return list.where((obj) => obj.genreId == genreId).toList();
  }
  
  Movie? findById(int id) {
    return list.where((obj) => obj.id == id).firstOrNull;
  }

  void create(Movie obj) {
    final id = list.isNotEmpty ? list.last.id + 1 : 1;
    list.add(Movie(id: id, director: obj.director, genreId: obj.genreId, title: obj.title));
  }

  void update(Movie obj) {
    int index = list.indexWhere((movie) => movie.id == obj.id);
    list[index] = obj;
  }

}