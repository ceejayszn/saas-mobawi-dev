class OutsideOrder {
  final String? id;
  final String customerName;
  final String location;
  final double total;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;

  OutsideOrder({
    this.id,
    required this.customerName,
    required this.location,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'location': location,
      'total': total,
      'status': status,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory OutsideOrder.fromMap(Map<String, dynamic> map) {
    return OutsideOrder(
      id: map['id']?.toString(),
      customerName: (map['customer_name'] ?? '') as String,
      location: (map['location'] ?? '') as String,
      total: ((map['total'] ?? 0) as num).toDouble(),
      status: (map['status'] ?? 'Pending') as String,
      paymentMethod: (map['payment_method'] ?? 'Unpaid') as String,
      createdAt: DateTime.parse((map['created_at'] ?? DateTime.now().toIso8601String()) as String),
    );
  }
}
