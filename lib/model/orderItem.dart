class OrderItem {
  String? productId;
  String? productName;
  double? price;
  int? quantity;

  OrderItem({
    this.productId,
    this.productName,
    this.price,
    this.quantity,
  });

  double get total => (price ?? 0.0) * (quantity ?? 0);

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'price': price,
    'quantity': quantity,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['productId'] as String?,
    productName: json['productName'] as String?,
    price: (json['price'] as num?)?.toDouble(),
    quantity: json['quantity'] as int?,
  );
}