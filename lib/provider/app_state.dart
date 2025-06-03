// import 'package:customer_alhussain/controller/controllerFile.dart';
// import 'package:customer_alhussain/model/debt.dart';
// import 'package:customer_alhussain/model/orders.dart';
// import 'package:customer_alhussain/model/products.dart';
// import 'package:flutter/material.dart';
//
// class AppState extends ChangeNotifier {
//   final Controller controller;
//   List<Product> products = [];
//   List<OrderModel> orders = [];
//   List<Debt> debts = [];
//   bool isLoading = false;
//
//   AppState({required this.controller});
//
//   // جلب المنتجات
//   Future<void> fetchProducts() async {
//     if (isLoading) return; // تجنب الجلب المتكرر
//     isLoading = true;
//     notifyListeners();
//     try {
//       products = await controller.getLocalProducts();
//       if (products.isEmpty) {
//         await controller.addToLocalProducts();
//         products = await controller.getLocalProducts();
//       }
//     } catch (e) {
//       print('Error fetching products: $e');
//     }
//     isLoading = false;
//     notifyListeners();
//   }
//
//   // جلب الطلبات لعميل معين
//   Future<void> fetchOrders(String customerId) async {
//     if (isLoading) return; // تجنب الجلب المتكرر
//     isLoading = true;
//     notifyListeners();
//     try {
//       orders = await controller.getOrdersByCustomer(customerId);
//       if (orders.isEmpty) {
//         await controller.addToLocalOrders();
//         orders = await controller.getOrdersByCustomer(customerId);
//       }
//     } catch (e) {
//       print('Error fetching orders: $e');
//     }
//     isLoading = false;
//     notifyListeners();
//   }
//
//   // جلب الديون لعميل معين
//   Future<void> fetchDebts(String customerId) async {
//     if (isLoading) return; // تجنب الجلب المتكرر
//     isLoading = true;
//     notifyListeners();
//     try {
//       debts = await controller.getLocalDebts();
//       debts = debts.where((debt) => debt.customerId == customerId).toList();
//       if (debts.isEmpty) {
//         await controller.addToLocalDebts();
//         debts = await controller.getLocalDebts();
//         debts = debts.where((debt) => debt.customerId == customerId).toList();
//       }
//     } catch (e) {
//       print('Error fetching debts: $e');
//     }
//     isLoading = false;
//     notifyListeners();
//   }
//
//   // إضافة طلب
//   Future<void> addOrder(OrderModel order) async {
//     isLoading = true;
//     notifyListeners();
//     try {
//       await controller.insertOrder(order);
//       orders = await controller.getOrdersByCustomer(order.customerId!);
//     } catch (e) {
//       print('Error adding order: $e');
//     }
//     isLoading = false;
//     notifyListeners();
//   }
//
//   // تحديث كمية المنتج
//   Future<void> updateProductQuantity(String productId, int newQuantity) async {
//     try {
//       final product = products.firstWhere((p) => p.id.toString() == productId);
//       product.quantity = newQuantity;
//       await controller.updateProduct(product, 1);
//       notifyListeners();
//     } catch (e) {
//       print('Error updating product quantity: $e');
//     }
//   }
// }