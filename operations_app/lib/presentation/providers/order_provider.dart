import 'package:flutter/material.dart';
import '../../data/db/database_helper.dart';
import '../../data/models/menu_item.dart';
import '../../data/models/order.dart';
import '../../data/models/order_item.dart';

class OrderProvider with ChangeNotifier {
  final Map<int, int> _cart = {}; // itemId -> quantity
  final List<Order> _recentOrders = [];

  Map<int, int> get cart => _cart;
  List<Order> get recentOrders => _recentOrders;

  int get totalItemCount => _cart.values.fold(0, (sum, q) => sum + q);

  void addToCart(MenuItem item) {
    if (item.id == null) return;
    _cart[item.id!] = (_cart[item.id!] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromCart(MenuItem item) {
    if (item.id == null) return;
    if (_cart.containsKey(item.id!)) {
      if (_cart[item.id!]! > 1) {
        _cart[item.id!] = _cart[item.id!]! - 1;
      } else {
        _cart.remove(item.id!);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void clearItem(MenuItem item) {
    if (item.id == null) return;
    _cart.remove(item.id);
    notifyListeners();
  }

  double calculateTotal(List<MenuItem> allItems) {
    double total = 0;
    _cart.forEach((itemId, qty) {
      final item = allItems.firstWhere((i) => i.id == itemId);
      total += item.price * qty;
    });
    return total;
  }

  Future<bool> processOrder(String paymentMethod, List<MenuItem> allItems) async {
    if (_cart.isEmpty) return false;

    double total = calculateTotal(allItems);
    final order = Order(
      total: total,
      status: 'Paid',
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );

    List<OrderItem> items = [];
    _cart.forEach((itemId, qty) {
      final item = allItems.firstWhere((i) => i.id == itemId);
      items.add(OrderItem(
        orderId: 0,
        itemId: itemId,
        itemName: item.name,
        quantity: qty,
        price: item.price,
      ));
    });

    await DatabaseHelper.instance.createOrder(order, items);
    clearCart();
    notifyListeners();
    return true;
  }
}
