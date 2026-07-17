import '../models/sale.dart';
import '../models/sale_item.dart';

abstract class IOrderRepository {
  Future<String> createOrder(Sale sale, List<SaleItem> items);
  Future<List<Sale>> getDailyOrders(String date);
  Future<List<Sale>> getOrdersBetween(DateTime start, DateTime end);
  
  Future<String> createSale(Sale sale, List<SaleItem> items);
  Future<List<Sale>> getSalesByStatus(String status);
  Future<List<Sale>> getSalesBetween(DateTime start, DateTime end);
  Future<void> markSalePaid(String orderId, {String paymentMethod = 'Cash'});
  Future<void> updateSaleStatus(String orderId, String status);
  
  Future<List<Map<String, dynamic>>> getFrequentCustomers();
}
