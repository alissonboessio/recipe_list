import 'package:flutter/material.dart';
import 'package:recipe_list/rotas.dart';
import 'package:recipe_list/services/genre_service.dart';
import 'package:provider/provider.dart';

class GenresScreen extends StatelessWidget {

  const GenresScreen({ super.key });

  @override
  Widget build(BuildContext context){

    final service = Provider.of<GenreService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Gêneros")),
      body: ListView.builder(
        itemCount: service.findAll.length,
        itemBuilder: (context, index) {
          final genre = service.findAll[index];
          return ListTile(
            title: Text(genre.description),
            onTap: () => Navigator.pushNamed(context, Rotas.movies, arguments: genre.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Rotas.genre);
        },
        tooltip: "Adicionar Gênero",
        child: const Icon(Icons.add),
      ),
    );
  }
}