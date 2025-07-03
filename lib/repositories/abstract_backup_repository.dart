import 'package:recipe_list/models/backup.dart';

abstract class BackupRepository {
  Future<List<Backup>> listBackups();
  Future<void> saveBackup();
  Future<void> restoreBackup(Backup backup);
}
