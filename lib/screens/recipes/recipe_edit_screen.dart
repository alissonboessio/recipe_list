import 'package:flutter/material.dart';
import 'package:recipe_list/models/complete_recipe.dart';
import 'package:recipe_list/models/ingredient.dart';
import 'package:recipe_list/models/instruction.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/services/ingredient_service.dart';
import 'package:recipe_list/services/instruction_service.dart';
import 'package:recipe_list/services/recipe_service.dart';
import 'package:recipe_list/widgets/star_rating.dart';

class RecipeEditScreen extends StatefulWidget {
  const RecipeEditScreen({super.key});

  @override
  State<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends State<RecipeEditScreen> {
  late int recipeId;

  RecipeService? _recipeService;
  IngredientService? _ingredientService;
  InstructionService? _instructionService;

  final _recipeNameController = TextEditingController();
  double _recipeRating = 0;

  final _ingredientNameController = TextEditingController();
  final _ingredientMeasureController = TextEditingController();
  final _ingredientQuantityController = TextEditingController();
  final _instructionController = TextEditingController();

  Future<CompleteRecipe> _loadRecipe(int id) async {
    final recipe = await _recipeService!.findById(id);
    final ingredients = await _ingredientService!.findAllByRecipe(id);
    final instructions = await _instructionService!.findAllByRecipe(id);

    _recipeNameController.text = recipe!.name;
    _recipeRating = recipe.rating! / 2;

    return CompleteRecipe(
      recipe: recipe,
      ingredients: ingredients,
      instructions: instructions,
    );
  }

  late Future<CompleteRecipe> _recipeDataFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _recipeService = Provider.of<RecipeService>(context, listen: false);
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
  void dispose() {
    _ingredientNameController.dispose();
    _ingredientMeasureController.dispose();
    _ingredientQuantityController.dispose();
    _instructionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _recipeDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print(snapshot.stackTrace);
          return Scaffold(body: Center(child: Text("Erro! ${snapshot.error}")));
        }

        final recipeData = snapshot.data!;
        final recipe = recipeData.recipe;
        final ingredients = recipeData.ingredients;
        final instructions = recipeData.instructions;

        return Scaffold(
          appBar: AppBar(title: Text("Edição de receita")),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  TextField(
                    controller: _recipeNameController,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    onSubmitted: (val) {
                      setState(() {
                        recipe.name = val;
                      });

                      _recipeService!.update(recipe);
                    },
                  ),
                  const SizedBox(height: 8),
                  StarRating(
                    size: 30,
                    rating: _recipeRating,
                    onRatingChanged: (newRating) {
                      setState(() {
                        _recipeRating = newRating;
                      });

                      recipe.rating = (_recipeRating * 2).toInt();

                      _recipeService!.update(recipe);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('Tempo de preparo: ${recipe.preparationTime} min'),

                  _sectionHeader("Ingredientes", () {
                    _showAddIngredientBottomSheet(context);
                  }),

                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ing = ingredients[index];
                      return GestureDetector(
                        onLongPress:
                            () => _showItemOptions(
                              context,
                              onEdit: () => _editIngredient(ing),
                              onDelete: () {
                                _ingredientService!.delete(ing.id!);
                              },
                            ),
                        child: ListTile(
                          title: Text(
                            '${ing.quantity} ${ing.measure} de ${ing.name}',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  _sectionHeader("Instruções", () {
                    _showAddInstructionBottomSheet(context);
                  }),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: instructions.length,
                    itemBuilder: (context, index) {
                      final inst = instructions[index];
                      return GestureDetector(
                        onLongPress:
                            () => _showItemOptions(
                              context,
                              onEdit: () => _editInstruction(inst),
                              onDelete: () {
                                _instructionService!.delete(inst.id!);
                              },
                            ),
                        child: ListTile(
                          title: Text(
                            '${inst.instructionOrder}. ${inst.instruction}',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
      ],
    );
  }

  void _showItemOptions(
    BuildContext context, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Excluir'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
    );
  }

  void _showAddIngredientBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      showDragHandle: true,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 350,
              child: Column(
                spacing: 8.0,
                children: [
                  const Text(
                    "Adicionar Ingrediente",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  TextField(
                    controller: _ingredientNameController,
                    decoration: const InputDecoration(labelText: "Nome"),
                  ),
                  TextField(
                    controller: _ingredientQuantityController,
                    decoration: const InputDecoration(labelText: "Quantidade"),
                    keyboardType: TextInputType.numberWithOptions(
                      signed: false,
                    ),
                  ),
                  TextField(
                    controller: _ingredientMeasureController,
                    decoration: const InputDecoration(labelText: "Medida"),
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _ingredientService!.create(
                          Ingredient(
                            recipeId: recipeId,
                            name: _ingredientNameController.text,
                            measure: _ingredientMeasureController.text,
                            quantity:
                                int.tryParse(
                                  _ingredientQuantityController.text,
                                ) ??
                                0,
                          ),
                        );

                        _ingredientNameController.clear();
                        _ingredientMeasureController.clear();
                        _ingredientQuantityController.clear();

                        Navigator.pop(context);
                      },
                      child: const Text("Salvar"),
                    ),
                  ),

                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  void _showAddInstructionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      showDragHandle: true,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 300,
              child: Column(
                spacing: 8.0,
                children: [
                  const Text(
                    "Adicionar Instrução",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  TextField(
                    controller: _instructionController,
                    decoration: const InputDecoration(labelText: "Descrição"),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final instructions = await _instructionService!
                            .findAllByRecipe(recipeId);

                        final newOrder = instructions.length + 1;

                        _instructionService!.create(
                          Instruction(
                            recipeId: recipeId,
                            instructionOrder: newOrder,
                            instruction: _instructionController.text,
                          ),
                        );
                        if (context.mounted) {
                          _instructionController.clear();

                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Salvar"),
                    ),
                  ),

                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  void _editIngredient(Ingredient ing) {
    // Implementar fluxo
  }

  void _editInstruction(Instruction inst) {
    // Implementar fluxo
  }
}
