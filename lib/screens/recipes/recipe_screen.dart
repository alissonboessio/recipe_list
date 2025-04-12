import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/models/recipe.dart';
import 'package:recipe_list/models/ingredient.dart';
import 'package:recipe_list/models/instruction.dart';
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

  @override
  Widget build(BuildContext context) {
    final recipeService = Provider.of<RecipeService>(context);
    final ingredientService = Provider.of<IngredientService>(context);
    final instructionService = Provider.of<InstructionService>(context);

    if (ModalRoute.of(context)!.settings.arguments != null) {
      if (ModalRoute.of(context)!.settings.arguments is int) {
        recipeId = ModalRoute.of(context)!.settings.arguments as int;
      }
    }

    final Recipe? recipe = recipeService.findById(recipeId);
    final List<Ingredient> ingredients = ingredientService.findAllByRecipe(recipeId);
    final List<Instruction> instructions = instructionService.findAllByRecipe(recipeId);

    if (recipe == null) {
      return const Scaffold(
        body: Center(child: Text("Receita não encontrada!")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Receita")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 75,
                        child: StarRating(
                              starCount: 5,
                              size: 15,
                              rating: recipe.rating?.toDouble() ?? 0.0,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text('Tempo de preparo: ${recipe.preparationTime} min'),
                      const SizedBox(height: 24),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: ()  {
                      Navigator.pushNamed(context, Rotas.recipeEdit, arguments: recipeId);
                    },
                  ),
                ],
              ),
              
        
              const Text("Ingredientes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    title: Text('${ing.quantity} ${ing.measure} de ${ing.name}'),
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                },
              ),
        
              const SizedBox(height: 24),
              const Text("Instruções", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    title: Text('${inst.order}. ${inst.instruction}'),
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
