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
      itemName: map['item_name'] ?? 'Unknown',
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
