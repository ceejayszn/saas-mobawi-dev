import '../models/order.dart';
import '../models/order_item.dart';
import '../models/outside_order.dart';

abstract class IOrderRepository {
  Future<int> createOrder(Order order, List<OrderItem> items);
  Future<List<Order>> getDailyOrders(String date);
  Future<List<Order>> getOrdersBetween(DateTime start, DateTime end);
  
  Future<int> createOutsideOrder(OutsideOrder order, List<OrderItem> items);
  Future<List<OutsideOrder>> getOutsideOrdersByStatus(String status);
  Future<List<OutsideOrder>> getOutsideOrdersBetween(DateTime start, DateTime end);
  Future<void> markOutsideOrderPaid(int orderId, {String paymentMethod = 'Cash'});
  Future<void> updateOutsideOrderStatus(int orderId, String status);
  
  Future<List<Map<String, dynamic>>> getFrequentCustomers();
}
