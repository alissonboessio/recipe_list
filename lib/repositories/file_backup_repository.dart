import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:path_provider/path_provider.dart';
import 'package:recipe_list/models/backup.dart';
import 'package:recipe_list/repositories/abstract_backup_repository.dart';
import 'package:recipe_list/services/database_service.dart';
import 'package:recipe_list/services/login_service.dart';
import 'package:recipe_list/services/notification_service.dart';
import 'package:sqflite/sqflite.dart';

class FileBackupRepository implements BackupRepository {
  // singleton
  factory FileBackupRepository() => _instance;

  FileBackupRepository.internal();
  static final FileBackupRepository _instance = FileBackupRepository.internal();

  final _dbService = DatabaseService();
  final _loginService = LoginService();
  final _notificationService = NotificationService();

  @override
  Future<List<Backup>> listBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final userDirectory = Directory(
        '${directory.path}/${_loginService.user!.uid}',
      );

      final List<FileSystemEntity> entities = userDirectory.listSync();

      final List<Backup> backupsList = [];

      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          final path = entity.path;

          backupsList.add(
            Backup(
              millisecondsSinceEpoch: int.parse(
                path.split('/').last.split('_').first,
              ),
              path: path,
            ),
          );
        }
      }

      return backupsList;
    } catch (err) {
      inspect(err);
      return [];
    }
  }

  @override
  Future<void> saveBackup() async {
    try {
      final sourceFile = await _dbService.getSourceDatabaseFile();

      final appDocsDirectory = await getApplicationDocumentsDirectory();

      final userDirectory = await Directory(
        '${appDocsDirectory.path}/${_loginService.user!.uid}',
      ).create(recursive: true);

      final now = DateTime.now().millisecondsSinceEpoch;

      await sourceFile.copy('${userDirectory.path}/${now}_recipe_list.db');
    } catch (err) {
      print('ERR  $err');
    }
  }

  @override
  Future<void> restoreBackup(Backup backup) async {
    final dbPath = await getDatabasesPath();

    try {
      await Isolate.run(() async {
        final newFile = File(backup.path!);

        print('OVERWRITE DB');

        newFile.copySync('$dbPath/recipe_list.db');
      });

      await _notificationService.showNotification(
        title: 'Backup do Dispositivo Restaurado',
        body:
            'As suas receitas foram restauradas com base no backup ${backup.dataFormatada} salvo no dispositivo.',
      );
    } catch (err) {
      inspect(err);

      await _notificationService.showNotification(
        title: 'Não foi possível restaurar o Backup do dispositivo',
        body:
            'Ocorreu um erro ao tentar restaurar o seu Backup ${backup.dataFormatada} do dispositivo.',
      );
    }
  }
}
