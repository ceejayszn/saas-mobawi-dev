import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/models/sale.dart';
import '../../data/models/sale_item.dart';
import '../../data/services/audit_log_service.dart';
import '../../data/repositories/i_order_repository.dart';

class SaleProvider with ChangeNotifier {
  final IOrderRepository _repository;

  final Map<String, int> _cart = {}; // itemId -> quantity
  final List<Sale> _recentOrders = [];
  final Map<String, int> _outsideCart = {};
  List<Sale> _pendingSales = [];
  List<Sale> _readySales = [];
  List<Sale> _deliveringSales = [];
  List<Sale> _paidSales = [];

  Map<String, int> get cart => _cart;
  List<Sale> get recentOrders => _recentOrders;
  Map<String, int> get outsideCart => _outsideCart;
  List<Sale> get pendingSales => _pendingSales;
  List<Sale> get readySales => _readySales;
  List<Sale> get deliveringSales => _deliveringSales;
  List<Sale> get paidSales => _paidSales;

  int get amountItemCount => _cart.values.fold(0, (sum, q) => sum + q);
  int get outsideTotalItemCount => _outsideCart.values.fold(0, (sum, q) => sum + q);

  SaleProvider(this._repository) {
    loadSales();
  }

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

  void clearItem(Product item) {
    if (item.id == null) return;
    _cart.remove(item.id);
    notifyListeners();
  }

  void addToOutsideCart(Product item) {
    if (item.id == null) return;
    _outsideCart[item.id!] = (_outsideCart[item.id!] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromOutsideCart(Product item) {
    if (item.id == null || !_outsideCart.containsKey(item.id!)) return;
    final currentQty = _outsideCart[item.id!] ?? 0;
    if (currentQty > 1) {
      _outsideCart[item.id!] = currentQty - 1;
    } else {
      _outsideCart.remove(item.id!);
    }
    notifyListeners();
  }

  void clearOutsideCart() {
    _outsideCart.clear();
    notifyListeners();
  }

  double calculateTotal(List<Product> allItems) {
    double amount = 0;
    _cart.forEach((itemId, qty) {
      final item = allItems.firstWhere((i) => i.id == itemId);
      amount += item.price * qty;
    });
    return amount;
  }

  double calculateOutsideTotal(List<Product> allItems) {
    double amount = 0;
    _outsideCart.forEach((itemId, qty) {
      final item = allItems.firstWhere((i) => i.id == itemId);
      amount += item.price * qty;
    });
    return amount;
  }

  Future<bool> processOrder(String paymentMethod, List<Product> allItems) async {
    if (_cart.isEmpty) return false;

    double amount = calculateTotal(allItems);
    final sale = Sale(
      amount: amount,
      status: 'Paid',
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );

    List<SaleItem> items = [];
    _cart.forEach((itemId, qty) {
      final item = allItems.firstWhere((i) => i.id == itemId);
      items.add(SaleItem(
        orderId: '',
        itemId: itemId,
        itemName: item.name,
        quantity: qty,
        price: item.price,
      ));
    });

    final orderId = await _repository.createOrder(sale, items);
    
    await AuditLogService.instance.orderPlaced(
      orderId: 'ORD-$orderId',
      amount: amount,
      itemCount: amountItemCount,
    );
    await AuditLogService.instance.orderPaid(
      orderId: 'ORD-$orderId',
      amount: amount,
      paymentMethod: paymentMethod,
    );

    clearCart();
    notifyListeners();
    return true;
  }

  Future<void> loadSales() async {
    _pendingSales = await _repository.getSalesByStatus('Pending');
    _readySales = await _repository.getSalesByStatus('Ready');
    _deliveringSales = await _repository.getSalesByStatus('Delivering');
    _paidSales = await _repository.getSalesByStatus('Paid');
    _frequentCustomers = await _repository.getFrequentCustomers();
    notifyListeners();
  }

  Future<bool> createSale({
    required String customerName,
    required String location,
    required List<Product> allItems,
  }) async {
    if (_outsideCart.isEmpty) return false;

    final amount = calculateOutsideTotal(allItems);
    final sale = Sale(
      customerName: customerName,
      location: location,
      amount: amount,
      status: 'Pending',
      paymentMethod: 'Unpaid',
      createdAt: DateTime.now(),
    );

    final items = <SaleItem>[];
    _outsideCart.forEach((itemId, qty) {
      final item = allItems.firstWhere((product) => product.id == itemId);
      items.add(
        SaleItem(
          orderId: '',
          itemId: itemId,
          itemName: item.name,
          quantity: qty,
          price: item.price,
        ),
      );
    });

    final orderId = await _repository.createSale(sale, items);
    
    await AuditLogService.instance.orderPlaced(
      orderId: 'OUT-$orderId',
      amount: amount,
      itemCount: _outsideCart.values.fold(0, (sum, q) => sum + q),
    );

    clearOutsideCart();
    await loadSales();
    return true;
  }

  Future<void> markSalePaid(String orderId, {String paymentMethod = 'Cash'}) async {
    await _repository.markSalePaid(orderId, paymentMethod: paymentMethod);
    
    final sale = _pendingSales.firstWhere((o) => o.id == orderId, orElse: () => _readySales.firstWhere((o) => o.id == orderId));
    await AuditLogService.instance.orderPaid(
      orderId: 'OUT-$orderId',
      amount: sale.amount,
      paymentMethod: paymentMethod,
    );

    await loadSales();
  }

  Future<void> markSaleDelivering(String orderId) async {
    await _repository.updateSaleStatus(orderId, 'Delivering');
    await loadSales();
  }

  Future<void> updateSaleStatus(String orderId, String status) async {
    await _repository.updateSaleStatus(orderId, status);
    await loadSales();
  }

  List<Map<String, dynamic>> _frequentCustomers = [];
  List<Map<String, dynamic>> get frequentCustomers => _frequentCustomers;

  Future<void> loadFrequentCustomers() async {
    _frequentCustomers = await _repository.getFrequentCustomers();
    notifyListeners();
  }
}
