import 'package:customer_alhussain/controller/controllerFile.dart';
import 'package:customer_alhussain/model/orderItem.dart';
import 'package:customer_alhussain/model/orders.dart';
import 'package:customer_alhussain/model/products.dart';
import 'package:customer_alhussain/views/CustomerOrdersScreen.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class CustomerBookingScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const CustomerBookingScreen({
    Key? key,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  @override
  _CustomerBookingScreenState createState() => _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends State<CustomerBookingScreen> {
  final Controller controller = Controller();
  List<Product> products = [];
  List<OrderItem> cart = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      products = await controller.getLocalProducts();
    } catch (e) {
      print('Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في جلب المنتجات: $e')),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void addToCart(Product product, int quantity) {
    setState(() {
      final existingItemIndex = cart.indexWhere((item) => item.productId == product.id.toString());
      if (existingItemIndex != -1) {
        final newQuantity = cart[existingItemIndex].quantity! + quantity;
        if (newQuantity <= 0) {
          cart.removeAt(existingItemIndex);
        } else if (newQuantity <= (product.quantity ?? 0)) {
          cart[existingItemIndex] = OrderItem(
            productId: product.id.toString(),
            productName: product.name,
            price: product.price ?? 0.0,
            quantity: newQuantity,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الكمية غير متوفرة')),
          );
        }
      } else if (quantity > 0 && quantity <= (product.quantity ?? 0)) {
        cart.add(OrderItem(
          productId: product.id.toString(),
          productName: product.name,
          price: product.price ?? 0.0,
          quantity: quantity,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الكمية غير متوفرة')),
        );
      }
    });
  }

  Future<void> placeOrder() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السلة فارغة')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final order = OrderModel(
        customerId: widget.customerId,
        customerName: widget.customerName,
        items: cart,
        totalAmount: cart.fold(0.0, (sum, item) => sum! + item.quantity! * item.price!),
        createdAt: DateTime.now(),
        isPaid: false,
        debtDate: DateTime.now().add(const Duration(days: 30)),
      );

      await controller.placeOrder(order);
      setState(() {
        cart.clear();
        fetchProducts();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الطلب بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في إنشاء الطلب: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // الأبيض
      appBar: AppBar(
        title: const Text("حجز المنتجات"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Color(0xFFFFFFFF)), // أبيض
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerOrdersScreen(
                  customerId: widget.customerId,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)), // الأزرق
              ),
            )
          : products.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد منتجات متاحة',
                    style: TextStyle(color: Color(0xFF212121)), // أسود
                  ),
                )
              : FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final cartItem = cart.firstWhere(
                              (item) => item.productId == product.id.toString(),
                              orElse: () => OrderItem(
                                productId: product.id.toString(),
                                productName: product.name,
                                price: product.price ?? 0.0,
                                quantity: 0,
                              ),
                            );
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Icon(Icons.store, color: Color(0xFF2196F3)), // الأزرق
                                title: Text(
                                  product.name ?? 'منتج غير معروف',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF212121), // أسود
                                  ),
                                ),
                                subtitle: Text(
                                  'السعر: ${product.price?.toStringAsFixed(2) ?? '0.00'} \$ | '
                                  'الكمية المتاحة: ${product.quantity ?? 0}',
                                  style: TextStyle(color: Color(0xFF212121)), // أسود
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, color: Color(0xFF2196F3)), // الأزرق
                                      onPressed: () {
                                        addToCart(product, -1);
                                      },
                                    ),
                                    Text(
                                      '${cartItem.quantity}',
                                      style: TextStyle(color: Color(0xFF212121)), // أسود
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add, color: Color(0xFF2196F3)), // الأزرق
                                      onPressed: () {
                                        addToCart(product, 1);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: Column(
                            children: [
                              Text(
                                'إجمالي السلة: ${cart.fold(0.0, (sum, item) => sum + item.quantity! * item.price!).toStringAsFixed(2)} \$',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121), // أسود
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: placeOrder,
                                child: const Text('إتمام الطلب'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => setState(() => cart.clear()),
                                child: Text(
                                  'تفريغ السلة',
                                  style: TextStyle(color: Color(0xFF2196F3)), // الأزرق
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}