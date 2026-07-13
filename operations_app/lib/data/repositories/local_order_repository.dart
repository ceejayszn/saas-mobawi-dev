import '../db/database_helper.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/outside_order.dart';
import '../services/sync_service.dart';
import 'i_order_repository.dart';

class LocalOrderRepository implements IOrderRepository {
  @override
  Future<String> createOrder(Order order, List<OrderItem> items) async {
    final orderId = await DatabaseHelper.instance.createOrder(order, items);
    
    // Auto-enqueue order creation for backend sync
    final syncPayload = {
      ...order.toMap(),
      'id': orderId,
      'items': items.map((i) => i.toMap()).toList(),
    };
    await SyncService.instance.enqueue('/api/sales', 'POST', syncPayload);
    
    return orderId;
  }

  @override
  Future<List<Order>> getDailyOrders(String date) async {
    return await DatabaseHelper.instance.getDailyOrders(date);
  }

  @override
  Future<List<Order>> getOrdersBetween(DateTime start, DateTime end) async {
    return await DatabaseHelper.instance.getOrdersBetween(start, end);
  }

  @override
  Future<String> createOutsideOrder(OutsideOrder order, List<OrderItem> items) async {
    final outsideOrderId = await DatabaseHelper.instance.createOutsideOrder(order, items);
    
    // Auto-enqueue delivery order creation for backend sync
    final syncPayload = {
      ...order.toMap(),
      'id': outsideOrderId,
      'items': items.map((i) => i.toMap()).toList(),
    };
    await SyncService.instance.enqueue('/api/sales', 'POST', syncPayload);
    
    return outsideOrderId;
  }

  @override
  Future<List<OutsideOrder>> getOutsideOrdersByStatus(String status) async {
    return await DatabaseHelper.instance.getOutsideOrdersByStatus(status);
  }

  @override
  Future<List<OutsideOrder>> getOutsideOrdersBetween(DateTime start, DateTime end) async {
    return await DatabaseHelper.instance.getOutsideOrdersBetween(start, end);
  }

  @override
  Future<void> markOutsideOrderPaid(String orderId, {String paymentMethod = 'Cash'}) async {
    await DatabaseHelper.instance.markOutsideOrderPaid(orderId, paymentMethod: paymentMethod);
    
    // Auto-enqueue payment event for backend sync
    await SyncService.instance.enqueue('/api/sales/$orderId/pay', 'POST', {
      'paymentMethod': paymentMethod,
    });
  }

  @override
  Future<void> updateOutsideOrderStatus(String orderId, String status) async {
    await DatabaseHelper.instance.updateOutsideOrderStatus(orderId, status);
    
    // Auto-enqueue status transition for backend sync
    await SyncService.instance.enqueue('/api/sales/$orderId/status', 'PUT', {
      'status': status,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getFrequentCustomers() async {
    return await DatabaseHelper.instance.getFrequentCustomers();
  }
}
