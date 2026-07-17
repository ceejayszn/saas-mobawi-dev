import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../db/database_helper.dart';

enum SyncStatus { idle, syncing, offline, error }

class SyncState {
  final SyncStatus status;
  final int pendingCount;
  final DateTime? lastSyncTime;
  final String? errorMessage;

  const SyncState({
    this.status = SyncStatus.idle,
    this.pendingCount = 0,
    this.lastSyncTime,
    this.errorMessage,
  });

  SyncState copyWith({
    SyncStatus? status,
    int? pendingCount,
    DateTime? lastSyncTime,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SyncService {
  static final SyncService instance = SyncService._init();

  SyncService._init();

  String baseUrl = 'https://mobawi-backend-api.onrender.com';
  String businessId = 'felixpinski';
  bool _isSyncing = false;
  Timer? _syncTimer;
  String? _jwtToken;
  bool _isLoggingIn = false;
  int _consecutiveFailures = 0;

  // UI Notifier for active status tracking
  final ValueNotifier<SyncState> stateNotifier = ValueNotifier(const SyncState());

  bool get isSyncing => _isSyncing;

  // Initialize sync state and load initial queue size
  Future<void> initialize({String? customBaseUrl, String? customBusinessId}) async {
    if (customBaseUrl != null) baseUrl = customBaseUrl;
    if (customBusinessId != null) businessId = customBusinessId;

    await refreshQueueCount();
    startPeriodicSync();
  }

  // Refresh current local SQLite queue count
  Future<int> refreshQueueCount() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final res = await db.rawQuery('SELECT COUNT(*) as cnt FROM sync_queue');
      final count = (res.first['cnt'] as num?)?.toInt() ?? 0;
      stateNotifier.value = stateNotifier.value.copyWith(pendingCount: count);
      return count;
    } catch (_) {
      return stateNotifier.value.pendingCount;
    }
  }

  // Schedule background timer checks
  void startPeriodicSync({Duration? interval}) {
    _syncTimer?.cancel();
    final defaultInterval = interval ?? const Duration(minutes: 5);
    _syncTimer = Timer.periodic(defaultInterval, (timer) async {
      await syncPendingItems();
    });
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // Enqueue operation locally with instant threshold validation
  Future<String> enqueue(String endpoint, String method, Map<String, dynamic> payload) async {
    final payloadString = jsonEncode(payload);
    final id = await DatabaseHelper.instance.enqueueSyncItem(endpoint, method, payloadString);
    
    final count = await refreshQueueCount();
    
    // Threshold Trigger: Sync immediately if queue size exceeds 20 items
    if (count >= 20) {
      unawaited(syncPendingItems());
    }
    
    return id;
  }

  // Check connection status by pinging the backend auth endpoint
  Future<bool> checkConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/auth/login'))
          .timeout(const Duration(seconds: 4));
      // Standard endpoints return 400/404/405/200 on healthy connection
      return response.statusCode != 0;
    } catch (_) {
      return false;
    }
  }

  // Batch sync pending items to the server
  Future<void> syncPendingItems() async {
    if (_isSyncing) return;
    _isSyncing = true;

    stateNotifier.value = stateNotifier.value.copyWith(status: SyncStatus.syncing);

    try {
      // 1. Network awareness check
      final isOnline = await checkConnection();
      if (!isOnline) {
        stateNotifier.value = stateNotifier.value.copyWith(
          status: SyncStatus.offline,
          errorMessage: 'Backend unreachable. Operating in offline mode.',
        );
        _scheduleBackoff();
        return;
      }

      // 2. Fetch queue items
      final items = await DatabaseHelper.instance.getPendingSyncItems();
      if (items.isEmpty) {
        stateNotifier.value = stateNotifier.value.copyWith(status: SyncStatus.idle);
        _consecutiveFailures = 0;
        return;
      }

      // 3. Batch grouping (up to 50 items)
      final batchList = items.take(50).toList();
      final batchPayload = batchList.map((item) => {
        'id': item.id,
        'endpoint': item.endpoint,
        'method': item.method,
        'payload': item.payload
      }).toList();

      final loggedIn = await _ensureLoggedIn();
      if (!loggedIn) {
        stateNotifier.value = stateNotifier.value.copyWith(
          status: SyncStatus.error,
          errorMessage: 'Authentication failed. Will retry later.',
        );
        _scheduleBackoff();
        return;
      }

      // 4. Send request
      final uri = Uri.parse('$baseUrl/api/sync/batch');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-business-id': businessId,
          'Authorization': 'Bearer $_jwtToken',
        },
        body: jsonEncode({'batch': batchPayload}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        _jwtToken = null; // reset token
        stateNotifier.value = stateNotifier.value.copyWith(status: SyncStatus.error);
        _scheduleBackoff();
        return;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;

        // Process individual batch item status outputs
        for (final res in results) {
          final itemId = res['id'] as String;
          final isSuccess = res['success'] as bool;
          if (isSuccess) {
            await DatabaseHelper.instance.deleteSyncItem(itemId);
          } else {
            await DatabaseHelper.instance.incrementSyncAttempts(itemId);
          }
        }

        _consecutiveFailures = 0;
        final remaining = await refreshQueueCount();

        stateNotifier.value = stateNotifier.value.copyWith(
          status: SyncStatus.idle,
          lastSyncTime: DateTime.now(),
          errorMessage: null,
        );

        // Adaptive Sync: If there are still items left in the queue, sync immediately again
        if (remaining > 0) {
          unawaited(syncPendingItems());
        } else {
          // Reset periodic timer to default 5 minutes
          startPeriodicSync();
        }
      } else {
        // Increment attempts on all items in this batch
        for (final item in batchList) {
          await DatabaseHelper.instance.incrementSyncAttempts(item.id);
        }
        _scheduleBackoff();
      }
    } catch (e) {
      stateNotifier.value = stateNotifier.value.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
      _scheduleBackoff();
    } finally {
      _isSyncing = false;
    }
  }

  // Handle server/network errors with exponential backoff scheduling
  void _scheduleBackoff() {
    _consecutiveFailures++;
    // Backoff formula: 30s * 2^consecutiveFailures (capped at 15 minutes)
    final backoffSeconds = math.min(30 * math.pow(2, _consecutiveFailures).toInt(), 900);
    startPeriodicSync(interval: Duration(seconds: backoffSeconds));
  }

  Future<bool> _ensureLoggedIn() async {
    if (_jwtToken != null) return true;
    if (_isLoggingIn) return false;
    _isLoggingIn = true;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': '${businessId}_pos',
          'password': '${businessId}_pos',
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _jwtToken = data['token'] as String?;
        return true;
      }
    } catch (_) {
      // Login failed
    } finally {
      _isLoggingIn = false;
    }
    return false;
  }
}
