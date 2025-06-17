import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../models/debt.dart';
import '../models/order.dart' as order_model;
import '../models/order.dart';
import '../models/product.dart';

class Service {
  final CollectionReference _debtsCollection =
      FirebaseFirestore.instance.collection('debts');

  final CollectionReference _ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  Future<bool> connected() async {
    bool conn = await InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  /// الحصول على كل الديون
  Future<List<Debt>> getDebts() async {
    QuerySnapshot querySnapshot = await _debtsCollection.get();
    if (querySnapshot.docs.isNotEmpty) {
      print('===== Find debts =====');
      return querySnapshot.docs
          .map((doc) => Debt.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } else {
      print('===== Not found debts =====');
      return [];
    }
  }

  /// إضافة دين جديد
  Future<void> addDebt(Debt debt, String id) async {
     await _debtsCollection.doc(id).set(debt.toFirestore());
  }

  /// تحديث دين موجود
  Future<void> updateDebt(Debt debt) async {
    await _debtsCollection.doc(debt.id.toString()).update(debt.toFirestore());
  }

  /// حذف دين
  Future<void> deleteDebt(String id) async {
    if(!await connected()){

    }
    await _debtsCollection.doc(id.toString()).delete();
  }

  /// الحصول على إجمالي الديون المستحقة
  // Future<double> getTotalActiveDebts() async {
  //   final snapshot =
  //       await _debtsCollection.where('isSettled', isEqualTo: false).get();
  //
  //   if (snapshot.docs.isEmpty) return 0.0;
  //
  //   double total = 0.0;
  //   for (var doc in snapshot.docs) {
  //     final debt =
  //         Debt.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
  //     total += (debt.totalDebt - debt.debtDiscount!);
  //   }
  //
  //   return total;
  // }

  

  // ========== Product Methods ==========

  Future<List<Product>> getProducts() async {
    QuerySnapshot querySnapshot = await _productsCollection.get();
    if (querySnapshot.docs.isNotEmpty) {
      print('Find prodects');
      return querySnapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } else {
      print('Not found prodects');
      return [];
    }
  }

  /// إضافة منتج جديد
  addProduct(Product product, int id) async {
    try {
      final docRef = await _productsCollection
          .doc(id.toString())
          .set(product.toFirestore());
      return docRef;
    } catch (e) {
      print('Failed to add product: $e');
      return null;
    }
  }

  /// تحديث منتج موجود
  Future<void> updateProduct(Product product) async {
    await _productsCollection
        .doc(product.id.toString())
        .update(product.toFirestore());
  }

  /// حذف منتج
  Future<void> deleteProduct(int id) async {
    await _productsCollection.doc(id.toString()).delete();
  }

 
 
  // ========== Order Methods ==========

  /// الحصول على جميع الطلبات
  Future<List<OrderModel>> getOrders() async {
    try {
      print('===== جلب جميع الطلبات من Firestore =====');
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('===== لا توجد طلبات في Firestore =====');
        return [];
      }

      List<OrderModel> orders = [];
      for (var doc in querySnapshot.docs) {
        try {
          var data = doc.data() as Map<String, dynamic>;
          print('===== بيانات الطلب من Firestore (Doc ID: ${doc.id}): $data =====');
          var order = OrderModel.fromJson(data);
          orders.add(order);
          print('===== تم تحويل الطلب ID: ${order.id} بنجاح =====');
        } catch (e) {
          print('===== خطأ في تحويل الطلب من Firestore (Doc ID: ${doc.id}): $e =====');
        }
      }

      print('===== تم جلب ${orders.length} طلبات بنجاح =====');
      return orders;
    } catch (e) {
      print('===== خطأ في جلب الطلبات من Firestore: $e =====');
      return [];
    }
  }


  /// إضافة طلب جديد
  Future<void> addOrder(OrderModel order, int id) async {
     await _ordersCollection.doc(id.toString()).set(order.toJson());
  }

  /// تحديث طلب موجود
  Future<void> updateOrder(OrderModel order) async {
    await _ordersCollection.doc(order.id.toString()).update(order.toJson());
  }

  /// حذف طلب
  Future<void> deleteOrder(int id) async {
    await _ordersCollection.doc(id.toString()).delete();
  }


  Future<bool> checkDocumentExists(String collection, int id) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(id.toString())
          .get();
      print("Find document");
      return documentSnapshot.exists;

    } catch (e) {
      print('Not found document');
      return false;
    }
  }

  Future<bool> checkDocumentExists2(String collection, String id) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(id)
          .get();
      print("Find document");
      return documentSnapshot.exists;

    } catch (e) {
      print('Not found document');
      return false;
    }
  }

}

Service service = Service();
