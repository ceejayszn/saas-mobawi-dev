export 'expense.dart';
export 'product.dart';
export 'sale.dart';
export 'sale_item.dart';
export 'sync_item.dart';

class InventoryItem {
  final String? id;
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
      id: map['id']?.toString(),
      itemName: map['item_name'],
      quantity: map['quantity'],
    );
  }
}
