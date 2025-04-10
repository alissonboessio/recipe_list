import 'package:flutter/material.dart';
import 'package:recipe_list/models/genre.dart';
import 'package:recipe_list/models/movie.dart';
import 'package:recipe_list/services/genre_service.dart';
import 'package:recipe_list/services/movie_service.dart';
import 'package:provider/provider.dart';

class MovieScreen extends StatefulWidget {
  MovieScreen({ super.key });

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  Movie? movie;
  Genre? selectedGenre;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // utilizado para iniciar o estado da tela caso seja uma edição
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = Provider.of<MovieService>(context, listen: false);
      final serviceGenre = Provider.of<GenreService>(context, listen: false);

      final arguments = ModalRoute.of(context)?.settings.arguments;

      if (arguments is int) {
        final fetchedMovie = service.findById(arguments);
        if (fetchedMovie != null) {
          setState(() {
            movie = fetchedMovie;
            _titleController.text = movie!.title;
            _directorController.text = movie!.director;
            selectedGenre = serviceGenre.findById(movie!.genreId);
          });
        }
      }

    });      
    
  }

  @override
  Widget build(BuildContext context){
    
    final service = Provider.of<MovieService>(context, listen: false);
    final serviceGenre = Provider.of<GenreService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Filme"),),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título do Filme'),
                validator: (value) => value!.isEmpty ? 'Título é obrigatório!' : null,
              ),

              SizedBox(height: 15,),

              TextFormField(
                controller: _directorController,
                decoration: const InputDecoration(labelText: 'Diretor do Filme'),
                validator: (value) => value!.isEmpty ? 'Diretor é obrigatório!' : null,
              ),

              SizedBox(height: 15,),

              DropdownButtonFormField<Genre>(
                decoration: const InputDecoration(labelText: "Gênero"),
                value: selectedGenre,
                items: serviceGenre.findAll.map((genre) {
                  return DropdownMenuItem(
                    value: genre,
                    child: Text(genre.description),
                  );
                }).toList(),
                onChanged: (genre) {
                  setState(() {
                    selectedGenre = genre;
                  });
                },
                validator: (value) => value == null ? 'Selecione um gênero' : null,
              ),

              SizedBox(height: 30,),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final title = _titleController.text;
                    final director = _directorController.text;

                    final updMovie = Movie(
                      id: movie?.id ?? 0, 
                      title: title,
                      director: director,
                      genreId: selectedGenre!.id,
                    );

                    if (movie == null) {
                      service.create(updMovie);
                    } else {
                      service.update(updMovie);
                    }

                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}