import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_service.dart';
import 'backup_service.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  SyncService._init();

  Timer? _heartbeatTimer;
  Timer? _syncTimer;

  // Default server URL - User can change this in SharedPreferences
  static const String defaultBaseUrl = "https://euton-db-production.up.railway.app";

  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_base_url') ?? defaultBaseUrl;
  }

  Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_base_url', url);
  }

  /// Start background heartbeat and syncing
  void startAutoSync() {
    _heartbeatTimer?.cancel();
    _syncTimer?.cancel();

    // Heartbeat every 1 minute
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      sendHeartbeat();
    });

    // Auto sync every 2 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      syncData();
    });

    // Run immediately
    sendHeartbeat();
    syncData();
    pullStatusUpdates();
  }

  void stopAutoSync() {
    _heartbeatTimer?.cancel();
    _syncTimer?.cancel();
  }

  /// Pulls updated order statuses from the remote server
  Future<void> pullStatusUpdates() async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/get_data.php?action=sync_pull');

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          final dbService = DatabaseService.instance;
          final List<dynamic> remoteOrders = result['data'];
          
          for (var remote in remoteOrders) {
            String seq = remote['sequence_id'];
            String status = remote['status'];
            String method = remote['payment_method'];
            String checkoutId = remote['checkout_request_id'] ?? '';
            
            // Update local DB if status is 'paid'
            if (status == 'paid') {
              await dbService.database.then((db) => db.execute(
                "UPDATE orders SET status = 'paid', payment_method = ?, checkout_request_id = ? WHERE sequence_id = ? AND status = 'unpaid'",
                [method, checkoutId, seq]
              ));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('SyncService Pull Error: $e');
    }
  }

  /// Registers cashier presence on remote server
  Future<bool> sendHeartbeat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cashier = prefs.getString('cashier_username');
      if (cashier == null || cashier.isEmpty) return false;

      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/sync.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'heartbeat',
          'cashier_name': cashier,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['status'] == 'success';
      }
    } catch (e) {
      debugPrint('SyncService Heartbeat Error: $e');
    }
    return false;
  }

  Future<bool> syncData() async {
    // Perform background auto-backup
    BackupService.instance.autoBackupDatabase();
    try {
      final dbService = DatabaseService.instance;
      
      // Fetch all local orders and sales
      final ordersList = await dbService.queryAll('orders');
      final salesList = await dbService.queryAll('sales');

      if (ordersList.isEmpty) return true; // Nothing to sync

      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/sync.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'sync',
          'orders': ordersList,
          'sales': salesList,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          debugPrint('SyncService: Successfully synced ${ordersList.length} orders to cloud.');
          // Pull updates after successful sync
          await pullStatusUpdates();
          return true;
        } else {
          debugPrint('SyncService: Sync failed: ${result['message']}');
        }
      } else {
        debugPrint('SyncService: Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('SyncService Sync Error: $e');
    }
    return false;
  }

  /// Fetches the list of online cashiers from the server
  Future<List<Map<String, dynamic>>> getOnlineCashiers() async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/get_data.php?action=active_cashiers');
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          return List<Map<String, dynamic>>.from(result['data']);
        }
      }
    } catch (e) {
      debugPrint('SyncService: getOnlineCashiers error: $e');
    }
    return [];
  }
}
