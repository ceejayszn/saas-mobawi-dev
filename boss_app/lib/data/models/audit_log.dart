// Audit Log model — production-ready, replaces ActivityLog
// Designed for future PostgreSQL + API integration

enum AuditModule {
  order,
  payment,
  expense,
  staff,
  inventory,
  security,
  system,
  shift,
  report,
}

enum AuditAction {
  created,
  updated,
  deleted,
  paid,
  clockedIn,
  clockedOut,
  login,
  logout,
  failedLogin,
  adjusted,
  exported,
}

enum AuditSeverity { info, success, warning, error }

enum AuditSyncStatus { local, synced, pending }

class AuditLog {
  final String id;
  final AuditModule module;
  final AuditAction action;
  final String entity; // e.g. "Order", "Staff", "Expense"
  final String? entityId; // e.g. "ORD-0042"
  final String user; // Staff name or "Admin"
  final String description;
  final double? amount; // Optional monetary value
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // Flexible extras
  final AuditSeverity severity;
  final AuditSyncStatus syncStatus;

  const AuditLog({
    required this.id,
    required this.module,
    required this.action,
    required this.entity,
    this.entityId,
    required this.user,
    required this.description,
    this.amount,
    required this.timestamp,
    this.metadata,
    this.severity = AuditSeverity.info,
    this.syncStatus = AuditSyncStatus.local,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      module: AuditModule.values.firstWhere(
        (e) => e.name == json['module'],
        orElse: () => AuditModule.system,
      ),
      action: AuditAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => AuditAction.created,
      ),
      entity: json['entity'] as String,
      entityId: json['entityId'] as String?,
      user: json['user'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      severity: AuditSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AuditSeverity.info,
      ),
      syncStatus: AuditSyncStatus.values.firstWhere(
        (e) => e.name == json['syncStatus'],
        orElse: () => AuditSyncStatus.local,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module': module.name,
      'action': action.name,
      'entity': entity,
      'entityId': entityId,
      'user': user,
      'description': description,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'severity': severity.name,
      'syncStatus': syncStatus.name,
    };
  }

  // Human-readable module label
  String get moduleLabel {
    switch (module) {
      case AuditModule.order: return 'Order';
      case AuditModule.payment: return 'Payment';
      case AuditModule.expense: return 'Expense';
      case AuditModule.staff: return 'Staff';
      case AuditModule.inventory: return 'Inventory';
      case AuditModule.security: return 'Security';
      case AuditModule.system: return 'System';
      case AuditModule.shift: return 'Shift';
      case AuditModule.report: return 'Report';
    }
  }

  // Human-readable action label
  String get actionLabel {
    switch (action) {
      case AuditAction.created: return 'Created';
      case AuditAction.updated: return 'Updated';
      case AuditAction.deleted: return 'Deleted';
      case AuditAction.paid: return 'Paid';
      case AuditAction.clockedIn: return 'Clocked In';
      case AuditAction.clockedOut: return 'Clocked Out';
      case AuditAction.login: return 'Login';
      case AuditAction.logout: return 'Logout';
      case AuditAction.failedLogin: return 'Failed Login';
      case AuditAction.adjusted: return 'Adjusted';
      case AuditAction.exported: return 'Exported';
    }
  }
}
