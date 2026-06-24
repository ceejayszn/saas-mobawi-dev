class MenuItem {
  final int? id;
  final String name;
  final double price;
  final bool isActive;

  MenuItem({this.id, required this.name, required this.price, this.isActive = true});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      isActive: map['is_active'] == 1,
    );
  }
}

class Order {
  final int? id;
  final double total;
  final String status; // Pending, Served, Paid
  final String paymentMethod; // Cash, M-Pesa, Mixed
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
      id: map['id'],
      total: map['total'],
      status: map['status'],
      paymentMethod: map['payment_method'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class OrderItem {
  final int? id;
  final int orderId;
  final int itemId;
  final String itemName;
  final int quantity;
  final double price;

  OrderItem({this.id, required this.orderId, required this.itemId, required this.itemName, required this.quantity, required this.price});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      orderId: map['order_id'],
      itemId: map['item_id'],
      itemName: map['item_name'] ?? 'Unknown Item',
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}

class Expense {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;

  Expense({this.id, required this.title, required this.amount, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }
}

class InventoryItem {
  final int? id;
  final String itemName;
  final double quantity;

  InventoryItem({this.id, required this.itemName, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'quantity': quantity,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      itemName: map['item_name'],
      quantity: map['quantity'],
    );
  }
}
