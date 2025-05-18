import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await initDb();
      return _db!;
    }
    return _db!;
  }

  Future<Database> initDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'shop.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT,
        timestamp INTEGER,
        isSync INTEGER
      )
    ''');

    await db.execute('''
  CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address TEXT,
    timestamp INTEGER,
    isSync INTEGER
  )
''');


    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY,
        customerId TEXT NOT NULL,
        customerName TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        createdAt TEXT,
        isPaid INTEGER NOT NULL,
        debtDate TEXT,
        isSync INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY,
        customerId TEXT NOT NULL,
        customerName TEXT NOT NULL,
        customerPhone TEXT,
        totalDebt REAL NOT NULL,
        debtDiscount REAL NOT NULL,
        debtDate INTEGER NOT NULL,
        isSyns INTEGER
      )
    ''');
  }

  Future<int> newId(String table, String column) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery('SELECT MAX($column) as maxId FROM $table');
    return (result.first['maxId'] as int? ?? 0) + 1;
  }

  Future<bool> checkIfitemExists(String table, int id, String column) async {
    try {
      final db = await sqlState.db;
      final result = await db.query(table, where: '$column = ?', whereArgs: [id]);
      bool exists = result.isNotEmpty;
      print('===== التحقق من وجود $table.$column = $id: $exists =====');
      return exists;
    } catch (e) {
      print('===== خطأ في التحقق من وجود العنصر: $e =====');
      return false;
    }
  }


  Future<int> insertData(String sql) async {
    final dbClient = await db;
    return await dbClient.rawInsert(sql);
  }

  Future<int> updateData(String sql) async {
    final dbClient = await db;
    return await dbClient.rawUpdate(sql);
  }

  Future<int> deleteData(String sql) async {
    final dbClient = await db;
    return await dbClient.rawDelete(sql);
  }
}

SqlDb sqlState = SqlDb();