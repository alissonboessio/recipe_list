class Instruction {
  int? id;
  int recipeId;
  int order;
  String instruction;
  
  Instruction({this.id, required this.recipeId, required this.instruction, required this.order});
}