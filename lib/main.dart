import 'package:flutter/material.dart';
import 'package:recipe_list/rotas.dart';
import 'package:recipe_list/screens/recipes/recipe_screen.dart';
import 'package:recipe_list/screens/recipes/recipes_screen.dart';
import 'package:recipe_list/services/ingredient_service.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/services/recipe_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeService()),
        ChangeNotifierProvider(create: (_) => IngredientService()),
      ],
      child: MaterialApp(
        initialRoute: Rotas.recipes,
        routes: {
          Rotas.recipes: (context) => RecipesScreen(),
          Rotas.recipe: (context) => RecipeScreen(),
          // Rotas.recipeEdit: (context) => RecipeScreen(),
        }
      ),
    );
  }
}
