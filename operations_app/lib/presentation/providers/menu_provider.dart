import 'package:flutter/material.dart';
import '../../data/db/database_helper.dart';
import '../../data/models/menu_item.dart';

class MenuProvider with ChangeNotifier {
  List<MenuItem> _items = [];
  bool _isLoading = false;

  List<MenuItem> get items => _items;
  List<MenuItem> get activeItems => _items.where((i) => i.isActive).toList();
  bool get isLoading => _isLoading;

  MenuProvider() {
    loadMenu();
  }

  Future<void> loadMenu() async {
    _isLoading = true;
    notifyListeners();
    _items = await DatabaseHelper.instance.getMenuItems();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMenuItem(String name, double price) async {
    await DatabaseHelper.instance.insertMenuItem(MenuItem(name: name, price: price));
    await loadMenu();
  }

  Future<void> toggleStatus(MenuItem item) async {
    final updated = MenuItem(id: item.id, name: item.name, price: item.price, isActive: !item.isActive);
    await DatabaseHelper.instance.updateMenuItem(updated);
    await loadMenu();
  }
}
