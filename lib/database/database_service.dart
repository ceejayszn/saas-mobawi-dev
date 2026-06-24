import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kibandaski_pos.db');
    await _selfHeal(_database!);
    return _database!;
  }

  Future<void> _selfHeal(Database db) async {
    try {
      final orderCols = await db.rawQuery('PRAGMA table_info(orders)');
      if (!orderCols.any((col) => col['name'] == 'status')) {
        await db.execute('ALTER TABLE orders ADD COLUMN status TEXT DEFAULT "unpaid"');
      }
      if (!orderCols.any((col) => col['name'] == 'is_modified')) {
        await db.execute('ALTER TABLE orders ADD COLUMN is_modified INTEGER DEFAULT 0');
      }
      if (!orderCols.any((col) => col['name'] == 'payment_method')) {
        await db.execute('ALTER TABLE orders ADD COLUMN payment_method TEXT DEFAULT "cash"');
      }
      if (!orderCols.any((col) => col['name'] == 'cashier_name')) {
        await db.execute('ALTER TABLE orders ADD COLUMN cashier_name TEXT DEFAULT "unknown"');
      }
      if (!orderCols.any((col) => col['name'] == 'checkout_request_id')) {
        await db.execute('ALTER TABLE orders ADD COLUMN checkout_request_id TEXT DEFAULT ""');
      }



      final salesCols = await db.rawQuery('PRAGMA table_info(sales)');
      if (!salesCols.any((col) => col['name'] == 'sequence_id')) {
        await db.execute('ALTER TABLE sales ADD COLUMN sequence_id TEXT DEFAULT ""');
      }

      // V4: Add Suppliers and Expense Supplier ID
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='suppliers'");
      if (tables.isEmpty) {
        await db.execute('''
          CREATE TABLE suppliers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      }

      final expenseCols = await db.rawQuery('PRAGMA table_info(expenses)');
      if (!expenseCols.any((col) => col['name'] == 'supplier_id')) {
        await db.execute('ALTER TABLE expenses ADD COLUMN supplier_id INTEGER');
      }
      if (!expenseCols.any((col) => col['name'] == 'status')) {
        await db.execute("ALTER TABLE expenses ADD COLUMN status TEXT DEFAULT 'settled'");
      }
      if (!expenseCols.any((col) => col['name'] == 'payment_method')) {
        await db.execute("ALTER TABLE expenses ADD COLUMN payment_method TEXT DEFAULT 'cash'");
      }
      if (!expenseCols.any((col) => col['name'] == 'settled_amount')) {
        await db.execute("ALTER TABLE expenses ADD COLUMN settled_amount REAL DEFAULT 0.0");
      }

      // V5: Delivery Orders
      final delivTables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='delivery_orders'");
      if (delivTables.isEmpty) {
        await db.execute('''
          CREATE TABLE delivery_orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_name TEXT NOT NULL,
            location TEXT NOT NULL,
            total REAL NOT NULL,
            status TEXT DEFAULT 'pending',
            payment_method TEXT DEFAULT 'cash',
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE delivery_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL,
            item_id INTEGER NOT NULL,
            item_name TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            unit_price REAL NOT NULL,
            total REAL NOT NULL
          )
        ''');
      }

      // V6: Hired Personnel
      final hiredTables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='hired_personnel'");
      if (hiredTables.isEmpty) {
        await db.execute('''
          CREATE TABLE hired_personnel (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            role TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE personnel_jobs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            personnel_id INTEGER NOT NULL,
            job_title TEXT NOT NULL,
            amount REAL NOT NULL,
            duration TEXT NOT NULL,
            status TEXT DEFAULT 'unsettled',
            payment_method TEXT DEFAULT 'cash',
            created_at TEXT NOT NULL
          )
        ''');
      }
    } catch (e) {
      debugPrint('Self-heal failed: $e');
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE orders (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              sequence_id TEXT NOT NULL,
              total REAL NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
          await db.execute('ALTER TABLE sales ADD COLUMN sequence_id TEXT DEFAULT ""');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE orders ADD COLUMN status TEXT DEFAULT "unpaid"');
          await db.execute('ALTER TABLE orders ADD COLUMN is_modified INTEGER DEFAULT 0');
          await db.execute('ALTER TABLE orders ADD COLUMN payment_method TEXT DEFAULT "cash"');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE suppliers (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
          await db.execute('ALTER TABLE expenses ADD COLUMN supplier_id INTEGER');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE delivery_orders (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              customer_name TEXT NOT NULL,
              location TEXT NOT NULL,
              total REAL NOT NULL,
              status TEXT DEFAULT 'pending',
              payment_method TEXT DEFAULT 'cash',
              created_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE delivery_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              order_id INTEGER NOT NULL,
              item_id INTEGER NOT NULL,
              item_name TEXT NOT NULL,
              quantity INTEGER NOT NULL,
              unit_price REAL NOT NULL,
              total REAL NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Items (Menu)
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL
      )
    ''');

    // 2. Sales
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sequence_id TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        total REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 2.5 Orders
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sequence_id TEXT NOT NULL,
        total REAL NOT NULL,
        status TEXT DEFAULT 'unpaid',
        is_modified INTEGER DEFAULT 0,
        payment_method TEXT DEFAULT 'cash',
        cashier_name TEXT DEFAULT 'unknown',
        checkout_request_id TEXT DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');

    // 3. Production
    await db.execute('''
      CREATE TABLE production (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        quantity_produced INTEGER NOT NULL,
        session TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 4. Expenses
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        supplier_id INTEGER,
        status TEXT DEFAULT 'settled',
        payment_method TEXT DEFAULT 'cash',
        settled_amount REAL DEFAULT 0.0,
        created_at TEXT NOT NULL
      )
    ''');

    // 4.5 Suppliers
    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 5. Credits (Deni)
    await db.execute('''
      CREATE TABLE credits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT,
        amount REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 6. Bills
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL
      )
    ''');

    // 6.5 Hired Personnel
    await db.execute('''
      CREATE TABLE hired_personnel (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE personnel_jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        personnel_id INTEGER NOT NULL,
        job_title TEXT NOT NULL,
        amount REAL NOT NULL,
        duration TEXT NOT NULL,
        status TEXT DEFAULT 'unsettled',
        payment_method TEXT DEFAULT 'cash',
        created_at TEXT NOT NULL
      )
    ''');

    // Indexes for speed
    await db.execute('CREATE INDEX idx_sales_date ON sales(created_at)');
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(created_at)');

    // 7. Delivery Orders (outside hotel)
    await db.execute('''
      CREATE TABLE delivery_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        location TEXT NOT NULL,
        total REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        payment_method TEXT DEFAULT 'cash',
        created_at TEXT NOT NULL
      )
    ''');

    // 8. Delivery Items
    await db.execute('''
      CREATE TABLE delivery_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total REAL NOT NULL
      )
    ''');

    // Seed initial items
    await db.insert('items', {'name': 'Tea', 'price': 20.0});
    await db.insert('items', {'name': 'Mandazi', 'price': 10.0});
    await db.insert('items', {'name': 'Chapati', 'price': 15.0});
    await db.insert('items', {'name': 'Egg', 'price': 25.0});
    
    // Seed initial bills
    await db.insert('bills', {'name': 'Electricity', 'balance': 0.0});
    await db.insert('bills', {'name': 'Water', 'balance': 0.0});
  }

  // Generic query method
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

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
