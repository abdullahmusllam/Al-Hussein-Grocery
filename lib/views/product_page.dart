import 'package:db/controllers/controller.dart';
import 'package:db/views/prodect_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../models/product.dart';
import '../services/service.dart';

class ManageProductsPage extends StatelessWidget {
  final Controller control = Get.put(Controller());

  void _showProductForm(BuildContext context, {Product? product}) async {
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
          onSave: control.getLocalProducts,
        ),
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('تأكيد الحذف', style: TextStyle(color: Colors.black87)),
        content: Text('هل أنت متأكد من حذف هذا المنتج؟', style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(color: Colors.black87)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bool connect = await InternetConnectionChecker.createInstance().hasConnection;
      if (!connect) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('أنت غير متصل بالإنترنت')),
        );
        return;
      }

      await service.deleteProduct(id);
      await control.deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف المنتج بنجاح')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('إدارة المنتجات'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file, color: Colors.white),
            tooltip: 'استيراد منتجات من Excel',
            onPressed: () => Controller.importProductsFromExcel(context, control),
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: control.searchController, // استخدم الكنترولر من الكنترولر إذا موجود
              decoration: InputDecoration(
                hintText: 'بحث عن منتج...',
                prefixIcon: Icon(Icons.search, color: Colors.black87),
              ),
              onChanged: (val) => control.search.value = val.toLowerCase(),
            ),
          ),
          Expanded(
            child: Obx(() {
              final query = control.search.value;
              final filtered = control.products.where((product) {
                return (product.name ?? '').toLowerCase().contains(query) ||
                    (product.category ?? '').toLowerCase().contains(query);
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text('لا توجد منتجات', style: TextStyle(color: Colors.black87)),
                );
              }

              return ListView.builder(
                itemCount: control.products.length,
                padding: EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final product = control.products[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(product.name ?? '', style: TextStyle(color: Colors.black87)),
                      subtitle: Text(
                        'الفئة: ${product.category ?? ''}\nالسعر: ${product.price ?? 0}',
                        style: TextStyle(color: Colors.black87),
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showProductForm(context, product: product),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(context, product.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(context),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
