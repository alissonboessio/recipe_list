import 'package:flutter/material.dart';
import 'package:recipe_list/models/genre.dart';
import 'package:recipe_list/services/genre_service.dart';
import 'package:provider/provider.dart';

class GenreScreen extends StatefulWidget {
  GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final service = Provider.of<GenreService>(context);


    return Scaffold(
      appBar: AppBar(title: const Text("Gênero"),),
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
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Nome do Gênero'),
                validator: (value) => value!.isEmpty ? 'Nome é obrigatório!' : null,
              ),

              SizedBox(height: 30,),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final description = _descriptionController.text;
                    service.create(Genre(id: 0, description: description));

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