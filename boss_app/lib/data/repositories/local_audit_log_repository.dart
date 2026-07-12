import '../models/audit_log.dart';
import 'i_audit_log_repository.dart';

class LocalAuditLogRepository implements IAuditLogRepository {
  @override
  Future<List<AuditLog>> getRecentAuditLogs({int limit = 50}) async {
    // Simulated logs from the operations_app POS
    final now = DateTime.now();
    return [
      AuditLog(
        id: 'LOG-001',
        module: AuditModule.security,
        action: AuditAction.login,
        entity: 'Session',
        user: 'Jane Doe',
        description: 'Jane Doe logged in to POS',
        timestamp: now.subtract(const Duration(hours: 4, minutes: 12)),
        severity: AuditSeverity.info,
      ),
      AuditLog(
        id: 'LOG-002',
        module: AuditModule.shift,
        action: AuditAction.clockedIn,
        entity: 'Shift',
        user: 'Jane Doe',
        description: 'Jane Doe started shift',
        timestamp: now.subtract(const Duration(hours: 4, minutes: 10)),
        severity: AuditSeverity.info,
      ),
      AuditLog(
        id: 'LOG-003',
        module: AuditModule.order,
        action: AuditAction.created,
        entity: 'Order',
        entityId: 'ORD-1042',
        user: 'Jane Doe',
        description: 'New order placed — 3 item(s) · KES 450',
        amount: 450,
        timestamp: now.subtract(const Duration(hours: 3, minutes: 45)),
        severity: AuditSeverity.success,
      ),
      AuditLog(
        id: 'LOG-004',
        module: AuditModule.payment,
        action: AuditAction.paid,
        entity: 'Payment',
        entityId: 'ORD-1042',
        user: 'Jane Doe',
        description: 'Payment received — M-Pesa · KES 450',
        amount: 450,
        timestamp: now.subtract(const Duration(hours: 3, minutes: 44)),
        severity: AuditSeverity.success,
      ),
      AuditLog(
        id: 'LOG-005',
        module: AuditModule.system,
        action: AuditAction.updated,
        entity: 'Device',
        user: 'System',
        description: 'Device connected to charger (Phone charging)',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
        severity: AuditSeverity.info,
      ),
      AuditLog(
        id: 'LOG-006',
        module: AuditModule.order,
        action: AuditAction.updated,
        entity: 'Order',
        entityId: 'ORD-1043',
        user: 'Jane Doe',
        description: 'Order modified — Added extra Fries',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
        severity: AuditSeverity.warning,
      ),
      AuditLog(
        id: 'LOG-007',
        module: AuditModule.order,
        action: AuditAction.deleted,
        entity: 'Order',
        entityId: 'ORD-1044',
        user: 'Jane Doe',
        description: 'Order cancelled — Customer changed mind',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 50)),
        severity: AuditSeverity.error,
      ),
      AuditLog(
        id: 'LOG-008',
        module: AuditModule.expense,
        action: AuditAction.created,
        entity: 'Expense',
        user: 'Jane Doe',
        description: 'Expense recorded — Cleaning Supplies · KES 250',
        amount: 250,
        timestamp: now.subtract(const Duration(minutes: 45)),
        severity: AuditSeverity.warning,
      ),
      AuditLog(
        id: 'LOG-009',
        module: AuditModule.security,
        action: AuditAction.failedLogin,
        entity: 'Session',
        user: 'Unknown',
        description: 'Failed login attempt on POS (Incorrect PIN)',
        timestamp: now.subtract(const Duration(minutes: 15)),
        severity: AuditSeverity.error,
      ),
    ];
  }
}
