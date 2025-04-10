import 'package:flutter/material.dart';
import 'package:recipe_list/rotas.dart';
import 'package:recipe_list/services/movie_service.dart';
import 'package:provider/provider.dart';

class MoviesScreen extends StatelessWidget {

  late int genreId;

  MoviesScreen({ super.key });

  @override
  Widget build(BuildContext context){

    final service = Provider.of<MovieService>(context);

    if (ModalRoute.of(context)!.settings.arguments != null) {
      if (ModalRoute.of(context)!.settings.arguments is int) {
        genreId = ModalRoute.of(context)!.settings.arguments as int;     
      }
    }

    final movies = service.findAllByGenre(genreId);

    return Scaffold(
      appBar: AppBar(title: const Text("Filmes")),
      body: movies.isEmpty
          ? const Center(child: Text("Gênero sem filmes"))
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  title: Text(movie.title),
                  onTap: () async {
                    await Navigator.pushNamed(context, Rotas.movie, arguments: movie.id);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Rotas.movie),
        tooltip: "Adicionar Filme",
        child: const Icon(Icons.add),
      ),
    );
  }
}