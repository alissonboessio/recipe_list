import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/models/recipe.dart';
import 'package:recipe_list/rotas.dart';
import 'package:recipe_list/services/recipe_service.dart';
import 'package:recipe_list/widgets/star_rating.dart';

class RecipeForm extends StatefulWidget {
  const RecipeForm({super.key, this.updateVal});

  final Recipe? updateVal;

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _recipeNameController = TextEditingController();
  double _recipeRatingController = 0;
  final _recipePrepTimeController = TextEditingController();

  RecipeService? _recipeService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _recipeService = Provider.of<RecipeService>(context, listen: true);
  }

  @override
  void initState() {
    final updateVal = widget.updateVal;
    if (updateVal != null) {
      _recipeNameController.text = updateVal.name;
      _recipeRatingController = updateVal.rating! / 2;
      _recipePrepTimeController.text = updateVal.preparationTime.toString();
    }

    super.initState();
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _recipePrepTimeController.dispose();

    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 8.0,
          children: [
            if (widget.updateVal == null) ...[
              const Text(
                "Adicionar Receita",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
            ],
            TextFormField(
              controller: _recipeNameController,
              decoration: const InputDecoration(labelText: "Nome"),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              validator: (input) {
                if (input == null || input.isEmpty) {
                  return 'Por favor, insira algum valor!';
                }

                return null;
              },
              onEditingComplete: () async {
                final updateVal = widget.updateVal;
                if (updateVal != null) {
                  setState(() {
                    updateVal.name = _recipeNameController.text;
                  });

                  await _recipeService!.update(updateVal);
                  if (context.mounted) {
                    FocusScope.of(context).unfocus();
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            StarRating(
              rating: _recipeRatingController,
              onRatingChanged: (newRating) async {
                setState(() {
                  _recipeRatingController = newRating;
                });

                final updateVal = widget.updateVal;
                if (updateVal != null) {
                  updateVal.rating = (_recipeRatingController * 2).truncate();

                  await _recipeService!.update(updateVal);
                  if (context.mounted) {
                    FocusScope.of(context).unfocus();
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _recipePrepTimeController,
              decoration: const InputDecoration(
                labelText: "Tempo de Preparo (em minutos)",
              ),
              validator: (input) {
                if (input == null || input.isEmpty) {
                  return 'Por favor, insira algum valor!';
                }

                return null;
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onEditingComplete: () async {
                final updateVal = widget.updateVal;
                if (updateVal != null) {
                  setState(() {
                    updateVal.preparationTime = int.parse(
                      _recipePrepTimeController.text,
                    );
                  });

                  await _recipeService!.update(updateVal);
                  if (context.mounted) {
                    FocusScope.of(context).unfocus();
                  }
                }
              },
              keyboardType: TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
            ),
            if (widget.updateVal == null) ...[
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await _recipeService!.create(
                      Recipe(
                        name: _recipeNameController.text,
                        preparationTime: int.parse(
                          _recipePrepTimeController.text,
                        ),
                        rating: (_recipeRatingController * 2).truncate(),

                        createdAt: DateTime.now(),
                      ),
                    );

                    if (context.mounted) {
                      Navigator.pop(context);

                      Navigator.pushNamed(
                        context,
                        Rotas.recipeEdit,
                        arguments: result,
                      );
                    }
                  },
                  child: const Text("Salvar"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
