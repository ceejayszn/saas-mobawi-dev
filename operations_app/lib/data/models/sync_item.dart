class SyncItem {
  final String id;
  final String endpoint;
  final String method;
  final String payload; // JSON String
  final DateTime createdAt;
  final int attempts;

  SyncItem({
    required this.id,
    required this.endpoint,
    required this.method,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'endpoint': endpoint,
      'method': method,
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      'attempts': attempts,
    };
  }

  factory SyncItem.fromMap(Map<String, dynamic> map) {
    return SyncItem(
      id: map['id'] as String,
      endpoint: map['endpoint'] as String,
      method: map['method'] as String,
      payload: map['payload'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      attempts: map['attempts'] as int? ?? 0,
    );
  }
}
