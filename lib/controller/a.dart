// import 'package:customer_alhussain/controller/controllerFile.dart'; // عدّل الاسم حسب مسار الملف
// import 'package:customer_alhussain/model/orders.dart';
// import 'package:customer_alhussain/model/orderItem.dart';
// import 'package:customer_alhussain/model/products.dart';

// class OrderService {
//   static Future<void> placeOrder(Product product, int quantity) async {
//     if (product.quantity == null || product.quantity! < quantity) {
//       print("❌ الكمية غير كافية في المخزون");
//       return;
//     }

//     // إنشاء عنصر الطلب
//     OrderItem orderItem = OrderItem(
//       productId: product.id.toString(),
//       productName: product.name,
//       price: product.price,
//       quantity: quantity,
//     );

//     // إنشاء الطلب
//     OrderModel order = OrderModel(
//       customerId: 'default',
//       customerName: 'عميل افتراضي',
//       items: [orderItem],
//       totalAmount: orderItem.total,
//       createdAt: DateTime.now(),
//       isPaid: false,
//     );

//     await controller.insertOrder(order);

//     // تحديث المنتج في المخزون
//     product.quantity = (product.quantity ?? 0) - quantity;
//     await controller.updateProduct(product, 1);
//   }
// }
