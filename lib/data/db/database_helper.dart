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
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT NOT NULL,
        quantity REAL NOT NULL
      )
    ''');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE menu_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        is_active INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
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
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT NOT NULL,
        quantity REAL NOT NULL
      )
    ''');
    
    // Seed data
    await db.insert('menu_items', {'name': 'Tea', 'price': 20.0, 'is_active': 1});
    await db.insert('menu_items', {'name': 'Coffee', 'price': 30.0, 'is_active': 1});
    await db.insert('menu_items', {'name': 'Chapati', 'price': 15.0, 'is_active': 1});
    await db.insert('menu_items', {'name': 'Ugali Beans', 'price': 70.0, 'is_active': 1});
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration logic if needed
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
}
