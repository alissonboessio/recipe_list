import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:recipe_list/firebase_options.dart';
import 'package:recipe_list/rotas.dart';
import 'package:recipe_list/screens/recipes/backup_screen.dart';
import 'package:recipe_list/screens/recipes/login_screen.dart';
import 'package:recipe_list/screens/recipes/recipe_edit_screen.dart';
import 'package:recipe_list/screens/recipes/recipe_screen.dart';
import 'package:recipe_list/screens/recipes/recipes_screen.dart';
import 'package:recipe_list/services/api_service.dart';
import 'package:recipe_list/services/ingredient_service.dart';
import 'package:recipe_list/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/services/login_service.dart';
import 'package:recipe_list/services/recipe_service.dart';
import 'package:recipe_list/services/instruction_service.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeLocalNotifications();

  await DatabaseService().initDatabase();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginService()),
        ChangeNotifierProvider(create: (_) => RecipeService()),
        ChangeNotifierProvider(create: (_) => IngredientService()),
        ChangeNotifierProvider(create: (_) => InstructionService()),
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: MaterialApp(
        initialRoute: Rotas.login,
        routes: {
          Rotas.login: (context) => LoginScreen(),
          Rotas.recipes: (context) => RecipesScreen(),
          Rotas.recipe: (context) => RecipeScreen(),
          Rotas.recipeEdit: (context) => RecipeEditScreen(),
          Rotas.backup: (context) => BackupScreen(),
        },
      ),
    );
  }
}

Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await FlutterLocalNotificationsPlugin().initialize(settings);
}
