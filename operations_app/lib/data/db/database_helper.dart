import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';
import '../../utils/uuid.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('copy_app.db');
    await _createMissingTables(_database!);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 6, // v6: Added audit columns, business_id, and indexes
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onOpen: _createMissingTables,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await _createMissingTables(db);
    
    // Seed data with UUIDs
    final now = DateTime.now().toIso8601String();
    await db.insert('products', {'id': generateUuid(), 'name': 'Tea', 'price': 20.0, 'is_active': 1, 'business_id': '', 'created_at': now, 'updated_at': now});
    await db.insert('products', {'id': generateUuid(), 'name': 'Coffee', 'price': 30.0, 'is_active': 1, 'business_id': '', 'created_at': now, 'updated_at': now});
    await db.insert('products', {'id': generateUuid(), 'name': 'Chapati', 'price': 15.0, 'is_active': 1, 'business_id': '', 'created_at': now, 'updated_at': now});
    await db.insert('products', {'id': generateUuid(), 'name': 'Ugali Beans', 'price': 70.0, 'is_active': 1, 'business_id': '', 'created_at': now, 'updated_at': now});
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      // Full rebuild for pre-UUID schemas
      await db.execute('DROP TABLE IF EXISTS sale_items');
      await db.execute('DROP TABLE IF EXISTS sales');
      await db.execute('DROP TABLE IF EXISTS outside_sale_items');
      await db.execute('DROP TABLE IF EXISTS sales');
      await db.execute('DROP TABLE IF EXISTS products');
      await db.execute('DROP TABLE IF EXISTS expenses');
      await db.execute('DROP TABLE IF EXISTS inventory');
      await db.execute('DROP TABLE IF EXISTS audit_logs');
      await db.execute('DROP TABLE IF EXISTS sync_queue');
    } else if (oldVersion < 6) {
      // v5 → v6: Add audit columns and business_id to existing tables.
      // Using ALTER TABLE for non-destructive migration.
      final alterations = <String>[
        'ALTER TABLE products ADD COLUMN business_id TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE products ADD COLUMN created_at TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE products ADD COLUMN updated_at TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE sales ADD COLUMN business_id TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE sales ADD COLUMN updated_at TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE sale_items ADD COLUMN created_at TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE sales ADD COLUMN business_id TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE sales ADD COLUMN updated_at TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE outside_sale_items ADD COLUMN created_at TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE expenses ADD COLUMN business_id TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE expenses ADD COLUMN created_at TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE expenses ADD COLUMN updated_at TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE inventory ADD COLUMN business_id TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE inventory ADD COLUMN created_at TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE inventory ADD COLUMN updated_at TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE audit_logs ADD COLUMN business_id TEXT NOT NULL DEFAULT ""',
      ];
      for (final sql in alterations) {
        try {
          await db.execute(sql);
        } catch (_) {
          // Column already exists — safe to ignore in SQLite
        }
      }
    }
    await _createMissingTables(db);
  }

  Future<void> _createMissingTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        is_active INTEGER DEFAULT 1,
        business_id TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT '',
        updated_at TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        status TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'In-Store',
        customer_name TEXT,
        location TEXT,
        user TEXT,
        business_id TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_items (
        id TEXT PRIMARY KEY,
        sale_id TEXT NOT NULL,
        item_id TEXT NOT NULL,
        item_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        created_at TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL DEFAULT 'Other',
        date TEXT NOT NULL,
        account_name TEXT DEFAULT 'General',
        status TEXT DEFAULT 'Settled',
        user TEXT NOT NULL DEFAULT 'Admin',
        business_id TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT '',
        updated_at TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory (
        id TEXT PRIMARY KEY,
        item_name TEXT NOT NULL,
        quantity REAL NOT NULL,
        business_id TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT '',
        updated_at TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS audit_logs (
        id TEXT PRIMARY KEY,
        log_id TEXT NOT NULL UNIQUE,
        module TEXT NOT NULL,
        action TEXT NOT NULL,
        entity TEXT NOT NULL,
        entity_id TEXT,
        user_name TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL,
        severity TEXT NOT NULL DEFAULT 'info',
        business_id TEXT NOT NULL DEFAULT '',
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id TEXT PRIMARY KEY,
        endpoint TEXT NOT NULL,
        method TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        attempts INTEGER DEFAULT 0
      )
    ''');

    // ── Indexes for query performance ──────────────────────────────────────
    await db.execute('CREATE INDEX IF NOT EXISTS idx_orders_created_at ON sales (created_at)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_orders_business_id ON sales (business_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sale_items_order_id ON sale_items (order_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sales_status ON sales (status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales (created_at)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses (date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_business_id ON expenses (business_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs (timestamp)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sync_queue_created_at ON sync_queue (created_at)');
  }

  // --- GENERIC METHODS ---
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<String> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    final String id = data['id']?.toString() ?? generateUuid();
    final dataWithId = Map<String, dynamic>.from(data);
    dataWithId['id'] = id;
    await db.insert(table, dataWithId);
    return id;
  }

  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  // --- SYNC QUEUE METHODS ---
  Future<String> enqueueSyncItem(String endpoint, String method, String payload) async {
    final id = generateUuid();
    final db = await database;
    await db.insert('sync_queue', {
      'id': id,
      'endpoint': endpoint,
      'method': method,
      'payload': payload,
      'created_at': DateTime.now().toIso8601String(),
      'attempts': 0,
    });
    return id;
  }

  Future<List<SyncItem>> getPendingSyncItems() async {
    final db = await database;
    final result = await db.query('sync_queue', orderBy: 'created_at ASC');
    return result.map((json) => SyncItem.fromMap(json)).toList();
  }

  Future<void> deleteSyncItem(String id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementSyncAttempts(String id) async {
    final db = await database;
    await db.rawUpdate('UPDATE sync_queue SET attempts = attempts + 1 WHERE id = ?', [id]);
  }

  Future<String> insertOrder(Sale sale, List<SaleItem> items) async {
    return await createOrder(sale, items);
  }

  // --- MENU ITEMS ---
  Future<String> insertProduct(Product item) async {
    final db = await database;
    final id = item.id ?? generateUuid();
    final itemMap = item.toMap();
    itemMap['id'] = id;
    await db.insert('products', itemMap);
    return id;
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('products');
    return result.map((json) => Product.fromMap(json)).toList();
  }
  
  Future<int> updateProduct(Product item) async {
    final db = await database;
    return await db.update('products', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  // --- ORDERS ---
  Future<String> createOrder(Sale sale, List<SaleItem> items) async {
    final db = await database;
    final orderId = sale.id ?? generateUuid();
    return await db.transaction((txn) async {
      final orderMap = sale.toMap();
      orderMap['id'] = orderId;
      await txn.insert('sales', orderMap);
      for (var item in items) {
        final itemId = item.id ?? generateUuid();
        final itemMap = item.toMap();
        itemMap['id'] = itemId;
        itemMap['order_id'] = orderId;
        await txn.insert('sale_items', itemMap);
      }
      return orderId;
    });
  }

  Future<List<Sale>> getDailyOrders(String date) async {
    final db = await database;
    final result = await db.query('sales', where: "strftime('%Y-%m-%d', created_at) = ?", whereArgs: [date]);
    return result.map((json) => Sale.fromMap(json)).toList();
  }

  Future<List<Sale>> getOrdersBetween(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.query(
      'sales',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => Sale.fromMap(json)).toList();
  }

  Future<String> createSale(Sale sale, List<SaleItem> items) async {
    final db = await database;
    final outsideOrderId = sale.id ?? generateUuid();
    return await db.transaction((txn) async {
      final orderMap = sale.toMap();
      orderMap['id'] = outsideOrderId;
      await txn.insert('sales', orderMap);
      for (final item in items) {
        final itemId = item.id ?? generateUuid();
        final itemMap = item.toMap();
        itemMap['id'] = itemId;
        itemMap.remove('order_id');
        itemMap['outside_order_id'] = outsideOrderId;
        await txn.insert('outside_sale_items', itemMap);
      }
      return outsideOrderId;
    });
  }

  Future<List<Sale>> getSalesByStatus(String status) async {
    final db = await database;
    final result = await db.query(
      'sales',
      where: 'LOWER(status) = ?',
      whereArgs: [status.toLowerCase()],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => Sale.fromMap(json)).toList();
  }

  Future<List<Sale>> getSalesBetween(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.query(
      'sales',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => Sale.fromMap(json)).toList();
  }

  Future<void> markSalePaid(String orderId, {String paymentMethod = 'Cash'}) async {
    final db = await database;
    await db.update(
      'sales',
      {
        'status': 'Paid',
        'payment_method': paymentMethod,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> updateSaleStatus(String orderId, String status) async {
    final db = await database;
    await db.update(
      'sales',
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
      SELECT item_name, SUM(quantity) AS quantity, SUM(quantity * price) AS amount
      FROM (
        SELECT oi.item_name, oi.quantity, oi.price, o.created_at
        FROM sale_items oi
        INNER JOIN sales o ON o.id = oi.order_id
        WHERE o.created_at >= ? AND o.created_at <= ?
        UNION ALL
        SELECT ooi.item_name, ooi.quantity, ooi.price, oo.created_at
        FROM outside_sale_items ooi
        INNER JOIN sales oo ON oo.id = ooi.outside_order_id
        WHERE oo.created_at >= ? AND oo.created_at <= ? AND LOWER(oo.status) = 'paid'
      )
      GROUP BY item_name
      ORDER BY amount DESC, quantity DESC, item_name ASC
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
  Future<String> insertExpense(Expense expense) async {
    final db = await database;
    final id = expense.id ?? generateUuid();
    final expenseMap = expense.toMap();
    expenseMap['id'] = id;
    await db.insert('expenses', expenseMap);
    return id;
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
      SELECT customer_name, MAX(location) as last_location, COUNT(*) as amount_orders, SUM(amount) as amount_spent
      FROM sales
      GROUP BY customer_name
      ORDER BY amount_orders DESC
    ''');
  }
}
