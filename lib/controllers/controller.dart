import 'dart:io';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:db/services/service.dart';
import 'package:db/sqldb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/debt.dart';

class Controller extends GetxController {
  @override
  void onInit() {
    super.onInit();
    getLocalProducts();
    getLocalDebts();
    getLocalOrders();
    searchController
        .addListener(() => search.value = searchController.text.toLowerCase());
  }

  var uuid = Uuid();
  var products = <Product>[].obs;
  var orders = <OrderModel>[].obs;
  var debts = <Debt>[].obs;
  var customers = <Customer>[].obs;
  RxString search = ''.obs;
  TextEditingController searchController = TextEditingController();

  // Product operations
  Future<void> getLocalProducts() async {
    print('prodects');
    final db = await sqlState.db;
    final List<Map<String, dynamic>> maps = await db.query('products');
    List<Product> data =
        List.generate(maps.length, (i) => Product.fromJson(maps[i]));
    products.assignAll(data);
  }

  Future<void> addProduct(Product product, int type) async {
    ///check if there is internet connection
    bool isConnected =
        await InternetConnectionChecker.createInstance().hasConnection;
    if (isConnected) {
      // print('Connected to internet');
      product.id = await sqlState.newId('products', 'id');
      if (type == 1) {
        await service.addProduct(product, product.id!);
        // print('===== تم الاضافه في الفاير بيس المنتج =====');
      }
      await sqlState.insertData(
          'insert into products (id, name, price, quantity, category, timestamp, isSync) values (${product.id}, "${product.name}", ${product.price}, ${product.quantity}, "${product.category}", ${DateTime.now().millisecondsSinceEpoch}, 1)');
      // print('===== add product in local =====');
    } else {
      // print('No internet connection');
      // Add to sync queue
      await sqlState.insertData(
          'insert into products (id, name, price, quantity, category, timestamp, isSync) values (${product.id}, "${product.name}", ${product.price}, ${product.quantity}, "${product.category}", ${DateTime.now().millisecondsSinceEpoch}, 0)');
    }
    // await getLocalProducts();
  }

  updateProduct(Product product, int type) async {
    ///check if there is internet connection
    bool isConnected =
        await InternetConnectionChecker.createInstance().hasConnection;
    if (isConnected) {
      // print('Connected to internet');
      if (type == 1) {
        await service.updateProduct(product);
        // print('product updated in firebase');
      }
      await sqlState.updateData(
          'update products set name = "${product.name}", price = ${product.price}, quantity = ${product.quantity},   category = "${product.category}", timestamp = ${DateTime.now().millisecondsSinceEpoch}, isSync = 1 where id = ${product.id}');
      // print('===== update product in local =====');
    } else {
      print('No internet connection');
      // Add to sync queue
      await sqlState.updateData(
          'update products set name = "${product.name}", price = ${product.price}, quantity = ${product.quantity},   category = "${product.category}", timestamp = ${DateTime.now().millisecondsSinceEpoch}, isSync = 0 where id = ${product.id}');
    }
    await getLocalProducts();
  }

  deleteProduct(int id) async {
    await sqlState.deleteData('delete from products where id = ${id}');
    print('===== delete prodect =====');
    await getLocalProducts();
  }

  Future<void> addToLocalProducts() async {
    // print('===== بدايه دالة جلب المنتجات =====');
    var connection =
        await InternetConnectionChecker.createInstance().hasConnection;
    if (connection) {
      // print('===== connected to internet =====');
      List<Product> responseFirebase = await service.getProducts();
      // print("responseFirebase = $responseFirebase");

      for (Product product in responseFirebase) {
        // Product productModel = Product.fromJson(product.toJson());
        bool exists =
            await sqlState.checkIfitemExists("products", product.id!, "id");
        if (exists) {
          // data to firebase = 0
          await updateProduct(product, 0);
        } else {
          await addProduct(product, 0);
        }
      }
    } else {
      print("===== لا يوجد اتصال بالانترنت ===== ");
    }
    await getLocalProducts();
  }

  // Order operations
  Future<List<OrderModel>> getLocalOrders() async {
    // print('===== بدء جلب الطلبات من قاعدة البيانات المحلية =====');
    try {
      final db = await sqlState.db;
      final List<Map<String, dynamic>> orderMaps = await db.query('orders');
      List<OrderModel> orders = [];

      for (var orderMap in orderMaps) {
        try {
          // جلب عناصر الطلب من جدول order_items
          final List<Map<String, dynamic>> itemMaps = await db.query(
            'order_items',
            where: 'orderId = ?',
            whereArgs: [orderMap['id']],
          );

          // تحويل عناصر الطلب إلى قائمة OrderItem
          List<OrderItem> items = itemMaps.map((itemMap) {
            return OrderItem(
              productId: itemMap['productId'] as String? ?? '',
              productName: itemMap['productName'] as String? ?? '',
              price: (itemMap['price'] as num?)?.toDouble() ?? 0.0,
              quantity: itemMap['quantity'] as int? ?? 0,
            );
          }).toList();

          // تحويل السجل إلى OrderModel
          OrderModel order = OrderModel(
            id: orderMap['id'] as int?,
            customerId: orderMap['customerId'] as String? ?? '',
            customerName: orderMap['customerName'] as String? ?? '',
            totalAmount: (orderMap['totalAmount'] as num?)?.toDouble() ?? 0.0,
            createdAt: orderMap['createdAt'] != null
                ? DateTime.tryParse(orderMap['createdAt'] as String) ??
                    DateTime.now()
                : DateTime.now(),
            isPaid: (orderMap['isPaid'] as int?) == 1,
            debtDate: orderMap['debtDate'] != null
                ? DateTime.tryParse(orderMap['debtDate'] as String) ??
                    DateTime.now()
                : DateTime.now(),
            items: items,
          );

          orders.assignAll([order]);
          // print('===== تم تحويل الطلب ID: ${order.id} بنجاح =====');
        } catch (e) {
          // print('===== خطأ في تحويل الطلب ID: ${orderMap['id']}: $e =====');
        }
      }
      // print('===== تم جلب ${orders.length} طلبات من قاعدة البيانات المحلية =====');
      return orders;
    } catch (e) {
      // print('===== خطأ في جلب الطلبات من قاعدة البيانات المحلية: $e =====');
      return [];
    }
  }

  Future<void> addOrder(OrderModel order) async {
    try {
      final db = await sqlState.db;
      // إنشاء معرف جديد للطلب إذا لم يكن موجودًا
      if (order.id == null) {
        order.id = await sqlState.newId('orders', 'id');
        // print('===== تم إنشاء معرف جديد للطلب: ${order.id} =====');
      }

      // التحقق من صحة بيانات الطلب
      if (order.customerId == null) {
        print(
            '===== خطأ: الطلب غير صالح للإدراج (CustomerId: ${order.customerId}) =====');
        return;
      }

      // إضافة الطلب إلى جدول orders
      await db.insert('orders', {
        'id': order.id,
        'customerId': order.customerId,
        'customerName': order.customerName ?? '',
        'totalAmount': order.totalAmount ?? 0.0,
        'createdAt': order.createdAt?.toIso8601String() ?? '',
        'isPaid': order.isPaid ? 1 : 0,
        'debtDate': order.debtDate?.toIso8601String() ?? '',
        'isSync': 1,
      });

      // إضافة عناصر الطلب إلى جدول order_items
      if (order.items != null) {
        for (var item in order.items!) {
          if (item.productId == null || item.quantity == null) {
            // print('===== خطأ: عنصر الطلب غير صالح (ProductId: ${item.productId}, Quantity: ${item.quantity}) =====');
            continue;
          }
          await db.insert('order_items', {
            'orderId': order.id,
            'productId': item.productId,
            'productName': item.productName ?? '',
            'price': item.price ?? 0.0,
            'quantity': item.quantity,
          });
        }
      }

      // print('===== تم إضافة الطلب ID: ${order.id} بنجاح =====');
    } catch (e) {
      // print('===== خطأ في إضافة الطلب ID: ${order.id}: $e =====');
    }
  }

  Future<void> updateOrder(OrderModel order) async {
    try {
      final db = await sqlState.db;
      // التحقق من صحة بيانات الطلب
      if (order.id == null || order.customerId == null) {
        // print('===== خطأ: الطلب غير صالح للتحديث (ID: ${order.id}, CustomerId: ${order.customerId}) =====');
        return;
      }

      // تحديث بيانات الطلب
      await db.update(
        'orders',
        {
          'customerId': order.customerId,
          'customerName': order.customerName ?? '',
          'totalAmount': order.totalAmount ?? 0.0,
          'createdAt': order.createdAt?.toIso8601String() ?? '',
          'isPaid': order.isPaid ? 1 : 0,
          'debtDate': order.debtDate?.toIso8601String() ?? '',
          'isSync': 1,
        },
        where: 'id = ?',
        whereArgs: [order.id],
      );

      // حذف عناصر الطلب القديمة
      await db
          .delete('order_items', where: 'orderId = ?', whereArgs: [order.id]);

      // إضافة عناصر الطلب الجديدة
      if (order.items != null) {
        for (var item in order.items!) {
          if (item.productId == null || item.quantity == null) {
            // print('===== خطأ: عنصر الطلب غير صالح (ProductId: ${item.productId}, Quantity: ${item.quantity}) =====');
            continue;
          }
          await db.insert('order_items', {
            'orderId': order.id,
            'productId': item.productId,
            'productName': item.productName ?? '',
            'price': item.price ?? 0.0,
            'quantity': item.quantity,
          });
        }
      }
      // print('===== تم تحديث الطلب ID: ${order.id} بنجاح =====');
    } catch (e) {
      // print('===== خطأ في تحديث الطلب ID: ${order.id}: $e =====');
    }
  }

  deleteOrder(int id) async {
    await sqlState.deleteData('delete from orders where id = ${id}');
    print('===== delete order =====');
  }

  Future<void> addToLocalOrders() async {
    // print('===== بدء جلب جميع الطلبات من Firestore =====');
    try {
      bool isConnected =
          await InternetConnectionChecker.createInstance().hasConnection;
      if (!isConnected) {
        print('===== لا يوجد اتصال بالإنترنت =====');
        return;
      }

      List<OrderModel> orders = await service.getOrders();
      // print('===== تم جلب ${orders.length} طلبات من Firestore =====');

      if (orders.isEmpty) {
        // print('===== لا توجد طلبات في Firestore =====');
        return;
      }

      for (OrderModel order in orders) {
        // التحقق من صحة بيانات الطلب
        if (order.id == null ||
            order.customerId == null ||
            order.items == null ||
            order.items!.isEmpty) {
          // print('===== خطأ: الطلب غير صالح (ID: ${order.id}, CustomerId: ${order.customerId}, Items: ${order.items?.length}) =====');
          continue;
        }

        // print('===== معالجة الطلب ID: ${order.id} =====');
        bool exists =
            await sqlState.checkIfitemExists("orders", order.id!, "id");
        // print('===== الطلب موجود في قاعدة البيانات المحلية: $exists =====');

        if (exists) {
          await updateOrder(order);
          // print('===== تم تحديث الطلب ID: ${order.id} =====');
        } else {
          await addOrder(order);
          // print('===== تم إضافة الطلب ID: ${order.id} =====');
        }
      }
      // print('===== اكتملت مزامنة الطلبات =====');
    } catch (e) {
      print('===== خطأ في مزامنة الطلبات: $e =====');
    }
  }

  // Debt operations
  Future<void> addDebt(Debt debt, int type) async {
    ///check if there is internet connection
    final db = await sqlState.db;
    bool isConnected =
        await InternetConnectionChecker.createInstance().hasConnection;
    if (isConnected) {
      print('Connected to internet');
      String id = uuid.v4();
      debt.id = id;
      debt.customerId = id;
      if (type == 1) {
        debt.isSync = 1;
        await service.addDebt(debt, debt.id!);
      }
      await db.insert('debts', debt.toMap());
    } else {
      print('No internet connection');
      // Add to sync queue
      debt.isSync = 0;
      await db.insert('debts', debt.toMap());
    }
  }

  updateDebt(Debt debt, int type) async {
    final db = await sqlState.db;

    ///check if there is internet connection
    // print('Connected to internet');
    if (type == 1) {
      bool isConnected =
          await InternetConnectionChecker.createInstance().hasConnection;
      if (isConnected) {
        await service.updateDebt(debt);
        await db.update('debts', debt.toMap()..remove(debt.id),
            where: 'id = ?', whereArgs: [debt.id]);
      } else {
        print('No internet connection');
        debt.isSync = 0;
        await db.update('debts', debt.toMap()..remove(debt.id),
            where: 'id = ?', whereArgs: [debt.id]);
      }
    } else {
      // Add to sync queue
      await db.update('debts', debt.toMap()..remove(debt.id),
          where: 'id = ?', whereArgs: [debt.id]);
    }
  }

  deleteDebt(String id) async {
    final db = await sqlState.db;
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
    await service.deleteDebt(id);
  }

  Future<void> getLocalDebts() async {
    print('=========== local');
    final db = await sqlState.db;
    final List<Map<String, dynamic>> maps = await db.query('debts');
    List<Debt> debtsList =
        List.generate(maps.length, (i) => Debt.fromJson(maps[i]));
    debts.assignAll(debtsList);
  }

  addToLocalDebts() async {
    var connection =
        await InternetConnectionChecker.createInstance().hasConnection;

    if (connection) {
      List<Debt> responseFirebase = await service.getDebts();
      print("responseFirebase = $responseFirebase");

      for (var debt in responseFirebase) {
        // Debt debtModel = Debt.fromJson(debt.toMap());
        bool exists =
            await sqlState.checkIfitemExists2("debts", debt.id!, "id");
        print('========================');
        if (exists) {
          // data to firebase = 0
          await updateDebt(debt, 0);
        } else {
          await addDebt(debt, 0);
        }
      }
    } else {
      print("لا يوجد اتصال بالانترنت");
    }
  }

  Future<void> updateOrderStatus(int orderId, bool isPaid) async {
    print('===== بدء تحديث حالة الطلب ID: $orderId إلى isPaid: $isPaid =====');
    try {
      final db = await sqlState.db;
      int rowsAffected = await db.update(
        'orders',
        {'isPaid': isPaid ? 1 : 0},
        where: 'id = ?',
        whereArgs: [orderId],
      );
      print(
          '===== عدد الصفوف التي تم تحديثها للطلب ID: $orderId: $rowsAffected =====');
      if (rowsAffected > 0) {
        print('===== تم تحديث حالة الطلب ID: $orderId بنجاح =====');
      } else {
        print(
            '===== فشل تحديث حالة الطلب ID: $orderId، لم يتم العثور على الطلب =====');
      }
    } catch (e) {
      print('===== خطأ في تحديث حالة الطلب ID: $orderId: $e =====');
      throw Exception('فشل في تحديث حالة الطلب: $e');
    }
  }

  static Future<void> importProductsFromExcel(
      BuildContext context, Controller controller) async {
    try {
      // طلب أذونات التخزين بشكل شامل
      print('===== طلب أذونات التخزين =====');
      bool hasPermission = false;
      if (Platform.isAndroid) {
        var status = await Permission.manageExternalStorage.status;
        if (status.isDenied) {
          await Permission.manageExternalStorage.request();
        }

        if (await Permission.manageExternalStorage.isGranted ||
            await Permission.storage.isGranted) {
          hasPermission = true;
          print('===== تم منح إذن الوصول للتخزين =====');
        } else {
          // محاولة طلب أذونات متعددة
          Map<Permission, PermissionStatus> statuses = await [
            Permission.storage,
            Permission.manageExternalStorage,
          ].request();

          hasPermission = statuses.values.any((status) => status.isGranted);
        }
      } else if (Platform.isIOS) {
        hasPermission = true;
      }

      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى منح إذن الوصول إلى التخزين')),
        );
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickMedia();
      if (pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم اختيار ملف')),
        );
        print('===== لم يتم اختيار الملف =====');
        return;
      }
      // print('result = $result');
      final path = pickedFile.path;
      if (!path.toLowerCase().endsWith('.xlsx') &&
          !path.toLowerCase().endsWith('.xls')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يجب أن يكون الملف Excel')),
        );
        print('===== يجب أن يكون الملف Excel =====');
        return;
      }

      // قراءة ملف Excel وتحويل البيانات إلى List<Product>
      final file = File(path);
      var bytes = file.readAsBytesSync();

      // استخدام spreadsheet_decoder بدلاً من excel
      var decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);

      List<Product> products = [];

      // الحصول على الورقة الأولى من ملف Excel
      String sheetName = decoder.tables.keys.first;
      var table = decoder.tables[sheetName]!;

      // قراءة الصفوف بدءًا من الصف الثاني (تخطي رأس الجدول)
      for (var rowIndex = 1; rowIndex < table.rows.length; rowIndex++) {
        var row = table.rows[rowIndex];

        // التحقق من وجود بيانات في الصف
        if (row.length < 3) continue;

        String name = (row[0] ?? '').toString();
        double price = 0.0;
        int quantity = 0;
        String category = '';

        try {
          price = double.tryParse((row[1] ?? '0').toString()) ?? 0.0;
          quantity = int.tryParse((row[2] ?? '0').toString()) ?? 0;
          category = row.length > 3 ? (row[3] ?? '').toString() : '';
        } catch (e) {
          print('===== خطأ في قراءة الصف $rowIndex: $e =====');
          continue;
        }

        if (name.isNotEmpty && price > 0 && quantity >= 0) {
          products.add(Product(
            name: name,
            price: price,
            quantity: quantity,
            category: category.isNotEmpty ? category : null,
          ));
        }
      }

      if (products.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم العثور على منتجات صالحة في الملف')),
        );
        return;
      }

      // تخزين البيانات في قاعدة البيانات
      for (var product in products) {
        bool exists = await sqlState.checkIfItemExistsByName(
            'products', 'name', product.name!);
        if (exists) {
          print('===== المنتج موجود في قاعدة البيانات =====');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('المنتج موجود في قاعدة البيانات')));
          continue;
        }
        await controller.addProduct(
            product, 1); // استبدال insertData بـ addProduct
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم استيراد المنتجات بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في استيراد المنتجات: $e')),
      );
      print('===== فشل في استيراد المنتجات: $e =====');
    }
  }

  Future<void> getCustomerFromLocal() async {
    final db = await sqlState.db;
    List<Map<String, dynamic>> maps = await db.query('customer');
    List<Customer> customerList =
        List.generate(maps.length, (i) => Customer.fromJson(maps[i]));
    customers.assignAll(customerList);
  }
}

Controller controller = Controller();
