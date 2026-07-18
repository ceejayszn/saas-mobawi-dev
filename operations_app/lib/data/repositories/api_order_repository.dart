import '../models/sale.dart';
import '../models/sale_item.dart';
import 'i_order_repository.dart';

class ApiOrderRepository implements IOrderRepository {
  @override
  Future<String> createOrder(Sale sale, List<SaleItem> items) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Sale>> getDailyOrders(String date) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Sale>> getOrdersBetween(DateTime start, DateTime end) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<String> createSale(Sale sale, List<SaleItem> items) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Sale>> getSalesByStatus(String status) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Sale>> getSalesBetween(DateTime start, DateTime end) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<void> markSalePaid(String orderId, {String paymentMethod = 'Cash'}) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<void> updateSaleStatus(String orderId, String status) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Map<String, dynamic>>> getFrequentCustomers() {
    throw UnimplementedError('API implementation pending');
  }
}
