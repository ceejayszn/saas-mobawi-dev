import '../models/audit_log.dart';

abstract class IAuditLogRepository {
  Future<List<AuditLog>> getRecentAuditLogs({int limit = 50});
}
