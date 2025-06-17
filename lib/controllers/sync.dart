import 'package:db/models/debt.dart';
import 'package:db/models/order.dart';
import 'package:db/models/product.dart';
import 'package:db/services/service.dart';
import 'package:db/sqldb.dart';
import 'package:sqflite/sqflite.dart';

class Sync {
  // Future<Database> data() async {
  //   final db = await sqlState.db;
  //   return db;
  // }

  Future<void> syncProduct() async {
    print('===== sync Product =====');
    List<Map<String, dynamic>> map =
        await sqlState.readDataID("products", 'isSync', 0);
    if (map.isNotEmpty) {
      print('===== map.isNotEmpty =====');
      List<Product> products = map.map((map) => Product.fromMap(map)).toList();
      for (Product product in products) {
        bool exists =
            await service.checkDocumentExists('products', product.id!);
        if (exists) {
          await service.updateProduct(product);

          await sqlState.updateData(
              'update products set isSync = 1 where id = ${product.id}');
          print('===== sync product (update) =====');

        } else {
          await service.addProduct(product, product.id!);
          await sqlState.updateData(
              'update products set isSync = 1 where id = ${product.id}');

          print('===== sync product (update) =====');
        }
      }
    } else {
      print('===== map.isEmpty =====');
    }
  }

  // Future<void> syncOrders() async {
  //   List<Map<String, dynamic>> map =
  //       await sqlState.readDataID("orders", 'isSync', 0);
  //   if (map.isNotEmpty) {
  //     List<OrderModel> orders = map.map((map) => OrderModel.fromJson(map)).toList();
  //     for (OrderModel order in orders) {
  //       bool exists = await service.checkDocumentExists('orders', order.id!);
  //       if (exists) {
  //         await service.updateOrder(order);
  //         await sqlState.updateData(
  //             'update orders set isSync = 1 where id = ${order.id}');
  //
  //         print('===== sync order (update)');
  //       } else {
  //         await service.addOrder(order, order.id!);
  //         await sqlState.updateData(
  //             'update orders set isSync = 1 where id = ${order.id}');
  //
  //         print('sync order (add)');
  //       }
  //     }
  //   }
  // }

  Future<void> syncDebts() async {
    final db = await sqlState.db;
    List<Map<String, dynamic>> map =
        await sqlState.readDataID("debts", 'isSync', 0);
    if (map.isNotEmpty) {
      List<Debt> debts = map.map((map) => Debt.fromJson(map)).toList();
      for (Debt debt in debts) {
        bool exists = await service.checkDocumentExists2('debts', debt.id!);
        print('==============');
        if (exists) {
          debt.isSync = 1;
          await service.updateDebt(debt);
          await db.update('debts', debt.toMap()..remove(debt.id), where: 'id = ?', whereArgs: [debt.id]);

          print('===== sync debt (update) =====');
        } else {
          debt.isSync = 1;
          await service.addDebt(debt, debt.id!);
          await db.update('debts', debt.toMap()..remove(debt.id), where: 'id = ?', whereArgs: [debt.id]);

          print('===== sync order (add) =====');
        }
      }
    }
  }
}

Sync sync = Sync();
