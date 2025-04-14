import 'package:flutter/material.dart';
import 'package:recipe_list/models/complete_recipe.dart';
import 'package:recipe_list/rotas.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/services/ingredient_service.dart';
import 'package:recipe_list/services/recipe_service.dart';
import 'package:recipe_list/services/instruction_service.dart';
import 'package:recipe_list/widgets/recipe_form.dart';

import '../../widgets/star_rating.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  RecipeService? _recipeService;
  IngredientService? _ingredientService;
  InstructionService? _instructionService;

  Future<List<CompleteRecipe>> _loadRecipes() async {
    final recipes = await _recipeService!.findAll;

    final List<CompleteRecipe> list = [];

    for (final recipe in recipes) {
      final ingredients = await _ingredientService!.findAllByRecipe(recipe.id!);
      final instructions = await _instructionService!.findAllByRecipe(
        recipe.id!,
      );

      list.add(
        CompleteRecipe(
          recipe: recipe,
          ingredients: ingredients,
          instructions: instructions,
        ),
      );
    }
    return list;
  }

  @override
  void dispose() {
    _recipeService!.dispose();
    _ingredientService!.dispose();
    _instructionService!.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _recipeService = Provider.of<RecipeService>(context, listen: true);
    _ingredientService = Provider.of<IngredientService>(context, listen: true);
    _instructionService = Provider.of<InstructionService>(
      context,
      listen: true,
    );

    _recipes = _loadRecipes();
  }

  late Future<List<CompleteRecipe>> _recipes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receitas")),
      body: FutureBuilder(
        future: _recipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.stackTrace);

            return Scaffold(
              body: Center(child: Text("Erro! ${snapshot.error}")),
            );
          } else if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: Text("Receitas não encontradas!")),
            );
          }

          final recipes = snapshot.data!;

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final completeRecipe = recipes[index];
              final recipe = completeRecipe.recipe;

              return Dismissible(
                key: ValueKey(recipe.id!),
                onDismissed: (direction) async {
                  await _recipeService!.delete(recipe.id!);
                },
                child: ListTile(
                  title: Row(
                    children: [
                      Text(recipe.name, style: const TextStyle(fontSize: 24)),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${completeRecipe.ingredients.length} ingredientes"),
                      const SizedBox(height: 5),
                      Text("${completeRecipe.instructions.length} instruções"),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 75,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StarRating(size: 15, rating: recipe.rating! / 2),
                        SizedBox(height: 5),
                        Text(
                          "${recipe.preparationTime} min",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        Rotas.recipe,
                        arguments: recipe.id,
                      ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: false,
            showDragHandle: true,
            useSafeArea: true,
            builder: (_) => RecipeForm(),
          );
        },
        tooltip: "Adicionar Receita",
        child: const Icon(Icons.add),
      ),
    );
  }
}
