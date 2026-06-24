import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart' show FilePicker;
import '../database/database_service.dart';

class BackupService {
  static final BackupService instance = BackupService._init();
  BackupService._init();

  // AES-256 encryption key (32 chars) — shared key enables cross-device restore
  final _key = encrypt.Key.fromUtf8('euton_hotel_secure_key_123456789');
  final _iv = encrypt.IV.fromLength(16);

  /// Returns the "Euton Data" folder path, creating it if needed.
  Future<Directory> _getEutonDataDir() async {
    Directory? base;
    try {
      // Try external storage (Downloads visible in file manager)
      if (Platform.isAndroid) {
        final dirs = await getExternalStorageDirectories();
        if (dirs != null && dirs.isNotEmpty) {
          // Go up to root external storage
          String rootPath = dirs.first.path;
          final segs = rootPath.split('/');
          final androidIdx = segs.indexOf('Android');
          if (androidIdx > 0) {
            rootPath = segs.sublist(0, androidIdx).join('/');
          }
          base = Directory(rootPath);
        }
      }
    } catch (_) {}

    // Fallback to app documents directory
    base ??= await getApplicationDocumentsDirectory();

    final eutonDir = Directory(p.join(base.path, 'Euton Data'));
    if (!await eutonDir.exists()) {
      await eutonDir.create(recursive: true);
    }
    return eutonDir;
  }

  /// Export encrypted database backup to "Euton Data" folder, then share.
  Future<void> exportDatabase(BuildContext context) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'kibandaski_pos.db');
      final file = File(path);

      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database file not found.')),
          );
        }
        return;
      }

      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Row(children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 12),
            Text('Encrypting backup...'),
          ])),
        );
      }

      final bytes = await file.readAsBytes();
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final encrypted = encrypter.encryptBytes(bytes, iv: _iv);

      // Save to "Euton Data" folder
      final eutonDir = await _getEutonDataDir();
      final ts = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final backupFileName = 'euton_backup_$ts.enc';
      final backupPath = p.join(eutonDir.path, backupFileName);
      final backupFile = File(backupPath);
      await backupFile.writeAsBytes(encrypted.bytes);

      if (context.mounted) {
        // Show success dialog with file location
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.lock, color: Colors.green),
                SizedBox(width: 8),
                Text('🔒 Backup Saved!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your encrypted backup has been saved to:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    '📁 Euton Data/$backupFileName',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '🔐 AES-256 Encrypted — Safe to share.\nTo restore on another device: share this file and use "Restore Database" in the menu.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share Now'),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await Share.shareXFiles(
                    [XFile(backupFile.path)],
                    text: '🔒 Euton Hotel Encrypted Backup — ${DateTime.now().toString().split('.')[0]}\nShare this file to restore on another device.',
                  );
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  /// Import & decrypt a backup file. User should navigate to "Euton Data" folder.
  Future<void> importDatabase(BuildContext context) async {
    // First show instruction dialog
    if (context.mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.upload_file, color: Colors.orange),
              SizedBox(width: 8),
              Text('Restore Database'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _instructionStep('1', 'Open the file picker that appears'),
              _instructionStep('2', 'Navigate to 📁 "Euton Data" folder'),
              _instructionStep('3', 'Select the .enc backup file'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text(
                  '⚠️ This will REPLACE all current data. Make sure you have the correct backup file.',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Pick File'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: false,
        dialogTitle: 'Select Euton Backup (.enc) from Euton Data folder',
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final encryptedBytes = await file.readAsBytes();

        final encrypter = encrypt.Encrypter(encrypt.AES(_key));
        final decryptedBytes = encrypter.decryptBytes(
          encrypt.Encrypted(encryptedBytes),
          iv: _iv,
        );

        final dbPath = await getDatabasesPath();
        final path = p.join(dbPath, 'kibandaski_pos.db');
        final targetFile = File(path);

        // Close db before overwriting
        await DatabaseService.instance.database.then((db) => db.close());
        await targetFile.writeAsBytes(decryptedBytes);

        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Restore Successful'),
                ],
              ),
              content: const Text(
                '✅ Database has been restored from backup.\n\nPlease restart the app to load the restored data.',
                style: TextStyle(height: 1.5),
              ),
              actions: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  icon: const Icon(Icons.close),
                  label: const Text('Close App'),
                  onPressed: () => exit(0),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed — Invalid or corrupted file: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _instructionStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Future<void> exportDataToCsv(BuildContext context) async {
    try {
      final db = await DatabaseService.instance.database;

      final buf = StringBuffer();
      buf.writeln('EUTON HOTEL - COMPREHENSIVE DATA EXPORT');
      buf.writeln('Generated: ${DateTime.now().toString().split('.')[0]}');
      buf.writeln();

      // --- SECTION 1: EAT-IN SALES ---
      buf.writeln('=== SECTION 1: EAT-IN ORDERS & SALES ===');
      buf.writeln('Order ID,Item,Quantity,Revenue (KES),Status,Payment Method,Date');
      final eatInData = await db.rawQuery('''
        SELECT o.sequence_id, i.name as item, s.quantity, s.total, o.status, o.payment_method, o.created_at
        FROM sales s
        JOIN items i ON s.item_id = i.id
        JOIN orders o ON s.sequence_id = o.sequence_id
        ORDER BY o.created_at DESC
      ''');
      for (final row in eatInData) {
        buf.writeln('"${row['sequence_id']}","${row['item']}",${row['quantity']},${row['total']},"${row['status']}","${row['payment_method']}","${row['created_at']}"');
      }
      buf.writeln();

      // --- SECTION 2: DELIVERY ORDERS ---
      buf.writeln('=== SECTION 2: DELIVERY ORDERS ===');
      buf.writeln('Delivery ID,Customer,Location,Total (KES),Status,Payment Method,Date');
      final delData = await db.rawQuery('''
        SELECT id, customer_name, location, total, status, payment_method, created_at
        FROM delivery_orders
        ORDER BY created_at DESC
      ''');
      for (final row in delData) {
        buf.writeln('${row['id']},"${row['customer_name']}","${row['location']}",${row['total']},"${row['status']}","${row['payment_method']}","${row['created_at']}"');
      }
      buf.writeln();

      // --- SECTION 3: EXPENSES & SUPPLIERS ---
      buf.writeln('=== SECTION 3: EXPENSES & SUPPLIERS ===');
      buf.writeln('Expense,Supplier,Amount (KES),Date');
      final expData = await db.rawQuery('''
        SELECT e.name as expense, COALESCE(sup.name, 'General') as supplier, e.amount, e.created_at
        FROM expenses e
        LEFT JOIN suppliers sup ON e.supplier_id = sup.id
        ORDER BY e.created_at DESC
      ''');
      for (final row in expData) {
        buf.writeln('"${row['expense']}","${row['supplier']}",${row['amount']},"${row['created_at']}"');
      }
      buf.writeln();

      // --- SECTION 4: DENI (CREDITS) ---
      buf.writeln('=== SECTION 4: CREDITS & DENI ===');
      buf.writeln('Customer,Phone,Amount (KES),Status,Date');
      final deniData = await db.rawQuery('''
        SELECT customer_name, phone, amount, status, created_at
        FROM credits
        ORDER BY created_at DESC
      ''');
      for (final row in deniData) {
        buf.writeln('"${row['customer_name']}","${row['phone']}",${row['amount']},"${row['status']}","${row['created_at']}"');
      }

      // Save to Euton Data folder
      final eutonDir = await _getEutonDataDir();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final csvPath = p.join(eutonDir.path, 'euton_full_report_$ts.csv');
      final outFile = File(csvPath);
      await outFile.writeAsString(buf.toString());

      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(outFile.path)],
          text: 'Euton Comprehensive Export — ${DateTime.now().toString().split('.')[0]}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export CSV failed: $e')),
        );
      }
    }
  }

  /// Silent auto backup in the background
  Future<void> autoBackupDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'kibandaski_pos.db');
      final file = File(path);
      if (!await file.exists()) return;

      final bytes = await file.readAsBytes();
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final encrypted = encrypter.encryptBytes(bytes, iv: _iv);

      final eutonDir = await _getEutonDataDir();
      final backupFileName = 'euton_backup_auto.enc';
      final backupPath = p.join(eutonDir.path, backupFileName);
      final backupFile = File(backupPath);
      await backupFile.writeAsBytes(encrypted.bytes);
      debugPrint("Auto backup completed successfully to $backupPath");
    } catch (e) {
      debugPrint("Auto backup failed: $e");
    }
  }
}
