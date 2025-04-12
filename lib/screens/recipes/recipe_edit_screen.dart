import 'package:flutter/material.dart';
import 'package:recipe_list/models/ingredient.dart';
import 'package:recipe_list/models/instruction.dart';
import 'package:recipe_list/models/recipe.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/services/ingredient_service.dart';
import 'package:recipe_list/services/instruction_service.dart';
import 'package:recipe_list/services/recipe_service.dart';
import 'package:recipe_list/widgets/star_rating.dart';

class RecipeEditScreen extends StatefulWidget {
  RecipeEditScreen({super.key});

  @override
  State<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends State<RecipeEditScreen> {
  late int recipeId;

  @override
  Widget build(BuildContext context) {
    final recipeService = Provider.of<RecipeService>(context, listen: true);
    final ingredientService = Provider.of<IngredientService>(context, listen: true);
    final instructionService = Provider.of<InstructionService>(context, listen: true);

    if (ModalRoute.of(context)!.settings.arguments != null) {
      if (ModalRoute.of(context)!.settings.arguments is int) {
        recipeId = ModalRoute.of(context)!.settings.arguments as int;
      }
    }

    final Recipe? recipe = recipeService.findById(recipeId);
    final List<Ingredient> ingredients = ingredientService.findAllByRecipe(recipeId);
    final List<Instruction> instructions = instructionService.findAllByRecipe(recipeId)
      ..sort((a, b) => a.order.compareTo(b.order));

    if (recipe == null) {
      return const Scaffold(
        body: Center(child: Text("Receita não encontrada!")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edição de receita")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
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
          
              _sectionHeader("Ingredientes", () {
                _showAddIngredientBottomSheet(context, ingredientService);
              }),
          
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ing = ingredients[index];
                  return GestureDetector(
                    onLongPress: () => _showItemOptions(
                      context,
                      onEdit: () => _editIngredient(ing),
                      onDelete: () {
                        ingredientService.delete(ing.id!);
                      },
                    ),
                    child: ListTile(
                      title: Text('${ing.quantity} ${ing.measure} de ${ing.name}'),
                    ),
                  );
                },
              ),
          
              const SizedBox(height: 24),
              _sectionHeader("Instruções", () {
                _showAddInstructionBottomSheet(context, instructionService);
              }),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: instructions.length,
                itemBuilder: (context, index) {
                  final inst = instructions[index];
                  return GestureDetector(
                    onLongPress: () => _showItemOptions(
                      context,
                      onEdit: () => _editInstruction(inst),
                      onDelete: () {
                        instructionService.delete(inst.id!);
                      },
                    ),
                    child: ListTile(
                      title: Text('${inst.order}. ${inst.instruction}'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onAdd,
        )
      ],
    );
  }

  void _showItemOptions(BuildContext context, {required VoidCallback onEdit, required VoidCallback onDelete}) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
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

  void _showAddIngredientBottomSheet(BuildContext context, IngredientService service) {
    final nameController = TextEditingController();
    final measureController = TextEditingController();
    final quantityController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 350,
          child: Column(
            spacing: 8.0,
            children: [
              const Text("Adicionar Ingrediente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4,),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nome")),
              TextField(controller: quantityController, decoration: const InputDecoration(labelText: "Quantidade"), keyboardType: TextInputType.number),
              TextField(controller: measureController, decoration: const InputDecoration(labelText: "Medida")),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    service.create(Ingredient(
                      recipeId: recipeId,
                      name: nameController.text,
                      measure: measureController.text,
                      quantity: double.tryParse(quantityController.text) ?? 0,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text("Salvar"),                
                ),
              ),
              
              SizedBox(height: 16,),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddInstructionBottomSheet(BuildContext context, InstructionService service) {
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: Column(
            spacing: 8.0,
            children: [
              const Text("Adicionar Instrução", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4,),
              TextField(
                controller: textController, 
                decoration: const InputDecoration(labelText: "Descrição"), 
                keyboardType: TextInputType.multiline, 
                maxLines: null,
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newOrder = service.findAllByRecipe(recipeId).length + 1;
                    service.create(Instruction(
                      recipeId: recipeId,
                      order: newOrder,
                      instruction: textController.text,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text("Salvar"),
                ),
              ),
              
              SizedBox(height: 16,),
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