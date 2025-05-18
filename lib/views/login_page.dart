import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_alhussain/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      if (phone.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = 'يرجى إدخال رقم الهاتف وكلمة المرور';
          _isLoading = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('phone', isEqualTo: phone)
          .where('password', isEqualTo: password)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final customerData = snapshot.docs.first.data();
        final customerId = snapshot.docs.first.id;
        final customerName = customerData['name'] as String;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('customerId', customerId);
        await prefs.setString('customerName', customerName);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              customerId: customerId,
              customerName: customerName,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'رقم الهاتف أو كلمة المرور غير صحيحة';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();

      if (phone.isEmpty || password.isEmpty || name.isEmpty) {
        setState(() {
          _errorMessage = 'يرجى إدخال جميع الحقول';
          _isLoading = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('phone', isEqualTo: phone)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _errorMessage = 'رقم الهاتف مسجل بالفعل';
          _isLoading = false;
        });
        return;
      }

      final newCustomer = {
        'phone': phone,
        'password': password,
        'name': name,
      };
      final docRef = await FirebaseFirestore.instance.collection('customers').add(newCustomer);
      final customerId = docRef.id;
      final customerName = name;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('customerId', customerId);
      await prefs.setString('customerName', customerName);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            customerId: customerId,
            customerName: customerName,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // الأبيض
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121), // أسود
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: Icon(Icons.phone, color: Color(0xFF2196F3)), // الأزرق
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF2196F3)), // الأزرق
                      ),
                      obscureText: true,
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'الاسم',
                          prefixIcon: Icon(Icons.person, color: Color(0xFF2196F3)), // الأزرق
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Color(0xFFD32F2F)), // أحمر
                        ),
                      ),
                    _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)), // الأزرق
                          )
                        : ElevatedButton(
                            onPressed: _isLogin ? _handleLogin : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Text(
                              _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                          _phoneController.clear();
                          _passwordController.clear();
                          _nameController.clear();
                        });
                      },
                      child: Text(
                        _isLogin ? 'ليس لديك حساب؟ إنشاء حساب' : 'لديك حساب؟ تسجيل الدخول',
                        style: TextStyle(color: Color(0xFF2196F3)), // الأزرق
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