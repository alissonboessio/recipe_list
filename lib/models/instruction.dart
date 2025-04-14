import 'package:recipe_list/models/base_model.dart';

class Instruction extends BaseModel {
  static String tableName = 'instructions';

  int? id;
  int recipeId;
  int instructionOrder;
  String instruction;

  Instruction({
    this.id,
    required this.recipeId,
    required this.instruction,
    required this.instructionOrder,
  });

  factory Instruction.fromMap(Map<String, dynamic> map) {
    return Instruction(
      id: map['id'],
      recipeId: map['recipeId'],
      instructionOrder: map['instructionOrder'],
      instruction: map['instruction'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'instructionOrder': instructionOrder,
      'instruction': instruction,
    };
  }
}
