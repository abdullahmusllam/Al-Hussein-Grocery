// يجب حفظ هذا الملف لإنشاء اي قاعدة بيانات

import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  // this is made to not make init again and again
  static Database? _db;
  Future<Database> get db async {
    if (_db == null) _db = await initalDb();
    return _db!;
  }

  // initalDb() async {
  //   // تحديد مسار مخصص لحفظ قاعدة البيانات
  //   String customPath =
  //       'storage/emulated/0/myApp/database/sadb.db'; // حدد هنا المسار المخصص الذي تريده

  //   // التحقق من وجود المجلد وإنشاؤه إذا لم يكن موجودًا
  //   String directoryPath =
  //       'storage/emulated/0/myApp/database/sadb.db'; // حدد مسار المجلد المخصص
  //   if (!await Directory(directoryPath).exists()) {
  //     await Directory(directoryPath).create(recursive: true);
  //   }

  //   // فتح قاعدة البيانات في المسار المخصص
  //   Database mydb = await openDatabase(
  //     customPath,
  //     onCreate: _onCreate,
  //     version: 3,
  //     onUpgrade: _onUpgrade,
  //   );

  //   return mydb;
  // }
  // here we init the database and creat the tables
  initalDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'alhussain.db');
    Database mydb = await openDatabase(path,
        onCreate: _onCreate, version: 3, onUpgrade: _onUpgrade);
    return mydb;
  }

  /*2 _onUpgrade(Database db, int oldversion, int newversion)async{
    await db.execute('''
       CREATE TABLE "cities"(
        "cnum" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "cname" TEXT NOT NULL

        )
        ''');

    print("onUpgrae =========================");
  }*/

  /*4 _onUpgrade(Database db, int oldversion, int newversion)async{
    await db.execute('''
       CREATE TABLE "people"(
        "id_user" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "pname" TEXT NOT NULL ,
        "address" INTEGER NOT NULL ,
        "pnum" INTEGER NOT NULL,
        "numphon" number NOT NULL

        )
        ''');

    print("onUpgrae =========================");
  }*/
  _onUpgrade(Database db, int oldversion, int newversion) async {

    print("onUpgrae =========================");
  }

  _onCreate(Database db, int version) async {
        await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        name TEXT,
        price REAL,
        quantity INTEGER,
        category TEXT,
        isSync BOOLEAN,
        timestamp INTEGER
      )
    ''');

    // Create orders table
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

    // Create debts table
    await db.execute('''
      CREATE TABLE debts(
        id INTEGER PRIMARY KEY,
        customerId TEXT,
        customerName TEXT,
        customerPhone TEXT,
        totalDebt REAL,
        debtDiscount REAL,
        debtDate DATE,
        isSync BOOLEAN,
        timestamp INTEGER
      )
    ''');

/*3 _onCreate(Database db, int version) async{
    await db.execute('''
        CREATE TABLE "people"(
        "id_user" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "pname" TEXT NOT NULL ,
        "" TEXT NOT NULL ,
        "pnum" INTEGER NOT NULL,
        "numphon" number NOT NULL


        )
        ''');*/
    /* await db.execute('''
        CREATE TABLE "users"(
        "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "user_name" TEXT NOT NULL,
        "user_password" TEXT NOT NULL
        )
        ''');*/
    print("======onCreat database and tables ================");
  }

// SELECT
  readData(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  readData2(String tablename) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.query(tablename);
    return response;
  }
  readDataID(String tablename, String column, int value) async{
    Database? mydb = await db;
    List<Map> response = await mydb.query(tablename, where: '$column = ?', whereArgs: [value]);
    return response;
  }

// INSERT
  insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  insertData2(
      {required String tablename, required Map<String, dynamic> data}) async {
    Database mydb = await db;
    return await mydb.insert(tablename, data);
  }

// UPDATE
  updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

// DELETE
  deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
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

  Future<bool> checkIfItemExistsByName(String table, String nameColumn, String name) async {
  try {
    final db = await sqlState.db;
    final result = await db.query(
      table,
      where: '$nameColumn = ?',
      whereArgs: [name],
    );
    bool exists = result.isNotEmpty;
    print('===== التحقق من وجود $table.$nameColumn = $name: $exists =====');
    return exists;
  } catch (e) {
    print('===== خطأ في التحقق من وجود المنتج بالاسم: $e =====');
    return false;
  }
}



  Future<int> newId(String table, String column) async {
  Database? mydb = await db;
  List<Map> response = await mydb!.rawQuery("SELECT MAX($column) AS max_id FROM $table");

  var maxId = response[0]['max_id'];
  // var maxID=response.last['max_id'];
  if (maxId == null) {
    return 1; // يعني أول رقم جديد
  }
  return maxId + 1;
}
}

SqlDb sqlState = SqlDb();
