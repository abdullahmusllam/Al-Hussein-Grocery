import 'package:db/views/prodect_form.dart';
import 'package:db/firebase_options.dart';
import 'package:db/sqldb.dart';
import 'package:db/views/orders_page.dart';
import 'package:db/views/home_page.dart';
import 'package:db/views/product_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

SqlDb sql = SqlDb();

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'بقالة الحسين ',
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: Color(0xFF2196F3), // الأزرق الأساسي
          onPrimary: Color(0xFFFFFFFF), // نص أبيض على الأزرق
          secondary: Color(0xFFFFCA28), // أصفر للإبراز
          onSecondary: Color(0xFF212121), // نص أسود على الأصفر
          surface: Color(0xFFFFFFFF), // الأبيض للخلفيات
          onSurface: Color(0xFF212121), // نص أسود على الأبيض
          background: Color(0xFFFFFFFF), // خلفية بيضاء
          onBackground: Color(0xFF212121), // نص أسود
          error: Color(0xFFD32F2F), // أحمر للأخطاء
          onError: Color(0xFFFFFFFF), // نص أبيض على الأحمر
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'RB',
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2196F3), // الأزرق
          foregroundColor: Color(0xFFFFFFFF), // نص أبيض
          elevation: 4,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
            color: Color(0xFFFFFFFF),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Color(0xFFFFFFFF), // نص أبيض
            backgroundColor: Color(0xFF2196F3), // الأزرق
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          color: Color(0xFFECEFF1), // رمادي فاتح
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Color(0xFF212121).withOpacity(0.2),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFECEFF1), // رمادي فاتح
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(color: Color(0xFF212121)), // نص أسود
          hintStyle: TextStyle(color: Color(0xFF212121).withOpacity(0.6)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFFFFCA28), // أصفر
          contentTextStyle: TextStyle(color: Color(0xFF212121)), // نص أسود
          actionTextColor: Color(0xFF2196F3), // أزرق للأزرار
        ),
      ),
      locale: Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      routes: {
        '/products': (context) => ManageProductsPage(),
        '/orders': (context) => OrdersPage(),
      },
      home: MainPage(),
    );
  }
}