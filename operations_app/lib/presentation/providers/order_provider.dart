import 'package:flutter/material.dart';
import '../../data/models/menu_item.dart';
import '../../data/models/order.dart';
import '../../data/models/order_item.dart';
import '../../data/models/outside_order.dart';
import '../../data/services/audit_log_service.dart';
import '../../data/repositories/i_order_repository.dart';

class OrderProvider with ChangeNotifier {
  final IOrderRepository _repository;

  final Map<int, int> _cart = {}; // itemId -> quantity
  final List<Order> _recentOrders = [];
  final Map<int, int> _outsideCart = {};
  List<OutsideOrder> _pendingOutsideOrders = [];
  List<OutsideOrder> _readyOutsideOrders = [];
  List<OutsideOrder> _deliveringOutsideOrders = [];
  List<OutsideOrder> _paidOutsideOrders = [];

  Map<int, int> get cart => _cart;
  List<Order> get recentOrders => _recentOrders;
  Map<int, int> get outsideCart => _outsideCart;
  List<OutsideOrder> get pendingOutsideOrders => _pendingOutsideOrders;
  List<OutsideOrder> get readyOutsideOrders => _readyOutsideOrders;
  List<OutsideOrder> get deliveringOutsideOrders => _deliveringOutsideOrders;
  List<OutsideOrder> get paidOutsideOrders => _paidOutsideOrders;

  int get totalItemCount => _cart.values.fold(0, (sum, q) => sum + q);
  int get outsideTotalItemCount => _outsideCart.values.fold(0, (sum, q) => sum + q);

  OrderProvider(this._repository) {
    loadOutsideOrders();
  }

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

  void addToOutsideCart(MenuItem item) {
    if (item.id == null) return;
    _outsideCart[item.id!] = (_outsideCart[item.id!] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromOutsideCart(MenuItem item) {
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

  double calculateTotal(List<MenuItem> allItems) {
    double total = 0;
    _cart.forEach((itemId, qty) {
      final item = allItems.firstWhere((i) => i.id == itemId);
      total += item.price * qty;
    });
    return total;
  }

  double calculateOutsideTotal(List<MenuItem> allItems) {
    double total = 0;
    _outsideCart.forEach((itemId, qty) {
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

    final orderId = await _repository.createOrder(order, items);
    
    await AuditLogService.instance.orderPlaced(
      orderId: 'ORD-$orderId',
      total: total,
      itemCount: totalItemCount,
    );
    await AuditLogService.instance.orderPaid(
      orderId: 'ORD-$orderId',
      amount: total,
      paymentMethod: paymentMethod,
    );

    clearCart();
    notifyListeners();
    return true;
  }

  Future<void> loadOutsideOrders() async {
    _pendingOutsideOrders = await _repository.getOutsideOrdersByStatus('Pending');
    _readyOutsideOrders = await _repository.getOutsideOrdersByStatus('Ready');
    _deliveringOutsideOrders = await _repository.getOutsideOrdersByStatus('Delivering');
    _paidOutsideOrders = await _repository.getOutsideOrdersByStatus('Paid');
    _frequentCustomers = await _repository.getFrequentCustomers();
    notifyListeners();
  }

  Future<bool> createOutsideOrder({
    required String customerName,
    required String location,
    required List<MenuItem> allItems,
  }) async {
    if (_outsideCart.isEmpty) return false;

    final total = calculateOutsideTotal(allItems);
    final order = OutsideOrder(
      customerName: customerName,
      location: location,
      total: total,
      status: 'Pending',
      paymentMethod: 'Unpaid',
      createdAt: DateTime.now(),
    );

    final items = <OrderItem>[];
    _outsideCart.forEach((itemId, qty) {
      final item = allItems.firstWhere((menuItem) => menuItem.id == itemId);
      items.add(
        OrderItem(
          orderId: 0,
          itemId: itemId,
          itemName: item.name,
          quantity: qty,
          price: item.price,
        ),
      );
    });

    final orderId = await _repository.createOutsideOrder(order, items);
    
    await AuditLogService.instance.orderPlaced(
      orderId: 'OUT-$orderId',
      total: total,
      itemCount: _outsideCart.values.fold(0, (sum, q) => sum + q),
    );

    clearOutsideCart();
    await loadOutsideOrders();
    return true;
  }

  Future<void> markOutsideOrderPaid(int orderId, {String paymentMethod = 'Cash'}) async {
    await _repository.markOutsideOrderPaid(orderId, paymentMethod: paymentMethod);
    
    final order = _pendingOutsideOrders.firstWhere((o) => o.id == orderId, orElse: () => _readyOutsideOrders.firstWhere((o) => o.id == orderId));
    await AuditLogService.instance.orderPaid(
      orderId: 'OUT-$orderId',
      amount: order.total,
      paymentMethod: paymentMethod,
    );

    await loadOutsideOrders();
  }

  Future<void> markOutsideOrderDelivering(int orderId) async {
    await _repository.updateOutsideOrderStatus(orderId, 'Delivering');
    await loadOutsideOrders();
  }

  Future<void> updateOutsideOrderStatus(int orderId, String status) async {
    await _repository.updateOutsideOrderStatus(orderId, status);
    await loadOutsideOrders();
  }

  List<Map<String, dynamic>> _frequentCustomers = [];
  List<Map<String, dynamic>> get frequentCustomers => _frequentCustomers;

  Future<void> loadFrequentCustomers() async {
    _frequentCustomers = await _repository.getFrequentCustomers();
    notifyListeners();
  }
}
