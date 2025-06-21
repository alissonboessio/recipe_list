import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recipe_list/models/complete_recipe.dart';
import 'package:recipe_list/rotas.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/services/ingredient_service.dart';
import 'package:recipe_list/services/localauth_service.dart';
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
                confirmDismiss: (direction) async {
                  bool autenticado = await LocalAuth().authenticate(
                    "Autentique-se para excluir a receita",
                  );

                  if (!autenticado) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Autenticação falhou!"),
                      ),
                    );
                    return false;
                  }

                  return true;
                },
                onDismissed: (direction) async {
                  await _recipeService!.delete(recipe.id!);
                },
                child: InkWell(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: ListTile(
                          title: Text(
                            recipe.name,
                            style: const TextStyle(fontSize: 24),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${completeRecipe.ingredients.length} ingredientes",
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${completeRecipe.instructions.length} instruções",
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                            Text(
                              DateFormat('dd/MM/yyyy').format(recipe.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
      floatingActionButton: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () async {
              var recipe = await _recipeService!.createRandomRecipe();
              Navigator.pushNamed(
                context,
                Rotas.recipe,
                arguments: recipe.id,
              );
            },
            tooltip: "Receita Aleatória",
            child: const Icon(Icons.help_outline),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                useSafeArea: true,
                builder: (_) => RecipeForm(),
              );
            },
            tooltip: "Adicionar Receita",
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
