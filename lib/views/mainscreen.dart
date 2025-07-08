import 'package:flutter/material.dart';
import 'package:db/controllers/sync.dart';
import 'package:db/controllers/controller.dart';
import 'package:db/views/home_page.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoading = true;
  String _loadingMessage = 'جاري تحميل البيانات...';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<bool> connected() async {
    bool conn = await InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  Future<void> _loadData() async {
    try {
      if (!await connected()) {
        return Get.to(() => MainPage());
      }
      // Update loading message
      setState(() {
        _loadingMessage = 'جاري مزامنة البيانات...';
      });

      // Sync data from remote database
      // await sync.syncProduct();
      await sync.syncDebts();

      setState(() {
        _loadingMessage = 'جاري تحميل ,ومزامنة البيانات ...';
      });

      // Load data to local storage
      // await controller.addToLocalProducts();
      // await controller.addToLocalOrders();
      await controller.addToLocalDebts();

      // Delay for a moment to show completion message
      setState(() {
        _loadingMessage = 'تم تحميل البيانات بنجاح!';
      });

      // Wait a moment before navigating
      await Future.delayed(Duration(seconds: 1));

      // Navigate to main page
      Get.off(MainPage());
    } catch (e) {
      setState(() {
        print(e);
        _loadingMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or app icon
              Icon(
                Icons.store,
                color: Color(0xFF2196F3),
                size: 80,
              ),
              SizedBox(height: 20),

              // App name
              Text(
                'بقالة الحسين',
                style: TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 50),

              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              ),
              SizedBox(height: 30),

              // Loading message
              Text(
                _loadingMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
