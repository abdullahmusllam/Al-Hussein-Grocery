import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:customer_alhussain/model/debt.dart';
import 'package:customer_alhussain/model/orders.dart';
import 'package:customer_alhussain/model/products.dart';
import 'package:customer_alhussain/service/servise.dart';
import 'package:customer_alhussain/sqldb.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/orderItem.dart';

class Controller {
  // جلب المنتجات من قاعدة البيانات المحلية
  Future<List<Product>> getLocalProducts() async {
    final db = await sqlState.db;
    final maps = await db.query('products');
    return maps.map((map) => Product.fromJson(map)).toList();
  }

  // إضافة منتج جديد إلى قاعدة البيانات المحلية
  Future<void> addProduct(Product product) async {
    final db = await sqlState.db;
    product.id = await sqlState.newId('products', 'id');
    await db.insert('products', {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'quantity': product.quantity,
      'category': product.category,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isSync': 1,
    });
    print('===== تم إضافة المنتج محليًا =====');
  }

  // تحديث منتج في قاعدة البيانات المحلية
  Future<void> updateProduct(Product product) async {
    final db = await sqlState.db;
    await db.update(
      'products',
      {
        'name': product.name,
        'price': product.price,
        'quantity': product.quantity,
        'category': product.category,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'isSync': 1,
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
    print('===== تم تحديث المنتج محليًا =====');
  }

  // جلب المنتجات من Firestore وتحديث قاعدة البيانات المحلية
  Future<void> addToLocalProducts() async {
    print('===== بدء جلب المنتجات من Firestore =====');
    bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;
    if (isConnected) {
      List<Product> products = await service.getProducts();
      print('===== جلب المنتجات من Firestore بنجاح =====');
      for (var product in products) {
        bool exists = await sqlState.checkIfitemExists("products", product.id!, "id");
        print('===== المنتج موجود: $exists =====');
        if (exists) {
          await updateProduct(product);
        } else {
          await addProduct(product);
        }
      }
    } else {
      print('===== لا يوجد اتصال بالإنترنت =====');
    }
  }

  // جلب الطلبات من قاعدة البيانات المحلية
  Future<List<OrderModel>> getLocalOrders() async {
    final db = await sqlState.db;
    final orderMaps = await db.query('orders');
    List<OrderModel> orders = [];

    for (var orderMap in orderMaps) {
      final items = await db.query(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [orderMap['id']],
      );
      orders.add(OrderModel(
        id: orderMap['id'] as int?,
        customerId: orderMap['customerId'] as String?,
        customerName: orderMap['customerName'] as String?,
        totalAmount: (orderMap['totalAmount'] as num?)?.toDouble(),
        createdAt: orderMap['createdAt'] != null
            ? DateTime.parse(orderMap['createdAt'] as String)
            : null,
        isPaid: (orderMap['isPaid'] as int?) == 1,
        debtDate: orderMap['debtDate'] != null
            ? DateTime.parse(orderMap['debtDate'] as String)
            : null,
        items: items
            .map((item) => OrderItem(
                  productId: item['productId'] as String?,
                  productName: item['productName'] as String?,
                  price: (item['price'] as num?)?.toDouble(),
                  quantity: item['quantity'] as int?,
                ))
            .toList(),
      ));
    }
    return orders;
  }

  // جلب طلبات عميل معين
  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    final db = await sqlState.db;
    final orderMaps = await db.query(
      'orders',
      where: 'customerId = ?',
      whereArgs: [customerId],
    );
    List<OrderModel> orders = [];

    for (var orderMap in orderMaps) {
      final items = await db.query(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [orderMap['id']],
      );
      orders.add(OrderModel(
        id: orderMap['id'] as int?,
        customerId: orderMap['customerId'] as String?,
        customerName: orderMap['customerName'] as String?,
        totalAmount: (orderMap['totalAmount'] as num?)?.toDouble(),
        createdAt: orderMap['createdAt'] != null
            ? DateTime.parse(orderMap['createdAt'] as String)
            : null,
        isPaid: (orderMap['isPaid'] as int?) == 1,
        debtDate: orderMap['debtDate'] != null
            ? DateTime.parse(orderMap['debtDate'] as String)
            : null,
        items: items
            .map((item) => OrderItem(
                  productId: item['productId'] as String?,
                  productName: item['productName'] as String?,
                  price: (item['price'] as num?)?.toDouble(),
                  quantity: item['quantity'] as int?,
                ))
            .toList(),
      ));
    }
    return orders;
  }

  // إضافة طلب جديد
  Future<void> insertOrder(OrderModel order) async {
    try {
      final db = await sqlState.db;
      bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;

      // إنشاء معرف جديد للطلب إذا لم يكن موجودًا
      if (order.id == null) {
        order.id = await sqlState.newId('orders', 'id');
        print('===== تم إنشاء معرف جديد للطلب: ${order.id} =====');
      }

      // التحقق من صحة بيانات الطلب
      if (order.customerId == null) {
        print('===== خطأ: الطلب غير صالح للإدراج (CustomerId: ${order.customerId}) =====');
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
        'isSync': isConnected ? 1 : 0,
      });

      // إضافة عناصر الطلب إلى جدول order_items
      if (order.items != null) {
        for (var item in order.items!) {
          if (item.productId == null || item.quantity == null) {
            print('===== خطأ: عنصر الطلب غير صالح (ProductId: ${item.productId}, Quantity: ${item.quantity}) =====');
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

      // مزامنة الطلب مع Firestore إذا كان هناك اتصال
      if (isConnected) {
        try {
          await service.addOrder(order, order.id!);
          print('===== تم مزامنة الطلب ID: ${order.id} مع Firestore =====');
        } catch (e) {
          print('===== خطأ في مزامنة الطلب مع Firestore: $e =====');
        }
      }

      print('===== تم إضافة الطلب ID: ${order.id} بنجاح =====');
    } catch (e) {
      print('===== خطأ في إضافة الطلب ID: ${order.id}: $e =====');
    }
  }
  // تحديث طلب موجود
  Future<void> updateOrder(OrderModel order) async {
    try {
      final db = await sqlState.db;
      bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;

      // التحقق من صحة بيانات الطلب
      if (order.id == null || order.customerId == null) {
        print('===== خطأ: الطلب غير صالح للتحديث (ID: ${order.id}, CustomerId: ${order.customerId}) =====');
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
          'isSync': isConnected ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [order.id],
      );

      // حذف عناصر الطلب القديمة
      await db.delete('order_items', where: 'orderId = ?', whereArgs: [order.id]);

      // إضافة عناصر الطلب الجديدة
      if (order.items != null) {
        for (var item in order.items!) {
          if (item.productId == null || item.quantity == null) {
            print('===== خطأ: عنصر الطلب غير صالح (ProductId: ${item.productId}, Quantity: ${item.quantity}) =====');
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

      // مزامنة مع Firestore إذا كان هناك اتصال
      if (isConnected) {
        try {
          await service.updateOrder(order);
          print('===== تم مزامنة الطلب ID: ${order.id} مع Firestore =====');
        } catch (e) {
          print('===== خطأ في مزامنة الطلب مع Firestore: $e =====');
        }
      }

      print('===== تم تحديث الطلب ID: ${order.id} بنجاح =====');
    } catch (e) {
      print('===== خطأ في تحديث الطلب ID: ${order.id}: $e =====');
    }
  }

  // حذف طلب
  Future<void> deleteOrder(int id) async {
    final db = await sqlState.db;
    await db.delete('orders', where: 'id = ?', whereArgs: [id]);
    await db.delete('order_items', where: 'orderId = ?', whereArgs: [id]);

    bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;
    if (isConnected) {
      await service.deleteOrder(id);
    }
    print('===== تم حذف الطلب =====');
  }

  // جلب الطلبات من Firestore وتحديث قاعدة البيانات المحلية
  Future<void> addToLocalOrders(String customerId) async {
    print('===== بدء جلب الطلبات من Firestore للعميل: $customerId =====');
    try {
      bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;
      if (!isConnected) {
        print('===== لا يوجد اتصال بالإنترنت =====');
        return;
      }

      List<OrderModel> orders = await service.getOrders(customerId);
      print('===== تم جلب ${orders.length} طلبات من Firestore =====');

      if (orders.isEmpty) {
        print('===== لا توجد طلبات للعميل $customerId في Firestore =====');
        return;
      }

      for (OrderModel order in orders) {
        // التحقق من صحة بيانات الطلب
        if (order.id == null || order.customerId == null || order.items == null || order.items!.isEmpty) {
          print('===== خطأ: الطلب غير صالح (ID: ${order.id}, CustomerId: ${order.customerId}, Items: ${order.items?.length}) =====');
          continue;
        }

        print('===== معالجة الطلب ID: ${order.id} =====');
        bool exists = await sqlState.checkIfitemExists("orders", order.id!, "id");
        print('===== الطلب موجود في قاعدة البيانات المحلية: $exists =====');

        if (exists) {
          await updateOrder(order);
          print('===== تم تحديث الطلب ID: ${order.id} =====');
        } else {
          await insertOrder(order);
          print('===== تم إضافة الطلب ID: ${order.id} =====');
        }
      }
      print('===== اكتملت مزامنة الطلبات =====');
    } catch (e) {
      print('===== خطأ في مزامنة الطلبات: $e =====');
    }
  }
  // مزامنة الدين مع SharedPreferences
  Future<void> syncDebtToSharedPreferences(String customerId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('debts')
          .doc(customerId)
          .get();
      final debtAmount = doc.exists
          ? (doc.data()?['remainingAmount'] as num?)?.toDouble() ?? 0.0
          : 0.0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('debt_$customerId', debtAmount.toString());
    } catch (e) {
      print('===== خطأ في مزامنة الدين: $e =====');
    }
  }

  // جلب الدين من SharedPreferences
  Future<double> getDebtFromSharedPreferences(String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    final debtString = prefs.getString('debt_$customerId');
    return double.tryParse(debtString ?? '0.0') ?? 0.0;
  }

  // تحديث كمية المنتج
  Future<void> updateProductQuantity(int productId, int newQuantity) async {
    final db = await sqlState.db;
    bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;

    await db.update(
      'products',
      {'quantity': newQuantity, 'isSync': isConnected ? 1 : 0},
      where: 'id = ?',
      whereArgs: [productId],
    );

    if (isConnected) {
      await service.updateProduct(productId, newQuantity);
    }

    print('===== تم تحديث كمية المنتج =====');
  }

  // إنشاء طلب جديد مع تحديث الكميات
  Future<void> placeOrder(OrderModel order) async {
    final db = await sqlState.db;

    // التحقق من كميات المنتجات
    for (var item in order.items!) {
      final productMaps = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [item.productId],
      );
      if (productMaps.isEmpty) {
        throw Exception('المنتج ${item.productId} غير موجود');
      }
      final currentQuantity = (productMaps.first['quantity'] as num?)?.toInt() ?? 0;
      final newQuantity = currentQuantity - item.quantity!;
      if (newQuantity < 0) {
        throw Exception('الكمية غير كافية للمنتج ${item.productName}');
      }
      // تحديث الكمية
      await updateProductQuantity(int.parse(item.productId!), newQuantity);
    }

    // إضافة الطلب
    await insertOrder(order);

    print('===== تم إنشاء الطلب بنجاح =====');
  }
}

Controller controller = Controller();