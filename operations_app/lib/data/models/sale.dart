class Sale {
  final String? id;
  final double amount;
  final String status;
  final String paymentMethod;
  final String type;
  final String? customerName;
  final String? location;
  final DateTime? createdAt;

  Sale({
    this.id, 
    required this.amount, 
    required this.status, 
    required this.paymentMethod, 
    this.type = 'In-Store',
    this.customerName,
    this.location,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'status': status,
      'payment_method': paymentMethod,
      'type': type,
      'customer_name': customerName,
      'location': location,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id']?.toString(),
      amount: map['amount'],
      status: map['status'],
      paymentMethod: map['payment_method'],
      type: map['type'] ?? 'In-Store',
      customerName: map['customer_name'],
      location: map['location'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}
