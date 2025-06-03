import 'package:cloud_firestore/cloud_firestore.dart';

class Debt {
   int id;
   String customerId;
   String customerName;
   String customerPhone;
   double totalDebt;
   double debtDiscount;
   DateTime debtDate;
   List<DebtTransaction> transactions;

  Debt({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.totalDebt,
    required this.debtDiscount,
    required this.debtDate,
    List<DebtTransaction>? transactions,
  }) : this.transactions = transactions ?? [];

  double get remainingAmount => totalDebt - debtDiscount;

  void increaseDebt(double amount, String description) {
    transactions.add(DebtTransaction(
      amount: amount,
      type: DebtTransactionType.increase,
      description: description,
      date: DateTime.now(),
    ));
  }

  void decreaseDebt(double amount, String description) {
    transactions.add(DebtTransaction(
      amount: amount,
      type: DebtTransactionType.decrease,
      description: description,
      date: DateTime.now(),
    ));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'totalDebt': totalDebt,
      'debtDiscount': debtDiscount,
      'debtDate': debtDate.millisecondsSinceEpoch,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'totalDebt': totalDebt,
      'debtDiscount': debtDiscount,
      'debtDate': debtDate,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      totalDebt: json['totalDebt'],
      debtDiscount: json['debtDiscount'],
      debtDate: DateTime.fromMillisecondsSinceEpoch(json['debtDate']),
      transactions: (json['transactions'] as List?)
          ?.map((t) => DebtTransaction.fromJson(t))
          .toList(),
    );
  }

  factory Debt.fromFirestore(String id, Map<String, dynamic> data) {
    return Debt(
      id: int.parse(id),
      customerId: data['customerId'],
      customerName: data['customerName'],
      customerPhone: data['customerPhone'],
      totalDebt: data['totalDebt'],
      debtDiscount: data['debtDiscount'],
      debtDate: (data['debtDate'] as Timestamp).toDate(),
      transactions: (data['transactions'] as List?)
          ?.map((t) => DebtTransaction.fromJson(t))
          .toList(),
    );
  }
}

enum DebtTransactionType {
  increase,
  decrease,
}

class DebtTransaction {
  final double amount;
  final DebtTransactionType type;
  final String description;
  final DateTime date;

  DebtTransaction({
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'type': type.toString(),
      'description': description,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory DebtTransaction.fromJson(Map<String, dynamic> json) {
    return DebtTransaction(
      amount: json['amount'],
      type: DebtTransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => DebtTransactionType.increase,
      ),
      description: json['description'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
    );
  }
}