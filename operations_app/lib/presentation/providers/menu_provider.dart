import 'package:flutter/material.dart';
import '../../data/models/menu_item.dart';
import '../../data/repositories/i_menu_repository.dart';

class MenuProvider with ChangeNotifier {
  final IMenuRepository _repository;
  List<MenuItem> _items = [];
  bool _isLoading = false;

  List<MenuItem> get items => _items;
  List<MenuItem> get activeItems => _items.where((i) => i.isActive).toList();
  bool get isLoading => _isLoading;

  MenuProvider(this._repository) {
    loadMenu();
  }

  Future<void> loadMenu() async {
    _isLoading = true;
    notifyListeners();
    _items = await _repository.getMenuItems();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMenuItem(String name, double price) async {
    await _repository.insertMenuItem(MenuItem(name: name, price: price));
    await loadMenu();
  }

  Future<void> toggleStatus(MenuItem item) async {
    final updated = MenuItem(id: item.id, name: item.name, price: item.price, isActive: !item.isActive);
    await _repository.updateMenuItem(updated);
    await loadMenu();
  }
}
