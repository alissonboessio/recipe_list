import 'package:flutter/material.dart';
import 'package:recipe_list/rotas.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/services/ingredient_service.dart';
import 'package:recipe_list/services/recipe_service.dart';
import 'package:recipe_list/services/instruction_service.dart';

import '../../widgets/star_rating.dart';

class RecipesScreen extends StatelessWidget {

  const RecipesScreen({ super.key });

  @override
  Widget build(BuildContext context){

    final service = Provider.of<RecipeService>(context);
    final serviceIngredient = Provider.of<IngredientService>(context);
    final serviceInstruction = Provider.of<InstructionService>(context);

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
                Text("${serviceInstruction.findAllByRecipe(recipe.id).length} preparos"),
              ],
            ),
            trailing: SizedBox(
              width: 75,              
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StarRating(
                    starCount: 5,
                    size: 15,
                    rating: recipe.rating?.toDouble() ?? 0.0,
                  ),
                  SizedBox(height: 5,),
                  Text("${recipe.preparationTime} min", 
                    style: const TextStyle(fontSize: 16)
                  ),
                ]              
              ),
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