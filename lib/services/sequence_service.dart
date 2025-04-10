
import 'package:flutter/material.dart';
import 'package:recipe_list/models/sequence.dart';
import 'package:recipe_list/repositories/prep_sequence_repository.dart';

class SequenceService extends ChangeNotifier {
  final SequenceRepository repository = SequenceRepository();

  List<Sequence> get findAll => repository.findAll; 


  List<Sequence> findAllByRecipe(int recipeId) {
    return repository.findAllByRecipe(recipeId);
  }

  Sequence? findById(int id) {
    return repository.findById(id);
  }

  void create(Sequence obj) {
    repository.create(obj);
    notifyListeners();
  }

  void update(Sequence obj) {
    repository.update(obj);
    notifyListeners();
  }

}