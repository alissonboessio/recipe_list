import 'package:flutter/material.dart';
import 'package:recipe_list/rotas.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/services/ingredient_service.dart';
import 'package:recipe_list/services/recipe_service.dart';
import 'package:recipe_list/services/sequence_service.dart';

class RecipesScreen extends StatelessWidget {

  const RecipesScreen({ super.key });

  @override
  Widget build(BuildContext context){

    final service = Provider.of<RecipeService>(context);
    final serviceIngredient = Provider.of<IngredientService>(context);
    final serviceSequence = Provider.of<SequenceService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Receitas")),
      body: ListView.builder(
        itemCount: service.findAll.length,
        itemBuilder: (context, index) {
          final recipe = service.findAll[index];
          return ListTile(
            title: Row(
              children: [
                Text(recipe.name, 
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ) ,
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${serviceIngredient.findAllByRecipe(recipe.id).length} ingredientes",
                 ),
                const SizedBox(height: 5,),
                Text("${serviceSequence.findAllByRecipe(recipe.id).length} preparos"),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${recipe.rating} estrelas",
                  style: const TextStyle(fontSize: 16)
                ), // mudar para icons pintados / apagados
                SizedBox(height: 5,),
                Text("${recipe.preparationTime} min", 
                  style: const TextStyle(fontSize: 16)
                ),
              ]

            ),
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