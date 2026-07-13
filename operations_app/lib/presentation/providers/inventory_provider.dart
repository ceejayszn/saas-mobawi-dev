import 'package:flutter/material.dart';
import '../../data/db/database_helper.dart';
import '../../data/models/models.dart';

class InventoryProvider with ChangeNotifier {
  List<InventoryItem> _inventory = [];
  bool _isLoading = false;

  List<InventoryItem> get inventory => _inventory;
  bool get isLoading => _isLoading;

  Future<void> loadInventory() async {
    _isLoading = true;
    notifyListeners();

    final data = await DatabaseHelper.instance.queryAll('inventory');
    _inventory = data.map((e) => InventoryItem.fromMap(e)).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateStock(String id, double newQuantity) async {
    await DatabaseHelper.instance.update('inventory', {'quantity': newQuantity}, id);
    await loadInventory();
  }

  Future<void> addInventoryItem(String name, double quantity) async {
    final item = InventoryItem(itemName: name, quantity: quantity);
    await DatabaseHelper.instance.insert('inventory', item.toMap());
    await loadInventory();
  }
}
