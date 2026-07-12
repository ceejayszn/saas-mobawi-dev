// AuditLogService — writes structured activity logs to the local SQLite DB.
// These logs are read by the boss_app monitoring screen for real-time visibility.
// Every significant POS action should call AuditLogService.log().

import 'dart:math';
import '../db/database_helper.dart';

class AuditLogService {
  AuditLogService._();
  static final AuditLogService instance = AuditLogService._();

  static final _rng = Random();

  String _genId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = _rng.nextInt(999999).toString().padLeft(6, '0');
    return 'LOG-$ts-$rand';
  }

  // ─────────────────────────────────────────────
  // Core write method
  // ─────────────────────────────────────────────

  Future<void> log({
    required String module,    // e.g. 'order', 'payment', 'security', 'shift'
    required String action,    // e.g. 'created', 'paid', 'login', 'cancelled'
    required String entity,    // e.g. 'Order', 'Expense', 'Session'
    String? entityId,          // e.g. 'ORD-0042'
    required String userName,  // who triggered the event
    required String description,
    double? amount,
    String severity = 'info',  // 'info' | 'success' | 'warning' | 'error'
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('audit_logs', {
        'log_id': _genId(),
        'module': module,
        'action': action,
        'entity': entity,
        'entity_id': entityId,
        'user_name': userName,
        'description': description,
        'amount': amount,
        'severity': severity,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Never crash the POS due to logging failure
    }
  }

  // ─────────────────────────────────────────────
  // Convenience methods — POS events
  // ─────────────────────────────────────────────

  Future<void> orderPlaced({
    required String orderId,
    required double total,
    required int itemCount,
    String user = 'Cashier',
  }) => log(
    module: 'order',
    action: 'created',
    entity: 'Order',
    entityId: orderId,
    userName: user,
    description: 'New order placed — $itemCount item(s) · KES ${total.toStringAsFixed(0)}',
    amount: total,
    severity: 'success',
  );

  Future<void> orderPaid({
    required String orderId,
    required double amount,
    required String paymentMethod,
    String user = 'Cashier',
  }) => log(
    module: 'payment',
    action: 'paid',
    entity: 'Payment',
    entityId: orderId,
    userName: user,
    description: 'Payment received — $paymentMethod · KES ${amount.toStringAsFixed(0)}',
    amount: amount,
    severity: 'success',
  );

  Future<void> orderModified({
    required String orderId,
    String user = 'Cashier',
    String reason = '',
  }) => log(
    module: 'order',
    action: 'updated',
    entity: 'Order',
    entityId: orderId,
    userName: user,
    description: 'Order modified${reason.isNotEmpty ? ' — $reason' : ''}',
    severity: 'warning',
  );

  Future<void> orderCancelled({
    required String orderId,
    String user = 'Cashier',
    String reason = '',
  }) => log(
    module: 'order',
    action: 'deleted',
    entity: 'Order',
    entityId: orderId,
    userName: user,
    description: 'Order cancelled${reason.isNotEmpty ? ' — $reason' : ''}',
    severity: 'error',
  );

  Future<void> expenseAdded({
    required String title,
    required double amount,
    String user = 'Cashier',
  }) => log(
    module: 'expense',
    action: 'created',
    entity: 'Expense',
    userName: user,
    description: 'Expense recorded — $title · KES ${amount.toStringAsFixed(0)}',
    amount: amount,
    severity: 'warning',
  );

  Future<void> staffLogin({required String userName}) => log(
    module: 'security',
    action: 'login',
    entity: 'Session',
    userName: userName,
    description: '$userName logged in to POS',
    severity: 'info',
  );

  Future<void> staffLogout({required String userName}) => log(
    module: 'shift',
    action: 'logout',
    entity: 'Session',
    userName: userName,
    description: '$userName logged out of POS',
    severity: 'info',
  );

  Future<void> failedLogin({String user = 'Unknown'}) => log(
    module: 'security',
    action: 'failedLogin',
    entity: 'Session',
    userName: user,
    description: 'Failed login attempt on POS',
    severity: 'error',
  );

  Future<void> shiftStarted({required String userName}) => log(
    module: 'shift',
    action: 'clockedIn',
    entity: 'Shift',
    userName: userName,
    description: '$userName started shift',
    severity: 'info',
  );

  Future<void> shiftEnded({required String userName}) => log(
    module: 'shift',
    action: 'clockedOut',
    entity: 'Shift',
    userName: userName,
    description: '$userName ended shift',
    severity: 'info',
  );

  Future<void> deviceEvent({
    required String event,
    String detail = '',
    String severity = 'info',
  }) => log(
    module: 'system',
    action: 'updated',
    entity: 'Device',
    userName: 'System',
    description: event + (detail.isNotEmpty ? ' — $detail' : ''),
    severity: severity,
  );

  // ─────────────────────────────────────────────
  // Read recent logs (for boss_app to consume)
  // ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getRecentLogs({int limit = 100}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.query(
        'activity_logs',
        orderBy: 'timestamp DESC',
        limit: limit,
      );
    } catch (_) {
      return [];
    }
  }
}
