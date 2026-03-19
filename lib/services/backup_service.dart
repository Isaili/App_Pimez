import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import '../models/purchase_model.dart';
import '../models/goal_model.dart';
import '../models/pepper_type.dart';
import 'database_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final DatabaseService _databaseService = DatabaseService();
  
  // Obtener directorio de backups
  Future<Directory> _getBackupDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');
    
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    return backupDir;
  }

  // Crear backup
  Future<String?> createBackup() async {
    try {
   
      final purchases = await _databaseService.getAllPurchases();
      final goals = await _databaseService.getAllGoals();

      
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'purchases': purchases.map((p) => {
          'id': p.id,
          'personName': p.personName,
          'community': p.community,
          'kilos': p.kilos,
          'pricePerKilo': p.pricePerKilo,
          'totalAmount': p.totalAmount,
          'pepperType': p.pepperType.toString(),
          'quality': p.quality,
          'purchaseDate': p.purchaseDate.toIso8601String(),
          'createdAt': p.createdAt.toIso8601String(),
        }).toList(),
        'goals': goals.map((g) => {
          'id': g.id,
          'name': g.name,
          'targetKilos': g.targetKilos,
          'currentKilos': g.currentKilos,
          'startDate': g.startDate.toIso8601String(),
          'endDate': g.endDate.toIso8601String(),
          'isActive': g.isActive ? 1 : 0,
        }).toList(),
      };

      // Guardar archivo
      final backupDir = await _getBackupDirectory();
      final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${backupDir.path}/$fileName');
      
      await file.writeAsString(jsonEncode(backupData));
      
      return file.path;
    } catch (e) {
      print('Error creating backup: $e');
      return null;
    }
  }

 
  Future<bool> restoreBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Archivo de backup no encontrado');
      }

      final content = await file.readAsString();
      final backupData = jsonDecode(content);

      
      if (backupData['version'] != '1.0') {
        throw Exception('Versión de backup no compatible');
      }

      final db = await _databaseService.database;

      // Iniciar transacción
      await db.transaction((txn) async {
        
        await txn.delete('purchases');
        await txn.delete('goals');

        // Restaurar purchases
        for (var purchaseData in backupData['purchases']) {
          await txn.insert('purchases', {
            'id': purchaseData['id'],
            'personName': purchaseData['personName'],
            'community': purchaseData['community'],
            'kilos': purchaseData['kilos'],
            'pricePerKilo': purchaseData['pricePerKilo'],
            'totalAmount': purchaseData['totalAmount'],
            'pepperType': purchaseData['pepperType'],
            'quality': purchaseData['quality'],
            'purchaseDate': purchaseData['purchaseDate'],
            'createdAt': purchaseData['createdAt'],
          });
        }

        // Restaurar goals
        for (var goalData in backupData['goals']) {
          await txn.insert('goals', {
            'id': goalData['id'],
            'name': goalData['name'],
            'targetKilos': goalData['targetKilos'],
            'currentKilos': goalData['currentKilos'],
            'startDate': goalData['startDate'],
            'endDate': goalData['endDate'],
            'isActive': goalData['isActive'],
          });
        }
      });

      return true;
    } catch (e) {
      print('Error restoring backup: $e');
      return false;
    }
  }

  // Obtener lista de backups
  Future<List<FileSystemEntity>> getBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      return backupDir.listSync().whereType<File>().toList();
    } catch (e) {
      print('Error getting backups: $e');
      return [];
    }
  }

  
  Future<String> getLastBackupDate() async {
    try {
      final backups = await getBackups();
      if (backups.isEmpty) return 'No hay respaldos';

      backups.sort((a, b) {
        return b.statSync().modified.compareTo(a.statSync().modified);
      });

      final lastBackup = backups.first;
      final date = lastBackup.statSync().modified;
      final format = DateFormat('dd/MM/yyyy HH:mm');
      return format.format(date);
    } catch (e) {
      return 'Error al obtener fecha';
    }
  }

  // Compartir backup
  Future<void> shareBackup(String filePath) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Respaldo de PIMEZ',
      );
    } catch (e) {
      print('Error sharing backup: $e');
    }
  }

 
  Future<void> cleanupOldBackups() async {
    try {
      final backups = await getBackups();
      if (backups.length <= 10) return;

      backups.sort((a, b) {
        return a.statSync().modified.compareTo(b.statSync().modified);
      });

      for (int i = 0; i < backups.length - 10; i++) {
        await backups[i].delete();
      }
    } catch (e) {
      print('Error cleaning up backups: $e');
    }
  }
}