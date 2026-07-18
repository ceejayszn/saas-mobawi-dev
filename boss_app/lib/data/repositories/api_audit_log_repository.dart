import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/api/api_client.dart';
import '../models/audit_log.dart';
import 'i_audit_log_repository.dart';

class ApiAuditLogRepository implements IAuditLogRepository {
  @override
  Future<List<AuditLog>> getRecentAuditLogs({int limit = 50}) async {
    try {
      final response = await ApiClient.instance.get('/api/audit-logs?limit=$limit');
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((json) {
          return AuditLog(
            id: json['id']?.toString() ?? '',
            module: AuditModule.system,
            action: AuditAction.created,
            entity: 'System',
            user: json['user'] as String? ?? 'POS',
            description: json['newValue'] as String? ?? json['oldValue'] as String? ?? 'System log event',
            timestamp: DateTime.parse(json['time'] as String),
            syncStatus: AuditSyncStatus.synced,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiAuditLogRepository getRecentAuditLogs error: $e');
    }
    return [];
  }
}
