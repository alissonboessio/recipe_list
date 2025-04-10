
import 'package:flutter/material.dart';
import 'package:recipe_list/models/movie.dart';
import 'package:recipe_list/repositories/movie_repository.dart';

class MovieService extends ChangeNotifier {
  final MovieRepository repository = MovieRepository();

  List<Movie> get findAll => repository.findAll; 


  List<Movie> findAllByGenre(int genreId) {
    return repository.findAllByGenre(genreId);
  }

  Movie? findById(int id) {
    return repository.findById(id);
  }

  void create(Movie obj) {
    repository.create(obj);
    notifyListeners();
  }

  void update(Movie obj) {
    repository.update(obj);
    notifyListeners();
  }

}