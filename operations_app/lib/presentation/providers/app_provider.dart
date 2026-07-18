import 'package:flutter/material.dart';
import '../../data/db/database_helper.dart';
import '../../data/models/models.dart';
import '../../data/services/sync_service.dart';

class AppProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Product> _products = [];
  List<Sale> _orders = [];
  List<Expense> _expenses = [];
  List<InventoryItem> _inventory = [];

  List<Product> get products => _products.where((item) => item.isActive).toList();
  List<Product> get allProducts => _products;
  List<Sale> get sales => _orders;
  List<Expense> get expenses => _expenses;
  List<InventoryItem> get inventory => _inventory;

  // Current sale state (POS)
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
    final data = await _db.queryAll('products');
    _products = data.map((e) => Product.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> loadOrders() async {
    final data = await _db.queryAll('sales');
    _orders = data.map((e) => Sale.fromMap(e)).toList().reversed.toList();
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
  void addToCart(Product item) {
    if (item.id == null) return;
    _cart[item.id!] = (_cart[item.id!] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromCart(Product item) {
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
    double amount = 0;
    _cart.forEach((itemId, qty) {
      final item = _products.firstWhere((element) => element.id == itemId);
      amount += item.price * qty;
    });
    return amount;
  }

  Future<void> checkout(String paymentMethod) async {
    if (_cart.isEmpty) return;

    List<SaleItem> saleItems = [];
    _cart.forEach((itemId, qty) {
      final item = _products.firstWhere((element) => element.id == itemId);
      saleItems.add(SaleItem(
        orderId: '', // Placeholder
        itemId: itemId,
        itemName: item.name,
        quantity: qty,
        price: item.price,
      ));
    });

    final sale = Sale(
      amount: cartTotal,
      status: 'Paid',
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );

    await _db.insertOrder(sale, saleItems);

    // Auto-deduct inventory stocks for matching items
    for (var saleItem in saleItems) {
      try {
        final matchingInventory = _inventory.firstWhere(
          (inv) => inv.itemName.toLowerCase() == saleItem.itemName.toLowerCase()
        );
        if (matchingInventory.id != null) {
          final newQty = (matchingInventory.quantity - saleItem.quantity).clamp(0.0, double.infinity);
          await _db.update('inventory', {'quantity': newQty}, matchingInventory.id!);
          await SyncService.instance.enqueue('/api/inventory/${matchingInventory.id}', 'PUT', {'quantity': newQty});
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
  Future<void> addProduct(String name, double price) async {
    await _db.insert('products', Product(name: name, price: price).toMap());
    await loadMenu();
  }

  Future<void> toggleProduct(Product item) async {
    final updated = Product(id: item.id, name: item.name, price: item.price, isActive: !item.isActive);
    await _db.update('products', updated.toMap(), item.id!);
    await loadMenu();
  }

  Future<void> addExpense(String title, double amount) async {
    await _db.insert('expenses', Expense(title: title, amount: amount, date: DateTime.now()).toMap());
    await loadExpenses();
  }

  ValueNotifier<SyncState> get syncNotifier => SyncService.instance.stateNotifier;

  Future<void> triggerSync() async {
    await SyncService.instance.syncPendingItems();
  }
}
