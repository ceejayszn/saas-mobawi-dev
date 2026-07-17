import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/api/api_client.dart';
import 'i_report_repository.dart';

class ApiReportRepository implements IReportRepository {
  @override
  Future<ReportSummary> getSummary({required DateTime from, required DateTime to}) async {
    try {
      final response = await ApiClient.instance.get('/api/reports/summary');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ReportSummary(
          todaySales: (data['todaySales'] as num?)?.toDouble() ?? 0.0,
          weeklySales: (data['weeklySales'] as num?)?.toDouble() ?? 0.0,
          monthlySales: (data['monthlySales'] as num?)?.toDouble() ?? 0.0,
          annualSales: (data['annualSales'] as num?)?.toDouble() ?? 0.0,
          totalOrders: data['totalOrders'] as int? ?? 0,
          paidOrders: data['paidOrders'] as int? ?? 0,
          pendingOrders: data['pendingOrders'] as int? ?? 0,
          deliveries: data['deliveries'] as int? ?? 0,
          totalExpenses: (data['totalExpenses'] as num?)?.toDouble() ?? 0.0,
          netProfit: (data['netProfit'] as num?)?.toDouble() ?? 0.0,
          cashRevenue: (data['cashRevenue'] as num?)?.toDouble() ?? 0.0,
          mpesaRevenue: (data['mpesaRevenue'] as num?)?.toDouble() ?? 0.0,
          staffOnDuty: data['staffOnDuty'] as int? ?? 0,
          lowStockItems: data['lowStockItems'] as int? ?? 0,
        );
      }
    } catch (e) {
      debugPrint('ApiReportRepository getSummary error: $e');
    }
    return const ReportSummary();
  }

  @override
  Future<List<DailySaleItem>> getDailyItemSales(DateTime date) async {
    try {
      final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final response = await ApiClient.instance.get('/api/reports/daily-sales?date=$formattedDate');
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) {
          return DailySaleItem(
            itemName: item['itemName'] as String? ?? 'POS Order',
            quantity: item['quantity'] as int? ?? 1,
            unitPrice: (item['unitPrice'] as num?)?.toDouble() ?? 0.0,
            totalPrice: (item['totalPrice'] as num?)?.toDouble() ?? 0.0,
            orderTime: DateTime.parse(item['orderTime'] as String),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiReportRepository getDailyItemSales error: $e');
    }
    return [];
  }
}
