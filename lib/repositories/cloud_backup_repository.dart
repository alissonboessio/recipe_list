import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_list/models/backup.dart';
import 'package:recipe_list/repositories/abstract_backup_repository.dart';
import 'package:recipe_list/services/database_service.dart';
import 'package:recipe_list/services/login_service.dart';
import 'package:recipe_list/services/notification_service.dart';
import 'package:sqflite/sqflite.dart';

class CloudBackupRepository implements BackupRepository {
  // singleton
  factory CloudBackupRepository() => _instance;

  CloudBackupRepository.internal();
  static final CloudBackupRepository _instance =
      CloudBackupRepository.internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _dbService = DatabaseService();
  final _loginService = LoginService();
  final _notificationService = NotificationService();

  @override
  Future<List<Backup>> listBackups() async {
    try {
      final documents =
          await _firestore
              .collection('users')
              .doc(_loginService.user!.uid)
              .collection('backups')
              .orderBy('millisecondsSinceEpoch', descending: false)
              .get();

      final List<Backup> backupsList = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in documents.docs) {
        final rawDoc = document.data();

        backupsList.add(
          Backup(
            millisecondsSinceEpoch: rawDoc['millisecondsSinceEpoch'],
            path: null,
            base64Data: rawDoc['data'],
          ),
        );
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

      final bytes = await sourceFile.readAsBytes();
      final base64Data = base64Encode(bytes);

      final now = DateTime.now().millisecondsSinceEpoch;

      await _firestore
          .collection('users')
          .doc(_loginService.user!.uid)
          .collection('backups')
          .add({'millisecondsSinceEpoch': now, 'data': base64Data});
    } catch (err) {
      print('ERR  $err');
    }
  }

  @override
  Future<void> restoreBackup(Backup backup) async {
    final dbPath = await getDatabasesPath();

    try {
      await Isolate.run(() async {
        final source = File('$dbPath/recipe_list.db');

        source.writeAsBytesSync(base64Decode(backup.base64Data!), flush: true);
      });

      await _notificationService.showNotification(
        title: 'Backup Restaurado da Cloud',
        body:
            'As suas receitas foram restauradas com base no backup ${backup.dataFormatada}',
      );
    } catch (err) {
      inspect(err);

      await _notificationService.showNotification(
        title: 'Não foi possível restaurar o Backup da Cloud',
        body:
            'Ocorreu um erro ao tentar restaurar o seu Backup ${backup.dataFormatada} da cloud.',
      );
    }
  }
}
