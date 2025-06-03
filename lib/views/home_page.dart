import 'package:animate_do/animate_do.dart';
import 'package:customer_alhussain/controller/controllerFile.dart';
import 'package:customer_alhussain/views/CustomerOrdersScreen.dart';
import 'package:customer_alhussain/views/product_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const HomeScreen({
    Key? key,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Controller controller = Controller();
  double totalDebt = 0.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDebt();
  }

  Future<void> fetchDebt() async {
    setState(() {
      isLoading = true;
    });
    try {
      await controller.addToLocalProducts();
      await controller.addToLocalOrders(widget.customerId);
      await controller.syncDebtToSharedPreferences(widget.customerId);
      totalDebt = await controller.getDebtFromSharedPreferences(widget.customerId);
    } catch (e) {
      print('Error fetching debt: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // الأبيض
      body: SafeArea(
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)), // الأزرق
                )
              : FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // رسالة ترحيب
                          ZoomIn(
                            duration: const Duration(milliseconds: 1000),
                            child: Text(
                              'مرحبًا، ${widget.customerName}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121), // أسود
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // عرض الدين
                          if (totalDebt > 0)
                            FadeInUp(
                              duration: const Duration(milliseconds: 900),
                              child: Card(
                                color: Color(0xFFF5F5F5), // فاتح
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'إجمالي الدين المستحق:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD32F2F), // أحمر
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${totalDebt.toStringAsFixed(2)} \$',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD32F2F), // أحمر
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (totalDebt > 0) const SizedBox(height: 24),
                          // زر الانتقال إلى صفحة الحجز
                          FadeInUp(
                            duration: const Duration(milliseconds: 1000),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerBookingScreen(
                                      customerId: widget.customerId,
                                      customerName: widget.customerName,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.store, size: 24),
                              label: const Text(
                                'تصفح المنتجات',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // زر الانتقال إلى صفحة الطلبات
                          FadeInUp(
                            duration: const Duration(milliseconds: 1100),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerOrdersScreen(
                                      customerId: widget.customerId,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.list, size: 24),
                              label: const Text(
                                'عرض الطلبات',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}