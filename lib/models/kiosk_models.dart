class KioskItem {
  final int? id;
  final String name;
  final double price;

  KioskItem({this.id, required this.name, required this.price});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'price': price};
  factory KioskItem.fromMap(Map<String, dynamic> map) => KioskItem(
    id: map['id'],
    name: map['name'],
    price: map['price'],
  );
}

class KioskOrder {
  final int? id;
  final String sequenceId;
  final double total;
  final DateTime createdAt;
  final String status;
  final bool isModified;
  final String paymentMethod;
  final String cashierName;
  final String checkoutRequestId;

  KioskOrder({
    this.id,
    required this.sequenceId,
    required this.total,
    required this.createdAt,
    this.status = 'unpaid',
    this.isModified = false,
    this.paymentMethod = 'cash',
    this.cashierName = 'unknown',
    this.checkoutRequestId = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'sequence_id': sequenceId,
    'total': total,
    'status': status,
    'is_modified': isModified ? 1 : 0,
    'payment_method': paymentMethod,
    'cashier_name': cashierName,
    'checkout_request_id': checkoutRequestId,
    'created_at': createdAt.toIso8601String(),
  };

  factory KioskOrder.fromMap(Map<String, dynamic> map) => KioskOrder(
    id: map['id'],
    sequenceId: map['sequence_id'],
    total: map['total'],
    status: map['status'] ?? 'unpaid',
    isModified: (map['is_modified'] ?? 0) == 1,
    paymentMethod: map['payment_method'] ?? 'cash',
    cashierName: map['cashier_name'] ?? 'unknown',
    checkoutRequestId: map['checkout_request_id'] ?? '',
    createdAt: DateTime.parse(map['created_at']),
  );
}


class Sale {
  final int? id;
  final String sequenceId;
  final int itemId;
  final int quantity;
  final double total;
  final DateTime createdAt;

  Sale({this.id, required this.sequenceId, required this.itemId, required this.quantity, required this.total, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id,
    'sequence_id': sequenceId,
    'item_id': itemId,
    'quantity': quantity,
    'total': total,
    'created_at': createdAt.toIso8601String(),
  };

  factory Sale.fromMap(Map<String, dynamic> map) => Sale(
    id: map['id'],
    sequenceId: map['sequence_id'] ?? '',
    itemId: map['item_id'],
    quantity: map['quantity'],
    total: map['total'],
    createdAt: DateTime.parse(map['created_at']),
  );
}

class Production {
  final int? id;
  final int itemId;
  final int quantityProduced;
  final String session;
  final DateTime createdAt;

  Production({this.id, required this.itemId, required this.quantityProduced, required this.session, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id,
    'item_id': itemId,
    'quantity_produced': quantityProduced,
    'session': session,
    'created_at': createdAt.toIso8601String(),
  };

  factory Production.fromMap(Map<String, dynamic> map) => Production(
    id: map['id'],
    itemId: map['item_id'],
    quantityProduced: map['quantity_produced'],
    session: map['session'],
    createdAt: DateTime.parse(map['created_at']),
  );
}

class Supplier {
  final int? id;
  final String name;
  final DateTime createdAt;

  Supplier({this.id, required this.name, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'created_at': createdAt.toIso8601String(),
  };

  factory Supplier.fromMap(Map<String, dynamic> map) => Supplier(
    id: map['id'],
    name: map['name'],
    createdAt: DateTime.parse(map['created_at']),
  );
}

class Expense {
  final int? id;
  final String name;
  final double amount;
  final int? supplierId;
  final String status;
  final String paymentMethod;
  final double settledAmount;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.name,
    required this.amount,
    this.supplierId,
    this.status = 'settled',
    this.paymentMethod = 'cash',
    this.settledAmount = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'amount': amount,
    'supplier_id': supplierId,
    'status': status,
    'payment_method': paymentMethod,
    'settled_amount': settledAmount,
    'created_at': createdAt.toIso8601String(),
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'],
    name: map['name'],
    amount: (map['amount'] as num).toDouble(),
    supplierId: map['supplier_id'],
    status: map['status'] ?? 'settled',
    paymentMethod: map['payment_method'] ?? 'cash',
    settledAmount: (map['settled_amount'] as num?)?.toDouble() ?? 0.0,
    createdAt: DateTime.parse(map['created_at']),
  );
}

class Credit {
  final int? id;
  final String? customerName;
  final double amount;
  final String status;
  final DateTime createdAt;

  Credit({this.id, this.customerName, required this.amount, required this.status, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id,
    'customer_name': customerName,
    'amount': amount,
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };

  factory Credit.fromMap(Map<String, dynamic> map) => Credit(
    id: map['id'],
    customerName: map['customer_name'],
    amount: map['amount'],
    status: map['status'],
    createdAt: DateTime.parse(map['created_at']),
  );
}

class Bill {
  final int? id;
  final String name;
  final double balance;

  Bill({this.id, required this.name, required this.balance});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'balance': balance};
  factory Bill.fromMap(Map<String, dynamic> map) => Bill(
    id: map['id'],
    name: map['name'],
    balance: map['balance'],
  );
}

// ─── OUTSIDE / DELIVERY ORDERS ──────────────────────────────────────────────

class DeliveryOrder {
  final int? id;
  final String customerName;
  final String location;
  final double total;
  final String status;       // 'pending' | 'paid'
  final String paymentMethod; // 'cash'  | 'mpesa'
  final DateTime createdAt;

  DeliveryOrder({
    this.id,
    required this.customerName,
    required this.location,
    required this.total,
    this.status = 'pending',
    this.paymentMethod = 'cash',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'customer_name': customerName,
    'location': location,
    'total': total,
    'status': status,
    'payment_method': paymentMethod,
    'created_at': createdAt.toIso8601String(),
  };

  factory DeliveryOrder.fromMap(Map<String, dynamic> map) => DeliveryOrder(
    id: map['id'],
    customerName: map['customer_name'],
    location: map['location'] ?? '',
    total: map['total'],
    status: map['status'] ?? 'pending',
    paymentMethod: map['payment_method'] ?? 'cash',
    createdAt: DateTime.parse(map['created_at']),
  );
}

class DeliveryItem {
  final int? id;
  final int orderId;
  final int itemId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double total;

  DeliveryItem({
    this.id,
    required this.orderId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'order_id': orderId,
    'item_id': itemId,
    'item_name': itemName,
    'quantity': quantity,
    'unit_price': unitPrice,
    'total': total,
  };

  factory DeliveryItem.fromMap(Map<String, dynamic> map) => DeliveryItem(
    id: map['id'],
    orderId: map['order_id'],
    itemId: map['item_id'],
    itemName: map['item_name'] ?? '',
    quantity: map['quantity'],
    unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
    total: (map['total'] as num?)?.toDouble() ?? 0.0,
  );
}

class HiredPersonnel {
  final int? id;
  final String name;
  final String phone;
  final String role;
  final DateTime createdAt;

  HiredPersonnel({
    this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'role': role,
    'created_at': createdAt.toIso8601String(),
  };

  factory HiredPersonnel.fromMap(Map<String, dynamic> map) => HiredPersonnel(
    id: map['id'],
    name: map['name'],
    phone: map['phone'],
    role: map['role'],
    createdAt: DateTime.parse(map['created_at']),
  );
}

class PersonnelJob {
  final int? id;
  final int personnelId;
  final String jobTitle;
  final double amount;
  final String duration;
  final String status;          // 'settled' | 'unsettled'
  final String paymentMethod;   // 'cash' | 'mpesa'
  final DateTime createdAt;

  PersonnelJob({
    this.id,
    required this.personnelId,
    required this.jobTitle,
    required this.amount,
    required this.duration,
    this.status = 'unsettled',
    this.paymentMethod = 'cash',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'personnel_id': personnelId,
    'job_title': jobTitle,
    'amount': amount,
    'duration': duration,
    'status': status,
    'payment_method': paymentMethod,
    'created_at': createdAt.toIso8601String(),
  };

  factory PersonnelJob.fromMap(Map<String, dynamic> map) => PersonnelJob(
    id: map['id'],
    personnelId: map['personnel_id'],
    jobTitle: map['job_title'],
    amount: (map['amount'] as num).toDouble(),
    duration: map['duration'],
    status: map['status'] ?? 'unsettled',
    paymentMethod: map['payment_method'] ?? 'cash',
    createdAt: DateTime.parse(map['created_at']),
  );
}
