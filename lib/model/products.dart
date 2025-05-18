import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// نموذج بيانات المنتج
class Product {
  int? id;
  String? name;
  double? price;
  int? quantity;
  String? category;

  Product({
    this.id,
    this.name,
    this.price,
    this.quantity,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'category': category,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
        id: map['id'],
        name: map['name'],
        price: map['price'],
        quantity: map['quantity'],
        category: map['category']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'category': category,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      category: json['category'],
    );
  }

  factory Product.fromFirestore(int id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'],
      price: data['price'],
      quantity: data['quantity'],
      category: data['category'],
    );
  }
}
