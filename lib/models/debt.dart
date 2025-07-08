import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Debt {
  String id;
  String customerId;
  String customerName;
  int totalDebt;
  int? isSync;

  Debt({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.totalDebt,
    this.isSync,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'totalDebt': totalDebt,
      'isSync': isSync,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'totalDebt': totalDebt,
      'isSync': isSync,
    };
  }

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
        id: json['id'],
        customerId: json['customerId'],
        customerName: json['customerName'] ?? '',
        totalDebt: json['totalDebt'] ?? 0,
        isSync: json['isSync'] ?? 0);
  }

  factory Debt.fromFirestore(String id, Map<String, dynamic> data) {
    return Debt(
      id: id,
      customerId: data['customerId'],
      customerName: data['customerName'],
      totalDebt: data['totalDebt'],
      isSync: data['isSync'],
    );
  }
}
