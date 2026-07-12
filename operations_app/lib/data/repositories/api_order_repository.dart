import '../models/order.dart';
import '../models/order_item.dart';
import '../models/outside_order.dart';
import 'i_order_repository.dart';

class ApiOrderRepository implements IOrderRepository {
  @override
  Future<int> createOrder(Order order, List<OrderItem> items) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Order>> getDailyOrders(String date) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Order>> getOrdersBetween(DateTime start, DateTime end) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<int> createOutsideOrder(OutsideOrder order, List<OrderItem> items) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<OutsideOrder>> getOutsideOrdersByStatus(String status) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<OutsideOrder>> getOutsideOrdersBetween(DateTime start, DateTime end) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<void> markOutsideOrderPaid(int orderId, {String paymentMethod = 'Cash'}) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<void> updateOutsideOrderStatus(int orderId, String status) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Map<String, dynamic>>> getFrequentCustomers() {
    throw UnimplementedError('API implementation pending');
  }
}
