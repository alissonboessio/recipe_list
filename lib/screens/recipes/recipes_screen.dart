import 'package:flutter/material.dart';
import 'package:recipe_list/rotas.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/services/recipe_service.dart';

class RecipesScreen extends StatelessWidget {

  const RecipesScreen({ super.key });

  @override
  Widget build(BuildContext context){

    final service = Provider.of<RecipeService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Receitas")),
      body: ListView.builder(
        itemCount: service.findAll.length,
        itemBuilder: (context, index) {
          final recipe = service.findAll[index];
          return ListTile(
            title: Text(recipe.name),
            onTap: () => Navigator.pushNamed(context, Rotas.recipe, arguments: recipe.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Rotas.recipe);
        },
        tooltip: "Adicionar Receita",
        child: const Icon(Icons.add),
      ),
    );
  }
}