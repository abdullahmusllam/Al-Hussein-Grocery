import 'package:db/views/debts_page.dart';
import 'package:db/views/orders_page.dart';
import 'package:db/views/product_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mainscreen.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  void _showLoadingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFFFFFFF), // الأبيض
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2196F3)), // الأزرق
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'الرجاء الانتظار حتى رفع البيانات',
                    style: TextStyle(color: Color(0xFF212121)), // أسود
                  ),
                ),
              ],
            ),
          );
        }).then((value) {
      Navigator.pop(context);
    });
  }

  void onButtonPressed(String buttonName, BuildContext context) {
    print('$buttonName button pressed');
    if (buttonName == 'الطلبات') {
      Get.to(OrdersPage());
    }
    if (buttonName == 'المنتجات') {
      Get.to(ManageProductsPage());
    }
    if (buttonName == 'الديون') {
      Get.to(DebtsPage());
    }
    if (buttonName == 'تحديث البيانات') {
      Get.to(MainScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // الأبيض
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store,
                    color: Color(0xFF2196F3), // الأزرق
                    size: 40,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'بقالة الحسين',
                    style: TextStyle(
                      color: Color(0xFF212121), // أسود
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildMenuButton(
                      context: context,
                      title: 'الطلبات',
                      icon: Icons.shopping_cart,
                      color: Color(0xFF2196F3), // الأزرق
                      onPressed: () => onButtonPressed('الطلبات', context),
                    ),
                    SizedBox(height: 30),
                    _buildMenuButton(
                      context: context,
                      title: 'المنتجات',
                      icon: Icons.inventory,
                      color: Color(0xFF2196F3), // الأزرق
                      onPressed: () => onButtonPressed('المنتجات', context),
                    ),
                    SizedBox(height: 30),
                    _buildMenuButton(
                      context: context,
                      title: 'الديون',
                      icon: Icons.credit_card,
                      color: Color(0xFF2196F3), // الأزرق
                      onPressed: () => onButtonPressed('الديون', context),
                    ),
                    SizedBox(height: 30),
                    _buildMenuButton(
                      context: context,
                      title: 'تحديث البيانات',
                      icon: Icons.update,
                      color: Color(0xFF2196F3), // الأزرق
                      onPressed: () =>
                          onButtonPressed('تحديث البيانات', context),
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

  Widget _buildMenuButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFFECEFF1), // رمادي فاتح
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF212121).withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF212121), // أسود
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
