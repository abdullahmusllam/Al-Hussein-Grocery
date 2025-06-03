// import 'orderItem.dart';
import 'order_item.dart';

class OrderModel {
  int? id;
  String? customerId;
  String? customerName;
  List<OrderItem>? items;
  double? totalAmount;
  DateTime? createdAt;
  bool isPaid;
  DateTime? debtDate;

  OrderModel({
    this.id,
    this.customerId,
    this.customerName,
    this.items,
    this.totalAmount,
    this.createdAt,
    this.isPaid = false,
    this.debtDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'customerName': customerName,
    'items': items?.map((item) => item.toJson()).toList(),
    'totalAmount': totalAmount,
    'createdAt': createdAt?.toIso8601String(),
    'isPaid': isPaid,
    'debtDate': debtDate?.toIso8601String(),
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] is int ? json['id'] as int? : int.tryParse(json['id']?.toString() ?? ''),
    customerId: json['customerId'] as String? ?? '',
    customerName: json['customerName'] as String? ?? '',
    items: json['items'] != null && json['items'] is List
        ? (json['items'] as List)
        .map((item) {
      try {
        return OrderItem.fromJson(item as Map<String, dynamic>);
      } catch (e) {
        print('===== خطأ في تحويل عنصر الطلب: $e =====');
        return null;
      }
    })
        .where((item) => item != null)
        .cast<OrderItem>()
        .toList()
        : [],
    totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
    isPaid: json['isPaid'] is bool
        ? json['isPaid'] as bool
        : (json['isPaid'] as int?) == 1,
    debtDate: json['debtDate'] != null
        ? DateTime.tryParse(json['debtDate'] as String) ?? DateTime.now()
        : DateTime.now(),
  );
}