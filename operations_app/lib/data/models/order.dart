class Order {
  final String? id;
  final double total;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;

  Order({this.id, required this.total, required this.status, required this.paymentMethod, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'status': status,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id']?.toString(),
      total: map['total'],
      status: map['status'],
      paymentMethod: map['payment_method'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
