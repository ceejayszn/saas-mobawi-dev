import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database/database_service.dart';
import '../models/kiosk_models.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sync_service.dart';

class SalesService with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<KioskItem> _items = [];
  List<Sale> _dailySales = [];
  List<KioskOrder> _dailyOrders = [];
  final Map<KioskItem, int> _cart = {};
  bool _isLoading = false;

  List<KioskItem> get items => _items;
  List<Sale> get dailySales => _dailySales;
  List<KioskOrder> get dailyOrders => _dailyOrders;
  Map<KioskItem, int> get cart => _cart;
  bool get isLoading => _isLoading;
  
  double get cartTotal => _cart.entries.fold(0.0, (sum, entry) => sum + (entry.key.price * entry.value));

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    final data = await _db.queryAll('items');
    _items = data.map((e) => KioskItem.fromMap(e)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMenuItem(String name, double price) async {
    await _db.insert('items', {'name': name, 'price': price});
    await loadItems();
  }

  Future<void> updateMenuItem(int id, String name, double price) async {
    await _db.update('items', {'name': name, 'price': price}, id);
    await loadItems();
  }

  Future<void> deleteMenuItem(int id) async {
    await _db.database.then((db) => db.delete('items', where: 'id = ?', whereArgs: [id]));
    await loadItems();
  }

  Future<void> loadDailySales() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final data = await _db.database.then((db) => db.query('sales', 
      where: "strftime('%Y-%m-%d', created_at) = ?", 
      whereArgs: [today]));
    _dailySales = data.map((e) => Sale.fromMap(e)).toList();

    final orderData = await _db.database.then((db) => db.query('orders', 
      where: "strftime('%Y-%m-%d', created_at) = ?", 
      whereArgs: [today],
      orderBy: 'created_at DESC'));
    _dailyOrders = orderData.map((e) => KioskOrder.fromMap(e)).toList();

    notifyListeners();
  }

  void addToCart(KioskItem item) {
    _cart[item] = (_cart[item] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromCart(KioskItem item) {
    if (_cart.containsKey(item)) {
      if (_cart[item]! > 1) {
        _cart[item] = _cart[item]! - 1;
      } else {
        _cart.remove(item);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    orderToEdit = null;
    notifyListeners();
  }

  KioskOrder? orderToEdit;

  Future<void> loadOrderIntoCart(KioskOrder order) async {
    clearCart();
    orderToEdit = order;
    final sales = await getOrderSales(order.sequenceId);
    for (var sale in sales) {
      final item = _items.firstWhere((i) => i.id == sale.itemId);
      _cart[item] = sale.quantity;
    }
    notifyListeners();
  }

  Future<List<Sale>> getOrderSales(String sequenceId) async {
    final data = await _db.database.then((db) => db.query('sales', where: 'sequence_id = ?', whereArgs: [sequenceId]));
    return data.map((e) => Sale.fromMap(e)).toList();
  }

  Future<void> markOrderPaid(String sequenceId, {String method = 'cash', String checkoutRequestId = ''}) async {
    final db = await _db.database;
    final Map<String, dynamic> updateData = {
      'status': 'paid',
      'payment_method': method,
    };
    if (checkoutRequestId.isNotEmpty) {
      updateData['checkout_request_id'] = checkoutRequestId;
    }
    await db.update('orders', updateData, where: 'sequence_id = ?', whereArgs: [sequenceId]);
    await loadDailySales();
    SyncService.instance.syncData();
  }

  Future<void> updateOrderCheckoutId(String sequenceId, String checkoutId) async {
    final db = await _db.database;
    await db.update('orders', {'checkout_request_id': checkoutId}, where: 'sequence_id = ?', whereArgs: [sequenceId]);
    await loadDailySales();
    SyncService.instance.syncData();
  }

  Future<void> checkout() async {
    if (_cart.isEmpty) return;

    String sequenceId;
    String status = 'unpaid';
    bool isModified = false;
    String cashier = 'unknown';

    try {
      final prefs = await SharedPreferences.getInstance();
      cashier = prefs.getString('cashier_username') ?? 'unknown';
    } catch (_) {}

    if (orderToEdit != null) {
      sequenceId = orderToEdit!.sequenceId;
      status = 'unpaid'; // Reset to unpaid when modified
      isModified = true;
      final db = await _db.database;
      await db.delete('orders', where: 'sequence_id = ?', whereArgs: [sequenceId]);
      await db.delete('sales', where: 'sequence_id = ?', whereArgs: [sequenceId]);
    } else {
      sequenceId = await _generateSequenceId();
    }
    
    final total = cartTotal;
    
    final order = KioskOrder(
      sequenceId: sequenceId,
      total: total,
      status: status,
      isModified: isModified,
      cashierName: cashier,
      createdAt: DateTime.now(),
    );

    // Save order
    await _db.insert('orders', order.toMap());

    // Save sales
    for (var entry in _cart.entries) {
      final sale = Sale(
        sequenceId: sequenceId,
        itemId: entry.key.id!,
        quantity: entry.value,
        total: entry.key.price * entry.value,
        createdAt: DateTime.now(),
      );
      await _db.insert('sales', sale.toMap());
    }

    clearCart();
    await loadDailySales();
    SyncService.instance.syncData();
  }

  Future<String> _generateSequenceId() async {
    final db = await _db.database;
    final result = await db.rawQuery("SELECT DISTINCT date(created_at) as dt FROM orders ORDER BY dt ASC");
    final dates = result.map((row) => row['dt'] as String).toList();
    
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (!dates.contains(today)) {
      dates.add(today);
    }
    final dayIndex = dates.indexOf(today);
    final letterPrefix = _getLetterSequence(dayIndex);
    
    final countResult = await db.rawQuery(
      "SELECT COUNT(*) as c FROM orders WHERE date(created_at) = ?", 
      [today]
    );
    int count = countResult.isNotEmpty ? (countResult.first['c'] as int) : 0;
    
    return '$letterPrefix${count + 1}';
  }

  String _getLetterSequence(int dayIndex) {
    String result = '';
    int curr = dayIndex;
    while (curr >= 0) {
      result = String.fromCharCode(97 + (curr % 26)) + result;
      curr = (curr ~/ 26) - 1;
    }
    return result;
  }
}

class ProductionService with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<Production> _dailyProduction = [];

  List<Production> get dailyProduction => _dailyProduction;

  Future<void> loadDailyProduction() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final data = await _db.database.then((db) => db.query('production', 
      where: "strftime('%Y-%m-%d', created_at) = ?", 
      whereArgs: [today]));
    _dailyProduction = data.map((e) => Production.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addProduction(int itemId, int quantity, String session) async {
    final prod = Production(
      itemId: itemId,
      quantityProduced: quantity,
      session: session,
      createdAt: DateTime.now(),
    );
    await _db.insert('production', prod.toMap());
    await loadDailyProduction();
  }

  int getProducedCount(int itemId) {
    return _dailyProduction
        .where((p) => p.itemId == itemId)
        .fold(0, (sum, p) => sum + p.quantityProduced);
  }
}

class ExpenseService with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<Expense> _dailyExpenses = [];

  List<Expense> get dailyExpenses => _dailyExpenses;
  double get totalDailyExpenses => _dailyExpenses.fold(0.0, (sum, e) => sum + e.amount);

  Future<void> loadDailyExpenses({int? supplierId}) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String whereStr = "strftime('%Y-%m-%d', created_at) = ?";
    List<dynamic> whereArgs = [today];
    if (supplierId != null) {
      whereStr += " AND supplier_id = ?";
      whereArgs.add(supplierId);
    }
    final data = await _db.database.then((db) => db.query('expenses', 
      where: whereStr, 
      whereArgs: whereArgs));
    _dailyExpenses = data.map((e) => Expense.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addExpense(String name, double amount, {int? supplierId, String status = 'settled', String paymentMethod = 'cash', double settledAmount = 0.0}) async {
    final exp = Expense(
      name: name,
      amount: amount,
      supplierId: supplierId,
      status: status,
      paymentMethod: paymentMethod,
      settledAmount: settledAmount,
      createdAt: DateTime.now(),
    );
    await _db.insert('expenses', exp.toMap());
    await loadDailyExpenses(supplierId: supplierId);
  }

  Future<void> settleExpense(int id, double payAmount, String method, {int? supplierId}) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> res = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) {
      final current = Expense.fromMap(res.first);
      final newSettled = current.settledAmount + payAmount;
      final newStatus = newSettled >= current.amount ? 'settled' : 'unsettled';
      await db.update('expenses', {
        'settled_amount': newSettled,
        'status': newStatus,
        'payment_method': method,
      }, where: 'id = ?', whereArgs: [id]);
      await loadDailyExpenses(supplierId: supplierId);
    }
  }
}

class SupplierService with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<Supplier> _suppliers = [];

  List<Supplier> get suppliers => _suppliers;

  Future<void> loadSuppliers() async {
    final data = await _db.queryAll('suppliers');
    _suppliers = data.map((e) => Supplier.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addSupplier(String name) async {
    final supplier = Supplier(name: name, createdAt: DateTime.now());
    await _db.insert('suppliers', supplier.toMap());
    await loadSuppliers();
  }
}

class SummaryService with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
  double _totalRevenue = 0;
  int _totalItemsSold = 0;

  double get totalRevenue => _totalRevenue;
  int get totalItemsSold => _totalItemsSold;

  Future<void> refreshSummary() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final db = await _db.database;
    
    final orderData = await db.rawQuery(
      "SELECT SUM(total) as t FROM orders WHERE date(created_at) = ? AND status = 'paid'", 
      [today]
    );
    _totalRevenue = (orderData.isNotEmpty && orderData.first['t'] != null) ? (orderData.first['t'] as double) : 0.0;
    
    final salesData = await db.rawQuery(
      "SELECT SUM(s.quantity) as q FROM sales s JOIN orders o ON s.sequence_id = o.sequence_id WHERE date(o.created_at) = ? AND o.status = 'paid'",
      [today]
    );
    _totalItemsSold = (salesData.isNotEmpty && salesData.first['q'] != null) ? (salesData.first['q'] as int) : 0;
    
    notifyListeners();
  }
}

class CreditService with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<Credit> _credits = [];

  List<Credit> get unpaidCredits => _credits.where((c) => c.status == 'unpaid').toList();

  Future<void> loadCredits() async {
    final data = await _db.queryAll('credits');
    _credits = data.map((e) => Credit.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addCredit(String? name, double amount) async {
    final credit = Credit(
      customerName: name,
      amount: amount,
      status: 'unpaid',
      createdAt: DateTime.now(),
    );
    await _db.insert('credits', credit.toMap());
    await loadCredits();
  }

  Future<void> markAsPaid(int id) async {
    await _db.update('credits', {'status': 'paid'}, id);
    await loadCredits();
  }
}

class BillService with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<Bill> _bills = [];

  List<Bill> get bills => _bills;

  Future<void> loadBills() async {
    final data = await _db.queryAll('bills');
    _bills = data.map((e) => Bill.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> updateBalance(int id, double newBalance) async {
    await _db.update('bills', {'balance': newBalance}, id);
    await loadBills();
  }
}

class AnalysisService with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  bool _isLoading = false;
  double _totalRevenue = 0;
  double _totalExpenses = 0;
  int _totalSold = 0;
  int _totalProduced = 0;
  double _totalDeni = 0;
  double _totalMpesa = 0;
  double _totalCash = 0;
  double _totalUnsettledBills = 0;
  List<Map<String, dynamic>> _topItems = [];
  List<Map<String, dynamic>> _fullSales = [];
  List<Map<String, dynamic>> _supplierExpenses = [];
  Map<String, double> _hourlySales = {};
  double _deliveryRevenue = 0;
  Set<DateTime> _activeDates = {};
  List<Map<String, dynamic>> _activeCashiers = [];
  List<Map<String, dynamic>> _localCashiers = [];
  List<HiredPersonnel> _personnel = [];
  List<PersonnelJob> _personnelJobs = [];

  List<KioskOrder> _rangeOrders = [];
  List<Expense> _rangeExpenses = [];
  List<Credit> _rangeCredits = [];
  List<DeliveryOrder> _rangeDeliveries = [];

  bool get isLoading => _isLoading;
  double get totalRevenue => _totalRevenue;
  double get totalExpenses => _totalExpenses;
  int get totalSold => _totalSold;
  int get totalProduced => _totalProduced;
  double get totalDeni => _totalDeni;
  double get totalMpesa => _totalMpesa;
  double get totalCash => _totalCash;
  double get totalUnsettledBills => _totalUnsettledBills;
  List<Map<String, dynamic>> get topItems => _topItems;
  List<Map<String, dynamic>> get fullSales => _fullSales;
  List<Map<String, dynamic>> get supplierExpenses => _supplierExpenses;
  Map<String, double> get hourlySales => _hourlySales;
  double get deliveryRevenue => _deliveryRevenue;
  Set<DateTime> get activeDates => _activeDates;
  List<Map<String, dynamic>> get activeCashiers => _activeCashiers;
  List<Map<String, dynamic>> get localCashiers => _localCashiers;
  List<HiredPersonnel> get personnel => _personnel;
  List<PersonnelJob> get personnelJobs => _personnelJobs;

  List<KioskOrder> get rangeOrders => _rangeOrders;
  List<Expense> get rangeExpenses => _rangeExpenses;
  List<Credit> get rangeCredits => _rangeCredits;
  List<DeliveryOrder> get rangeDeliveries => _rangeDeliveries;

  Future<void> loadPersonnel() async {
    final db = await _db.database;
    final data = await db.query('hired_personnel', orderBy: 'id DESC');
    _personnel = data.map((e) => HiredPersonnel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> loadPersonnelJobs() async {
    final db = await _db.database;
    final data = await db.query('personnel_jobs', orderBy: 'id DESC');
    _personnelJobs = data.map((e) => PersonnelJob.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addPersonnel(String name, String phone, String role) async {
    final hp = HiredPersonnel(name: name, phone: phone, role: role, createdAt: DateTime.now());
    await _db.insert('hired_personnel', hp.toMap());
    await loadPersonnel();
  }

  Future<void> deletePersonnel(int id) async {
    final db = await _db.database;
    await db.delete('hired_personnel', where: 'id = ?', whereArgs: [id]);
    await db.delete('personnel_jobs', where: 'personnel_id = ?', whereArgs: [id]);
    await loadPersonnel();
    await loadPersonnelJobs();
  }

  Future<void> addPersonnelJob(int personnelId, String jobTitle, double amount, String duration, {String status = 'unsettled'}) async {
    final job = PersonnelJob(
      personnelId: personnelId,
      jobTitle: jobTitle,
      amount: amount,
      duration: duration,
      status: status,
      createdAt: DateTime.now(),
    );
    await _db.insert('personnel_jobs', job.toMap());
    await loadPersonnelJobs();
  }

  Future<void> settlePersonnelJob(int jobId, String paymentMethod) async {
    final db = await _db.database;
    await db.update('personnel_jobs', {
      'status': 'settled',
      'payment_method': paymentMethod,
    }, where: 'id = ?', whereArgs: [jobId]);
    await loadPersonnelJobs();
  }

  Future<void> loadLocalCashiers() async {
    final db = await _db.database;
    final data = await db.rawQuery('''
      SELECT cashier_name, COUNT(*) as input_count
      FROM orders
      GROUP BY cashier_name
      ORDER BY input_count DESC
    ''');
    _localCashiers = data;
    notifyListeners();
  }

  Future<void> loadActiveDates() async {
    final db = await _db.database;
    final data = await db.rawQuery("SELECT DISTINCT date(created_at) as d FROM orders WHERE status = 'paid'");
    _activeDates = data.map((e) => DateTime.parse(e['d'] as String)).toSet();
    notifyListeners();
  }

  Future<void> loadActiveCashiers() async {
    try {
      final baseUrl = await SyncService.instance.getBaseUrl();
      final url = Uri.parse('$baseUrl/get_data.php?action=active_cashiers');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          _activeCashiers = List<Map<String, dynamic>>.from(result['data']);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading active cashiers: $e');
    }
  }

  Future<void> loadData(String rangeType) async {
    _isLoading = true;
    notifyListeners();
    
    final db = await _db.database;
    String dateCondition;
    
    if (rangeType == 'today') {
      dateCondition = "date(created_at) = date('now', 'localtime')";
    } else if (rangeType == 'week') {
      dateCondition = "date(created_at) >= date('now', 'localtime', '-7 days')";
    } else if (rangeType == 'month') {
      dateCondition = "date(created_at) >= date('now', 'localtime', 'start of month')";
    } else if (rangeType.startsWith('date:')) {
      final specificDate = rangeType.split(':')[1]; // e.g. 2026-06-18
      dateCondition = "date(created_at) = '$specificDate'";
    } else {
      dateCondition = "date(created_at) >= date('now', 'localtime', 'start of month')";
    }

    try {
      // Revenue (Paid orders only)
      final revData = await db.rawQuery("SELECT SUM(total) as t FROM orders WHERE $dateCondition AND status = 'paid'");
      _totalRevenue = revData.isNotEmpty && revData.first['t'] != null ? revData.first['t'] as double : 0.0;

      // Mpesa
      final mpesaData = await db.rawQuery("SELECT SUM(total) as t FROM orders WHERE $dateCondition AND status = 'paid' AND payment_method = 'mpesa'");
      _totalMpesa = mpesaData.isNotEmpty && mpesaData.first['t'] != null ? mpesaData.first['t'] as double : 0.0;

      // Cash
      final cashData = await db.rawQuery("SELECT SUM(total) as t FROM orders WHERE $dateCondition AND status = 'paid' AND payment_method = 'cash'");
      _totalCash = cashData.isNotEmpty && cashData.first['t'] != null ? cashData.first['t'] as double : 0.0;

      // Unpaid Deni (From credits table)
      final deniData = await db.rawQuery("SELECT SUM(amount) as t FROM credits WHERE status = 'unpaid'");
      _totalDeni = deniData.isNotEmpty && deniData.first['t'] != null ? deniData.first['t'] as double : 0.0;

      // Unsettled Expenses (balance to settle)
      final unsettledExpData = await db.rawQuery("SELECT SUM(amount - settled_amount) as t FROM expenses WHERE status = 'unsettled'");
      final unsettledExp = unsettledExpData.isNotEmpty && unsettledExpData.first['t'] != null ? unsettledExpData.first['t'] as double : 0.0;

      // Unsettled Personnel Jobs
      final unsettledJobsData = await db.rawQuery("SELECT SUM(amount) as t FROM personnel_jobs WHERE status = 'unsettled'");
      final unsettledJobs = unsettledJobsData.isNotEmpty && unsettledJobsData.first['t'] != null ? unsettledJobsData.first['t'] as double : 0.0;

      _totalUnsettledBills = _totalDeni + unsettledExp + unsettledJobs;

      // Expenses
      final expData = await db.rawQuery("SELECT SUM(amount) as t FROM expenses WHERE $dateCondition");
      _totalExpenses = expData.isNotEmpty && expData.first['t'] != null ? expData.first['t'] as double : 0.0;

      // Total Items Produced
      final prodData = await db.rawQuery("SELECT SUM(quantity_produced) as q FROM production WHERE $dateCondition");
      _totalProduced = prodData.isNotEmpty && prodData.first['q'] != null ? prodData.first['q'] as int : 0;

      // Total Items Sold (From sales joined to paid orders)
      final soldData = await db.rawQuery("SELECT SUM(s.quantity) as q FROM sales s JOIN orders o ON s.sequence_id = o.sequence_id WHERE date(o.created_at) = date(s.created_at) AND ${dateCondition.replaceAll('created_at', 'o.created_at')} AND o.status = 'paid'");
      _totalSold = soldData.isNotEmpty && soldData.first['q'] != null ? soldData.first['q'] as int : 0;

      // Top Items (Limit 5)
      final topData = await db.rawQuery('''
        SELECT i.name, SUM(s.quantity) as qty
        FROM sales s
        JOIN items i ON s.item_id = i.id
        JOIN orders o ON s.sequence_id = o.sequence_id
        WHERE ${dateCondition.replaceAll('created_at', 'o.created_at')} AND o.status = 'paid'
        GROUP BY i.name
        ORDER BY qty DESC
        LIMIT 5
      ''');
      
      _topItems = topData.map((e) => {
        'name': e['name'] as String,
        'qty': e['qty'] as int,
      }).toList();

      // Full Sales Summary
      final fullSalesData = await db.rawQuery('''
        SELECT i.name, SUM(s.quantity) as qty, SUM(s.total) as rev
        FROM sales s
        JOIN items i ON s.item_id = i.id
        JOIN orders o ON s.sequence_id = o.sequence_id
        WHERE ${dateCondition.replaceAll('created_at', 'o.created_at')} AND o.status = 'paid'
        GROUP BY i.name
        ORDER BY rev DESC
      ''');
      
      _fullSales = fullSalesData.map((e) => {
        'name': e['name'] as String,
        'qty': e['qty'] as int,
        'rev': e['rev'] as double,
      }).toList();

      // Supplier Expenses Summary
      final supplierExpData = await db.rawQuery('''
        SELECT COALESCE(s.name, 'General') as supplier, SUM(e.amount) as total
        FROM expenses e
        LEFT JOIN suppliers s ON e.supplier_id = s.id
        WHERE ${dateCondition.replaceAll('created_at', 'e.created_at')}
        GROUP BY supplier
        ORDER BY total DESC
      ''');

      _supplierExpenses = supplierExpData.map((e) => {
        'supplier': e['supplier'] as String,
        'total': e['total'] as double,
      }).toList();

      // Hourly Sales Data (for line chart)
      final hourlyData = await db.rawQuery('''
        SELECT strftime('%H', created_at) as hour, SUM(total) as amount
        FROM orders
        WHERE $dateCondition AND status = 'paid'
        GROUP BY hour
        ORDER BY hour ASC
      ''');
      
      _hourlySales = {};
      for (var row in hourlyData) {
        if (row['hour'] != null && row['amount'] != null) {
          _hourlySales[row['hour'].toString()] = row['amount'] as double;
        }
      }

      // Delivery (Outside) Orders Revenue
      final delivRevData = await db.rawQuery(
        "SELECT SUM(total) as t FROM delivery_orders WHERE $dateCondition AND status = 'paid'"
      );
      _deliveryRevenue = delivRevData.isNotEmpty && delivRevData.first['t'] != null
          ? delivRevData.first['t'] as double
          : 0.0;

      // Load range breakdown details
      final ordersData = await db.rawQuery("SELECT * FROM orders WHERE $dateCondition ORDER BY created_at DESC");
      _rangeOrders = ordersData.map((e) => KioskOrder.fromMap(e)).toList();

      final expListData = await db.rawQuery("SELECT * FROM expenses WHERE $dateCondition ORDER BY created_at DESC");
      _rangeExpenses = expListData.map((e) => Expense.fromMap(e)).toList();

      final creditsData = await db.rawQuery("SELECT * FROM credits WHERE status = 'unpaid' ORDER BY created_at DESC");
      _rangeCredits = creditsData.map((e) => Credit.fromMap(e)).toList();

      final delivDataList = await db.rawQuery("SELECT * FROM delivery_orders WHERE $dateCondition ORDER BY created_at DESC");
      _rangeDeliveries = delivDataList.map((e) => DeliveryOrder.fromMap(e)).toList();

    } catch (e) {
      debugPrint('Analytics Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}

// ─── DELIVERY SERVICE ────────────────────────────────────────────────────────

class DeliveryService with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<DeliveryOrder> _orders = [];

  List<DeliveryOrder> get orders => _orders;
  List<DeliveryOrder> get pendingOrders => _orders.where((o) => o.status == 'pending').toList();
  List<DeliveryOrder> get paidOrders => _orders.where((o) => o.status == 'paid').toList();

  Future<void> loadOrders() async {
    final db = await _db.database;
    final data = await db.query('delivery_orders', orderBy: 'created_at DESC');
    _orders = data.map((e) => DeliveryOrder.fromMap(e)).toList();
    notifyListeners();
  }

  Future<int> createOrder(String customerName, String location, List<Map<String, dynamic>> items) async {
    final db = await _db.database;
    final total = items.fold<double>(0, (s, i) => s + (i['total'] as double));
    final orderId = await db.insert('delivery_orders', {
      'customer_name': customerName,
      'location': location,
      'total': total,
      'status': 'pending',
      'payment_method': 'cash',
      'created_at': DateTime.now().toIso8601String(),
    });
    for (final item in items) {
      await db.insert('delivery_items', {
        'order_id': orderId,
        'item_id': item['itemId'],
        'item_name': item['itemName'],
        'quantity': item['quantity'],
        'unit_price': item['unitPrice'],
        'total': item['total'],
      });
    }
    await loadOrders();
    return orderId;
  }

  Future<List<DeliveryItem>> getOrderItems(int orderId) async {
    final db = await _db.database;
    final data = await db.query('delivery_items', where: 'order_id = ?', whereArgs: [orderId]);
    return data.map((e) => DeliveryItem.fromMap(e)).toList();
  }

  Future<void> updateOrder(int orderId, String customerName, String location, List<Map<String, dynamic>> items) async {
    final db = await _db.database;
    final total = items.fold<double>(0, (s, i) => s + (i['total'] as double));
    await db.update('delivery_orders', {
      'customer_name': customerName,
      'location': location,
      'total': total,
    }, where: 'id = ?', whereArgs: [orderId]);
    await db.delete('delivery_items', where: 'order_id = ?', whereArgs: [orderId]);
    for (final item in items) {
      await db.insert('delivery_items', {
        'order_id': orderId,
        'item_id': item['itemId'],
        'item_name': item['itemName'],
        'quantity': item['quantity'],
        'unit_price': item['unitPrice'],
        'total': item['total'],
      });
    }
    await loadOrders();
  }

  Future<void> markOrderPaid(int orderId, {String method = 'cash'}) async {
    final db = await _db.database;
    await db.update('delivery_orders', {'status': 'paid', 'payment_method': method},
        where: 'id = ?', whereArgs: [orderId]);
    await loadOrders();
  }

  Future<void> deleteOrder(int orderId) async {
    final db = await _db.database;
    await db.delete('delivery_items', where: 'order_id = ?', whereArgs: [orderId]);
    await db.delete('delivery_orders', where: 'id = ?', whereArgs: [orderId]);
    await loadOrders();
  }
}
