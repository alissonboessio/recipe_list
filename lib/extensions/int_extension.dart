import 'package:intl/intl.dart';

extension IntExtension on int {
  String fromMillisecondsSinceEpoch() {
    final date = DateTime.fromMillisecondsSinceEpoch(this);

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return dateFormat.format(date);
  }
}
