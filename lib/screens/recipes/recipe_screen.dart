import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/models/complete_recipe.dart';
import 'package:recipe_list/rotas.dart';
import 'package:recipe_list/services/recipe_service.dart';
import 'package:recipe_list/services/ingredient_service.dart';
import 'package:recipe_list/services/instruction_service.dart';
import 'package:recipe_list/widgets/star_rating.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  late int recipeId;
  final Set<int> _checkedIngredients = {};
  final Set<int> _checkedInstructions = {};

  RecipeService? _recipeService;
  IngredientService? _ingredientService;
  InstructionService? _instructionService;

  late Future<CompleteRecipe> _recipeDataFuture;

  Future<CompleteRecipe> _loadRecipe(int id) async {
    final recipe = await _recipeService!.findById(id);
    final ingredients = await _ingredientService!.findAllByRecipe(id);
    final instructions = await _instructionService!.findAllByRecipe(id);

    return CompleteRecipe(
      recipe: recipe!,
      ingredients: ingredients,
      instructions: instructions,
    );
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

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      recipeId = args;

      _recipeDataFuture = _loadRecipe(recipeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receita")),
      body: SafeArea(
        child: FutureBuilder(
          future: _recipeDataFuture,
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
                body: Center(child: Text("Receita não encontrada!")),
              );
            }

            final recipeData = snapshot.data!;
            final recipe = recipeData.recipe;
            final ingredients = recipeData.ingredients;
            final instructions = recipeData.instructions;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 75,
                            child: StarRating(
                              size: 15,
                              rating: recipe.rating! / 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tempo de preparo: ${recipe.preparationTime} min',
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Rotas.recipeEdit,
                            arguments: recipeId,
                          );
                        },
                      ),
                    ],
                  ),

                  const Text(
                    "Ingredientes",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ing = ingredients[index];
                      return CheckboxListTile(
                        value: _checkedIngredients.contains(ing.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _checkedIngredients.add(ing.id!);
                            } else {
                              _checkedIngredients.remove(ing.id);
                            }
                          });
                        },
                        title: Text(
                          '${ing.quantity} ${ing.measure} de ${ing.name}',
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Instruções",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: instructions.length,
                    itemBuilder: (context, index) {
                      final inst = instructions[index];
                      return CheckboxListTile(
                        value: _checkedInstructions.contains(inst.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _checkedInstructions.add(inst.id!);
                            } else {
                              _checkedInstructions.remove(inst.id);
                            }
                          });
                        },
                        title: Text(
                          '${inst.instructionOrder}. ${inst.instruction}',
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
