import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:recipe_list/models/backup.dart';
import 'package:recipe_list/repositories/cloud_backup_repository.dart';
import 'package:recipe_list/repositories/file_backup_repository.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  late Future<List<Backup>> _backups;

  final _fileBackupRepository = FileBackupRepository();
  final _cloudBackupRepository = CloudBackupRepository();

  bool _isFile = true;

  @override
  void initState() {
    super.initState();
    try {
      _backups = _fileBackupRepository.listBackups();
    } catch (err) {
      print('ERR AQUI');
      inspect(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backups")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isFile = true;
                    _backups = _fileBackupRepository.listBackups();
                  });
                },
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(side: BorderSide.none),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: _isFile ? 2 : 0)),
                  ),
                  child: Text('Locais', style: TextStyle(fontSize: 17)),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isFile = false;
                    _backups = _cloudBackupRepository.listBackups();
                  });
                },
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(side: BorderSide.none),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: !_isFile ? 2 : 0)),
                  ),
                  child: Text('Nuvem', style: TextStyle(fontSize: 17)),
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Backup>>(
              future: _backups,
              builder: (context, snapshot) {
                print('snapshot.hasData: ${snapshot.hasData}');
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final backups = snapshot.data!;

                inspect(backups);

                if (backups.isEmpty) {
                  return Center(child: Text("Nenhum backup disponível."));
                }

                return ListView.builder(
                  itemCount: backups.length,
                  itemBuilder: (context, index) {
                    final backup = backups[index];

                    return Card(
                      margin: EdgeInsets.all(12),
                      child: InkWell(
                        onTap: () async {
                          if (_isFile) {
                            await _fileBackupRepository.restoreBackup(backup);
                          } else {
                            await _cloudBackupRepository.restoreBackup(backup);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                backup.dataFormatada,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
