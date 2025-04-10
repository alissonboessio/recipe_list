import 'package:flutter/material.dart';
import 'package:recipe_list/models/recipe.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/services/recipe_service.dart';

class RecipeScreen extends StatefulWidget {
  RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final service = Provider.of<RecipeService>(context);


    return Scaffold(
      appBar: AppBar(title: const Text("Receita"),),
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
                decoration: const InputDecoration(labelText: 'Nome da Receita'),
                validator: (value) => value!.isEmpty ? 'Nome é obrigatório!' : null,
              ),

              SizedBox(height: 30,),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final description = _descriptionController.text;
                    service.create(Recipe(id: 0, name: description, preparationTime: 60));

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