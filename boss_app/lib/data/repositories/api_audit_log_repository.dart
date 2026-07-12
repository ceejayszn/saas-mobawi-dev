import '../models/audit_log.dart';
import 'i_audit_log_repository.dart';

class ApiAuditLogRepository implements IAuditLogRepository {
  @override
  Future<List<AuditLog>> getRecentAuditLogs({int limit = 50}) {
    throw UnimplementedError('API implementation pending');
  }
}
