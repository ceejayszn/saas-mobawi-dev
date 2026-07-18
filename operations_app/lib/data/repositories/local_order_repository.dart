import '../db/database_helper.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../services/sync_service.dart';
import 'i_order_repository.dart';

class LocalOrderRepository implements IOrderRepository {
  @override
  Future<String> createOrder(Sale sale, List<SaleItem> items) async {
    final orderId = await DatabaseHelper.instance.createOrder(sale, items);
    
    // Auto-enqueue sale creation for backend sync
    final syncPayload = {
      ...sale.toMap(),
      'id': orderId,
      'items': items.map((i) => i.toMap()).toList(),
    };
    await SyncService.instance.enqueue('/api/sales', 'POST', syncPayload);
    
    return orderId;
  }

  @override
  Future<List<Sale>> getDailyOrders(String date) async {
    return await DatabaseHelper.instance.getDailyOrders(date);
  }

  @override
  Future<List<Sale>> getOrdersBetween(DateTime start, DateTime end) async {
    return await DatabaseHelper.instance.getOrdersBetween(start, end);
  }

  @override
  Future<String> createSale(Sale sale, List<SaleItem> items) async {
    final outsideOrderId = await DatabaseHelper.instance.createSale(sale, items);
    
    // Auto-enqueue delivery sale creation for backend sync
    final syncPayload = {
      ...sale.toMap(),
      'id': outsideOrderId,
      'items': items.map((i) => i.toMap()).toList(),
    };
    await SyncService.instance.enqueue('/api/sales', 'POST', syncPayload);
    
    return outsideOrderId;
  }

  @override
  Future<List<Sale>> getSalesByStatus(String status) async {
    return await DatabaseHelper.instance.getSalesByStatus(status);
  }

  @override
  Future<List<Sale>> getSalesBetween(DateTime start, DateTime end) async {
    return await DatabaseHelper.instance.getSalesBetween(start, end);
  }

  @override
  Future<void> markSalePaid(String orderId, {String paymentMethod = 'Cash'}) async {
    await DatabaseHelper.instance.markSalePaid(orderId, paymentMethod: paymentMethod);
    
    // Auto-enqueue payment event for backend sync
    await SyncService.instance.enqueue('/api/sales/$orderId/pay', 'POST', {
      'paymentMethod': paymentMethod,
    });
  }

  @override
  Future<void> updateSaleStatus(String orderId, String status) async {
    await DatabaseHelper.instance.updateSaleStatus(orderId, status);
    
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
