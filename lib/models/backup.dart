import 'package:recipe_list/extensions/int_extension.dart';

class Backup {
  final int millisecondsSinceEpoch;
  final String? path;
  final String? base64Data;

  late String dataFormatada;

  Backup({required this.millisecondsSinceEpoch, this.path, this.base64Data}) {
    dataFormatada = millisecondsSinceEpoch.fromMillisecondsSinceEpoch();
  }
}
