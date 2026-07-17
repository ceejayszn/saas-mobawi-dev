import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/repositories/i_menu_repository.dart';

class ProductProvider with ChangeNotifier {
  final IMenuRepository _repository;
  List<Product> _items = [];
  bool _isLoading = false;

  List<Product> get items => _items;
  List<Product> get activeItems => _items.where((i) => i.isActive).toList();
  bool get isLoading => _isLoading;

  ProductProvider(this._repository) {
    loadMenu();
  }

  Future<void> loadMenu() async {
    _isLoading = true;
    notifyListeners();
    _items = await _repository.getProducts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(String name, double price) async {
    await _repository.insertProduct(Product(name: name, price: price));
    await loadMenu();
  }

  Future<void> toggleStatus(Product item) async {
    final updated = Product(id: item.id, name: item.name, price: item.price, isActive: !item.isActive);
    await _repository.updateProduct(updated);
    await loadMenu();
  }
}
