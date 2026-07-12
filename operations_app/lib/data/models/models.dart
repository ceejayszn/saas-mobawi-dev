export 'expense.dart';
export 'menu_item.dart';
export 'order.dart';
export 'order_item.dart';
export 'outside_order.dart';

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
