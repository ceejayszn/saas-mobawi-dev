import 'dart:convert';

enum ActivityLogType {
  order,
  payment,
  expense,
  staff,
  security,
  system,
}

enum ActivityLogSeverity { info, success, warning, error }

class ActivityLog {
  final String id;
  final ActivityLogType type;
  final ActivityLogSeverity severity;
  final String title;
  final String description;
  final DateTime timestamp;
  final double? amountIn;
  final double? amountOut;
  final String? staffName;
  final String? orderId;

  const ActivityLog({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
    this.amountIn,
    this.amountOut,
    this.staffName,
    this.orderId,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      type: ActivityLogType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityLogType.system,
      ),
      severity: ActivityLogSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => ActivityLogSeverity.info,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      amountIn: json['amountIn'] as double?,
      amountOut: json['amountOut'] as double?,
      staffName: json['staffName'] as String?,
      orderId: json['orderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'amountIn': amountIn,
      'amountOut': amountOut,
      'staffName': staffName,
      'orderId': orderId,
    };
  }

  static List<ActivityLog> fromJsonList(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => ActivityLog.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static String toJsonList(List<ActivityLog> logs) {
    return jsonEncode(logs.map((e) => e.toJson()).toList());
  }

  /// Sample demo logs for testing (shown when no real data exists)
  static List<ActivityLog> get sampleLogs => [
    ActivityLog(
      id: '1',
      type: ActivityLogType.order,
      severity: ActivityLogSeverity.success,
      title: 'Order Completed',
      description: 'Table 3 — 3 items completed by John',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      amountIn: 850.0,
      staffName: 'John Waiter',
      orderId: 'ORD-0042',
    ),
    ActivityLog(
      id: '2',
      type: ActivityLogType.payment,
      severity: ActivityLogSeverity.success,
      title: 'M-Pesa Payment Received',
      description: 'KES 850 received for Order #ORD-0042',
      timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
      amountIn: 850.0,
    ),
    ActivityLog(
      id: '3',
      type: ActivityLogType.expense,
      severity: ActivityLogSeverity.warning,
      title: 'Expense Added',
      description: 'Kitchen supplies — KES 1,200 by Manager',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      amountOut: 1200.0,
      staffName: 'Manager',
    ),
    ActivityLog(
      id: '4',
      type: ActivityLogType.security,
      severity: ActivityLogSeverity.warning,
      title: 'Failed Login Attempt',
      description: '2 failed PIN attempts on admin panel',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ActivityLog(
      id: '5',
      type: ActivityLogType.order,
      severity: ActivityLogSeverity.success,
      title: 'New Order Placed',
      description: 'Table 7 — 5 items by Mary Waiter',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      amountIn: 1450.0,
      staffName: 'Mary Waiter',
      orderId: 'ORD-0041',
    ),
    ActivityLog(
      id: '6',
      type: ActivityLogType.staff,
      severity: ActivityLogSeverity.info,
      title: 'Staff Clocked In',
      description: 'Grace Cashier started shift at 08:00',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      staffName: 'Grace Cashier',
    ),
    ActivityLog(
      id: '7',
      type: ActivityLogType.payment,
      severity: ActivityLogSeverity.success,
      title: 'Cash Payment',
      description: 'KES 1,450 cash received — Table 7',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      amountIn: 1450.0,
    ),
    ActivityLog(
      id: '8',
      type: ActivityLogType.system,
      severity: ActivityLogSeverity.info,
      title: 'Admin Logged In',
      description: 'Admin panel access granted',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];
}
