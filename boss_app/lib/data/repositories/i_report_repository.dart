// Abstract repository interface for Report data
// Implementations can switch between local storage, mock, or REST API
// without changing any UI code.

class ReportSummary {
  final double todaySales;
  final double weeklySales;
  final double monthlySales;
  final double annualSales;
  final int totalOrders;
  final int paidOrders;
  final int pendingOrders;
  final int deliveries;
  final double totalExpenses;
  final double netProfit;
  final double cashRevenue;
  final double mpesaRevenue;
  final int staffOnDuty;
  final int lowStockItems;

  const ReportSummary({
    this.todaySales = 0,
    this.weeklySales = 0,
    this.monthlySales = 0,
    this.annualSales = 0,
    this.totalOrders = 0,
    this.paidOrders = 0,
    this.pendingOrders = 0,
    this.deliveries = 0,
    this.totalExpenses = 0,
    this.netProfit = 0,
    this.cashRevenue = 0,
    this.mpesaRevenue = 0,
    this.staffOnDuty = 0,
    this.lowStockItems = 0,
  });
}

class DailySaleItem {
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime orderTime;

  const DailySaleItem({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.orderTime,
  });
}

abstract class IReportRepository {
  Future<ReportSummary> getSummary({
    required DateTime from,
    required DateTime to,
  });

  Future<List<DailySaleItem>> getDailyItemSales(DateTime date);
}
