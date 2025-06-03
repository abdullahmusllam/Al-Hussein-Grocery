import 'package:db/controllers/controller.dart';
import 'package:db/views/prodect_form.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../models/product.dart';
import '../services/service.dart';

class ManageProductsPage extends StatefulWidget {
  @override
  _ManageProductsPageState createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await controller.getLocalProducts();
    setState(() {
      _products = products;
    });
  }

  void _showProductForm({Product? product}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ProductForm(
          product: product,
          onSave: _loadProducts,
        ),
      ),
    );
  }

  Future<void> _deleteProduct(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFFFFFFF), // الأبيض
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(color: Color(0xFF212121)), // أسود
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا المنتج؟',
          style: TextStyle(color: Color(0xFF212121)), // أسود
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: TextStyle(color: Color(0xFF212121)), // أسود
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'حذف',
              style: TextStyle(color: Color(0xFFD32F2F)), // أحمر
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bool connect = await InternetConnectionChecker.createInstance().hasConnection;
      if (!connect) {
        print(connect);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('أنت غير متصل بالإنترنت')),
        );
        return;
      }
      await service.deleteProduct(id);
      await controller.deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف المنتج بنجاح')),
      );
    }
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filtered = _products.where((product) {
      return (product.name ?? '').toLowerCase().contains(query) ||
          (product.category ?? '').toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // الأبيض
      appBar: AppBar(
        title: Text('إدارة المنتجات'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file, color: Color(0xFFFFFFFF)), // أبيض
            tooltip: 'استيراد منتجات من Excel',
            onPressed: () => Controller.importProductsFromExcel(context, controller),
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث عن منتج...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF212121)), // أسود
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد منتجات',
                      style: TextStyle(color: Color(0xFF212121)), // أسود
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    padding: EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            product.name ?? '',
                            style: TextStyle(color: Color(0xFF212121)), // أسود
                          ),
                          subtitle: Text(
                            'الفئة: ${product.category ?? ''}\nالسعر: ${product.price ?? 0}',
                            style: TextStyle(color: Color(0xFF212121)), // أسود
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Color(0xFF2196F3)), // الأزرق
                                onPressed: () => _showProductForm(product: product),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Color(0xFFD32F2F)), // أحمر
                                onPressed: () => _deleteProduct(product.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        backgroundColor: Color(0xFF2196F3), // الأزرق
        child: Icon(Icons.add, color: Color(0xFFFFFFFF)), // أبيض
      ),
    );
  }
}