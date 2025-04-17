import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recipe_list/models/base_model.dart';
import 'package:recipe_list/models/complete_recipe.dart';
import 'package:recipe_list/models/ingredient.dart';
import 'package:recipe_list/models/instruction.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/services/ingredient_service.dart';
import 'package:recipe_list/services/instruction_service.dart';
import 'package:recipe_list/services/recipe_service.dart';
import 'package:recipe_list/widgets/recipe_form.dart';

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

  final _ingredientNameController = TextEditingController();
  final _ingredientMeasureController = TextEditingController();
  final _ingredientQuantityController = TextEditingController();
  final _instructionController = TextEditingController();

  Future<CompleteRecipe> _loadRecipe(int id) async {
    final recipe = await _recipeService!.findById(id);
    final ingredients = await _ingredientService!.findAllByRecipe(id);
    final instructions = await _instructionService!.findAllByRecipe(id);

    _recipeNameController.text = recipe!.name;

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
                  RecipeForm(updateVal: recipe),
                  const SizedBox(height: 8),
                  _sectionHeader("Ingredientes", () {
                    _showIngredientBottomSheet(context);
                  }),

                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ing = ingredients[index];
                      return InkWell(
                        onLongPress:
                            () => _showItemOptions(
                              context,
                              onEdit: _showIngredientBottomSheet,
                              updateVal: ing,
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
                    _showInstructionBottomSheet(context);
                  }),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: instructions.length,
                    itemBuilder: (context, index) {
                      final inst = instructions[index];
                      return InkWell(
                        onLongPress:
                            () => _showItemOptions(
                              context,
                              onEdit: _showInstructionBottomSheet,
                              updateVal: inst,
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
    required void Function(BuildContext context, {BaseModel? updateVal}) onEdit,
    required BaseModel updateVal,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      builder:
          (modalContext) => Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  onEdit(modalContext, updateVal: updateVal);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Excluir'),
                onTap: () {
                  onDelete();

                  Navigator.pop(modalContext);
                },
              ),
            ],
          ),
    );
  }

  void _showIngredientBottomSheet(
    BuildContext context, {
    BaseModel? updateVal,
  }) async {
    if (updateVal != null && updateVal is Ingredient) {
      _ingredientNameController.text = updateVal.name;
      _ingredientQuantityController.text = updateVal.quantity.toString();
      _ingredientMeasureController.text = updateVal.measure;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (modalContext) => Padding(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            ),
            child: SizedBox(
              height: 350,
              child: Column(
                spacing: 8.0,
                children: [
                  Text(
                    updateVal != null
                        ? 'Editar Ingrediente'
                        : "Adicionar Ingrediente",
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  TextField(
                    controller: _ingredientMeasureController,
                    decoration: const InputDecoration(labelText: "Medida"),
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (updateVal != null && updateVal is Ingredient) {
                          updateVal
                            ..name = _ingredientNameController.text
                            ..measure = _ingredientMeasureController.text
                            ..quantity =
                                int.tryParse(
                                  _ingredientQuantityController.text,
                                ) ??
                                0;

                          await _ingredientService!.update(updateVal);
                        } else {
                          await _ingredientService!.create(
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
                        }

                        if (context.mounted) {
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

    _clearIngredient();
  }

  void _showInstructionBottomSheet(
    BuildContext context, {
    BaseModel? updateVal,
  }) async {
    if (updateVal != null && updateVal is Instruction) {
      _instructionController.text = updateVal.instruction;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (modalContext) => Padding(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            ),
            child: SizedBox(
              height: 300,
              child: Column(
                spacing: 8.0,
                children: [
                  Text(
                    updateVal != null
                        ? 'Editar Instrução'
                        : "Adicionar Instrução",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  TextField(
                    controller: _instructionController,
                    decoration: const InputDecoration(labelText: "Descrição"),
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final instructions = await _instructionService!
                            .findAllByRecipe(recipeId);

                        if (updateVal == null) {
                          final newOrder = instructions.length + 1;
                          await _instructionService!.create(
                            Instruction(
                              recipeId: recipeId,
                              instructionOrder: newOrder,
                              instruction: _instructionController.text,
                            ),
                          );
                        } else {
                          if (updateVal is Instruction) {
                            updateVal.instruction = _instructionController.text;

                            await _instructionService!.update(updateVal);
                          }
                        }

                        if (context.mounted) {
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
    _clearInstruction();
  }

  void _clearIngredient() {
    _ingredientNameController.clear();
    _ingredientQuantityController.clear();
    _ingredientMeasureController.clear();
  }

  void _clearInstruction() {
    _instructionController.clear();
  }
}
