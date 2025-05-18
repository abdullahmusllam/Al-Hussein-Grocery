import 'package:customer_alhussain/views/home_page.dart';
import 'package:customer_alhussain/views/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق العميل',
      theme: ThemeData(
        fontFamily: 'RB',
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
        cardTheme: CardTheme(
          elevation: 4,
          color: Color(0xFFECEFF1), // رمادي فاتح
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: Color(0xFF212121).withOpacity(0.2),
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
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Color(0xFFFFFFFF), // الأبيض
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)), // الأزرق
                ),
              ),
            );
          }
          return snapshot.data ?? const LoginScreen();
        },
      ),
    );
  }

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId') ?? '';
    final customerName = prefs.getString('customerName') ?? '';

    if (customerId.isNotEmpty && customerName.isNotEmpty) {
      return HomeScreen(
        customerId: customerId,
        customerName: customerName,
      );
    }
    return const LoginScreen();
  }
}