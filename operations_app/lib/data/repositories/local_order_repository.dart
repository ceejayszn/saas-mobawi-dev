import '../db/database_helper.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/outside_order.dart';
import 'i_order_repository.dart';

class LocalOrderRepository implements IOrderRepository {
  @override
  Future<int> createOrder(Order order, List<OrderItem> items) async {
    return await DatabaseHelper.instance.createOrder(order, items);
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
  Future<int> createOutsideOrder(OutsideOrder order, List<OrderItem> items) async {
    return await DatabaseHelper.instance.createOutsideOrder(order, items);
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
  Future<void> markOutsideOrderPaid(int orderId, {String paymentMethod = 'Cash'}) async {
    return await DatabaseHelper.instance.markOutsideOrderPaid(orderId, paymentMethod: paymentMethod);
  }

  @override
  Future<void> updateOutsideOrderStatus(int orderId, String status) async {
    return await DatabaseHelper.instance.updateOutsideOrderStatus(orderId, status);
  }

  @override
  Future<List<Map<String, dynamic>>> getFrequentCustomers() async {
    return await DatabaseHelper.instance.getFrequentCustomers();
  }
}
