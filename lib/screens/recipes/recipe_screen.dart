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
  late int recipeId;

  @override
  Widget build(BuildContext context) {

    final service = Provider.of<RecipeService>(context);

    if (ModalRoute.of(context)!.settings.arguments != null) {
      if (ModalRoute.of(context)!.settings.arguments is int) {
        recipeId = ModalRoute.of(context)!.settings.arguments as int;     
      }
    }

    final Recipe? recipe = service.findById(recipeId);

    if (recipe == null) {
      return const Center(child: Text("Receita não encontrada!"));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Receita"),),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          spacing: 8,
          children: [
            
            Text(recipe.name, style: const TextStyle(fontSize: 24),),           

            SizedBox(height: 30,),
           
          ],
        ),
      ),
    );
  }
}