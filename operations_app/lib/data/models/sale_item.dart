class SaleItem {
  final String? id;
  final String orderId;
  final String itemId;
  final String itemName;
  final int quantity;
  final double price;

  SaleItem({this.id, required this.orderId, required this.itemId, required this.itemName, required this.quantity, required this.price});

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

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id']?.toString(),
      orderId: map['order_id'].toString(),
      itemId: map['item_id'].toString(),
      itemName: map['item_name'] ?? 'Unknown',
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
