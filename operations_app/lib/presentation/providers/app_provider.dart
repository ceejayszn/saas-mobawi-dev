import 'package:flutter/material.dart';
import '../../data/db/database_helper.dart';
import '../../data/models/models.dart';

class AppProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<MenuItem> _menuItems = [];
  List<Order> _orders = [];
  List<Expense> _expenses = [];
  List<InventoryItem> _inventory = [];

  List<MenuItem> get menuItems => _menuItems.where((item) => item.isActive).toList();
  List<MenuItem> get allMenuItems => _menuItems;
  List<Order> get orders => _orders;
  List<Expense> get expenses => _expenses;
  List<InventoryItem> get inventory => _inventory;

  // Current order state (POS)
  final Map<String, int> _cart = {}; // itemId -> quantity
  Map<String, int> get cart => _cart;

  AppProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadMenu(),
      loadOrders(),
      loadExpenses(),
      loadInventory(),
    ]);
    notifyListeners();
  }

  Future<void> loadMenu() async {
    final data = await _db.queryAll('menu_items');
    _menuItems = data.map((e) => MenuItem.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> loadOrders() async {
    final data = await _db.queryAll('orders');
    _orders = data.map((e) => Order.fromMap(e)).toList().reversed.toList();
    notifyListeners();
  }

  Future<void> loadExpenses() async {
    final data = await _db.queryAll('expenses');
    _expenses = data.map((e) => Expense.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> loadInventory() async {
    final data = await _db.queryAll('inventory');
    _inventory = data.map((e) => InventoryItem.fromMap(e)).toList();
    notifyListeners();
  }

  // POS Actions
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

  double get cartTotal {
    double total = 0;
    _cart.forEach((itemId, qty) {
      final item = _menuItems.firstWhere((element) => element.id == itemId);
      total += item.price * qty;
    });
    return total;
  }

  Future<void> checkout(String paymentMethod) async {
    if (_cart.isEmpty) return;

    List<OrderItem> orderItems = [];
    _cart.forEach((itemId, qty) {
      final item = _menuItems.firstWhere((element) => element.id == itemId);
      orderItems.add(OrderItem(
        orderId: '', // Placeholder
        itemId: itemId,
        itemName: item.name,
        quantity: qty,
        price: item.price,
      ));
    });

    final order = Order(
      total: cartTotal,
      status: 'Paid',
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );

    await _db.insertOrder(order, orderItems);

    // Auto-deduct inventory stocks for matching items
    for (var orderItem in orderItems) {
      try {
        final matchingInventory = _inventory.firstWhere(
          (inv) => inv.itemName.toLowerCase() == orderItem.itemName.toLowerCase()
        );
        if (matchingInventory.id != null) {
          final newQty = (matchingInventory.quantity - orderItem.quantity).clamp(0.0, double.infinity);
          await _db.update('inventory', {'quantity': newQty}, matchingInventory.id!);
        }
      } catch (_) {
        // No matching item in inventory to deduct, ignore silently or log
      }
    }

    clearCart();
    await loadOrders();
    await loadInventory();
  }

  // Management Actions
  Future<void> addMenuItem(String name, double price) async {
    await _db.insert('menu_items', MenuItem(name: name, price: price).toMap());
    await loadMenu();
  }

  Future<void> toggleMenuItem(MenuItem item) async {
    final updated = MenuItem(id: item.id, name: item.name, price: item.price, isActive: !item.isActive);
    await _db.update('menu_items', updated.toMap(), item.id!);
    await loadMenu();
  }

  Future<void> addExpense(String title, double amount) async {
    await _db.insert('expenses', Expense(title: title, amount: amount, date: DateTime.now()).toMap());
    await loadExpenses();
  }
}
