import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recipe_list/models/complete_recipe.dart';
import 'package:recipe_list/repositories/cloud_backup_repository.dart';
import 'package:recipe_list/repositories/file_backup_repository.dart';
import 'package:recipe_list/rotas.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/services/ingredient_service.dart';
import 'package:recipe_list/services/localauth_service.dart';
import 'package:recipe_list/services/notification_service.dart';
import 'package:recipe_list/services/recipe_service.dart';
import 'package:recipe_list/services/instruction_service.dart';
import 'package:recipe_list/widgets/main_drawer.dart';
import 'package:recipe_list/widgets/recipe_form.dart';
import 'package:recipe_list/widgets/star_rating.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  RecipeService? _recipeService;
  IngredientService? _ingredientService;
  InstructionService? _instructionService;

  final _fileBackupRepository = FileBackupRepository();
  final _cloudBackupRepository = CloudBackupRepository();
  final _notificationService = NotificationService();

  Future<List<CompleteRecipe>> _loadRecipes() async {
    print('LOAD RECIPES ');
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
      drawer: const MainDrawer(),
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
                      const SnackBar(content: Text("Autenticação falhou!")),
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
              Navigator.pushNamed(context, Rotas.recipe, arguments: recipe.id);
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
          FloatingActionButton(
            onPressed: () async {
              await Navigator.pushNamed(context, Rotas.backup);

              setState(() {
                _recipes = _loadRecipes();
              });
            },
            tooltip: "Restaurar Backups",
            child: const Icon(Icons.settings_backup_restore),
          ),
          FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                useSafeArea: true,
                builder:
                    (_) => Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Column(
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    try {
                                      await _cloudBackupRepository.saveBackup();

                                      await _notificationService.showNotification(
                                        title: 'Backup na Cloud realizado',
                                        body:
                                            'As suas receitas foram salvas na cloud!',
                                      );
                                    } catch (err) {
                                      await _notificationService.showNotification(
                                        title: 'Backup na Cloud falhou',
                                        body:
                                            'Não foi possível salvar as suas receitas na cloud.',
                                      );
                                    }
                                  },
                                  label: Text(
                                    'Backup Cloud',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  icon: Icon(Icons.cloud, size: 20),
                                ),
                                SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: () async {
                                    try {
                                      await _fileBackupRepository.saveBackup();

                                      await _notificationService.showNotification(
                                        title:
                                            'Backup realizado no Dispositivo',
                                        body:
                                            'As suas receitas foram salvas no dispositivo!',
                                      );
                                    } catch (err) {
                                      await _notificationService.showNotification(
                                        title: 'Backup no Dispositivo falhou',
                                        body:
                                            'Não foi possível salvar as suas receitas no dispositivo.',
                                      );
                                    }
                                  },
                                  label: Text(
                                    'Backup Local',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  icon: Icon(Icons.save, size: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
              );
            },
            tooltip: "Criar Backups",
            child: const Icon(Icons.backup),
          ),
        ],
      ),
    );
  }
}
