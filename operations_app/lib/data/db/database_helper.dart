import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('euton_hotel.db');
    await _createMissingTables(_database!);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onOpen: _createMissingTables,
    );
  }

  Future _createDB(Database db, int version) async {
    await _createMissingTables(db);
    
    // Seed data
    await db.insert('menu_items', {'name': 'Tea', 'price': 20.0, 'is_active': 1});
    await db.insert('menu_items', {'name': 'Coffee', 'price': 30.0, 'is_active': 1});
    await db.insert('menu_items', {'name': 'Chapati', 'price': 15.0, 'is_active': 1});
    await db.insert('menu_items', {'name': 'Ugali Beans', 'price': 70.0, 'is_active': 1});
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _createMissingTables(db);
  }

  Future<void> _createMissingTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS menu_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        is_active INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS outside_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        location TEXT NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS outside_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        outside_order_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (outside_order_id) REFERENCES outside_orders (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        account_name TEXT DEFAULT 'General',
        status TEXT DEFAULT 'Settled'
      )
    ''');

    try {
      await db.execute("ALTER TABLE expenses ADD COLUMN account_name TEXT DEFAULT 'General'");
    } catch (_) {}
    try {
      await db.execute("ALTER TABLE expenses ADD COLUMN status TEXT DEFAULT 'Settled'");
    } catch (_) {}

    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT NOT NULL,
        quantity REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        log_id TEXT NOT NULL UNIQUE,
        module TEXT NOT NULL,
        action TEXT NOT NULL,
        entity TEXT NOT NULL,
        entity_id TEXT,
        user_name TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL,
        severity TEXT NOT NULL DEFAULT 'info',
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // --- GENERIC METHODS ---
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertOrder(Order order, List<OrderItem> items) async {
    return await createOrder(order, items);
  }

  // --- MENU ITEMS ---
  Future<int> insertMenuItem(MenuItem item) async {
    final db = await database;
    return await db.insert('menu_items', item.toMap());
  }

  Future<List<MenuItem>> getMenuItems() async {
    final db = await database;
    final result = await db.query('menu_items');
    return result.map((json) => MenuItem.fromMap(json)).toList();
  }
  
  Future<int> updateMenuItem(MenuItem item) async {
    final db = await database;
    return await db.update('menu_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  // --- ORDERS ---
  Future<int> createOrder(Order order, List<OrderItem> items) async {
    final db = await database;
    return await db.transaction((txn) async {
      int orderId = await txn.insert('orders', order.toMap());
      for (var item in items) {
        final itemMap = item.toMap();
        itemMap['order_id'] = orderId;
        await txn.insert('order_items', itemMap);
      }
      return orderId;
    });
  }

  Future<List<Order>> getDailyOrders(String date) async {
    final db = await database;
    final result = await db.query('orders', where: "strftime('%Y-%m-%d', created_at) = ?", whereArgs: [date]);
    return result.map((json) => Order.fromMap(json)).toList();
  }

  Future<List<Order>> getOrdersBetween(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => Order.fromMap(json)).toList();
  }

  Future<int> createOutsideOrder(OutsideOrder order, List<OrderItem> items) async {
    final db = await database;
    return await db.transaction((txn) async {
      final outsideOrderId = await txn.insert('outside_orders', order.toMap());
      for (final item in items) {
        final itemMap = item.toMap();
        itemMap.remove('order_id');
        itemMap['outside_order_id'] = outsideOrderId;
        await txn.insert('outside_order_items', itemMap);
      }
      return outsideOrderId;
    });
  }

  Future<List<OutsideOrder>> getOutsideOrdersByStatus(String status) async {
    final db = await database;
    final result = await db.query(
      'outside_orders',
      where: 'LOWER(status) = ?',
      whereArgs: [status.toLowerCase()],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => OutsideOrder.fromMap(json)).toList();
  }

  Future<List<OutsideOrder>> getOutsideOrdersBetween(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.query(
      'outside_orders',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => OutsideOrder.fromMap(json)).toList();
  }

  Future<void> markOutsideOrderPaid(int orderId, {String paymentMethod = 'Cash'}) async {
    final db = await database;
    await db.update(
      'outside_orders',
      {
        'status': 'Paid',
        'payment_method': paymentMethod,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> updateOutsideOrderStatus(int orderId, String status) async {
    final db = await database;
    await db.update(
      'outside_orders',
      {
        'status': status,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<List<Map<String, dynamic>>> getSalesSummaryBetween(DateTime start, DateTime end) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT item_name, SUM(quantity) AS quantity, SUM(quantity * price) AS total
      FROM (
        SELECT oi.item_name, oi.quantity, oi.price, o.created_at
        FROM order_items oi
        INNER JOIN orders o ON o.id = oi.order_id
        WHERE o.created_at >= ? AND o.created_at <= ?
        UNION ALL
        SELECT ooi.item_name, ooi.quantity, ooi.price, oo.created_at
        FROM outside_order_items ooi
        INNER JOIN outside_orders oo ON oo.id = ooi.outside_order_id
        WHERE oo.created_at >= ? AND oo.created_at <= ? AND LOWER(oo.status) = 'paid'
      )
      GROUP BY item_name
      ORDER BY total DESC, quantity DESC, item_name ASC
      ''',
      [
        start.toIso8601String(),
        end.toIso8601String(),
        start.toIso8601String(),
        end.toIso8601String(),
      ],
    );
  }

  // --- EXPENSES ---
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getDailyExpenses(String date) async {
    final db = await database;
    final result = await db.query('expenses', where: "strftime('%Y-%m-%d', date) = ?", whereArgs: [date]);
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<List<Expense>> getExpensesBetween(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getFrequentCustomers() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT customer_name, MAX(location) as last_location, COUNT(*) as total_orders, SUM(total) as total_spent
      FROM outside_orders
      GROUP BY customer_name
      ORDER BY total_orders DESC
    ''');
  }
}
