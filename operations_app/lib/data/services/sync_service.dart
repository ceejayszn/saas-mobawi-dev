import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../db/database_helper.dart';
import '../models/sync_item.dart';

class SyncService {
  static final SyncService instance = SyncService._init();

  SyncService._init();

  String baseUrl = 'https://mobawi-backend-api.onrender.com'; // Live Render API endpoint
  String businessId = 'felixpinski'; // Multi-tenant scoping header context
  bool _isSyncing = false;
  Timer? _syncTimer;

  bool get isSyncing => _isSyncing;

  // Initialize and start periodic synchronization checks
  void initialize({String? customBaseUrl, String? customBusinessId}) {
    if (customBaseUrl != null) baseUrl = customBaseUrl;
    if (customBusinessId != null) businessId = customBusinessId;
    
    startPeriodicSync();
  }

  void startPeriodicSync({Duration interval = const Duration(seconds: 30)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (timer) async {
      await syncPendingItems();
    });
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // Enqueue a REST operation locally
  Future<String> enqueue(String endpoint, String method, Map<String, dynamic> payload) async {
    final payloadString = jsonEncode(payload);
    return await DatabaseHelper.instance.enqueueSyncItem(endpoint, method, payloadString);
  }

  // Iterate over pending items and sync them to the backend server
  Future<void> syncPendingItems() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final items = await DatabaseHelper.instance.getPendingSyncItems();
      if (items.isEmpty) return;

      for (final item in items) {
        final success = await _sendRequest(item);
        if (success) {
          await DatabaseHelper.instance.deleteSyncItem(item.id);
        } else {
          await DatabaseHelper.instance.incrementSyncAttempts(item.id);
          // Stop queue processing upon first connection failure to preserve order integrity
          break;
        }
      }
    } catch (_) {
      // Offline or server unreachable
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _sendRequest(SyncItem item) async {
    try {
      final uri = Uri.parse('$baseUrl${item.endpoint}');
      final headers = {
        'Content-Type': 'application/json',
        'x-business-id': businessId, // Tenant isolation binding header
      };

      http.Response response;
      switch (item.method.toUpperCase()) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: item.payload).timeout(const Duration(seconds: 10));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: item.payload).timeout(const Duration(seconds: 10));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 10));
          break;
        default:
          response = await http.post(uri, headers: headers, body: item.payload).timeout(const Duration(seconds: 10));
      }

      // Success codes 200 OK, 201 Created are considered successfully synced
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false; // Connection timeout, network loss, or dns lookup failures
    }
  }
}
