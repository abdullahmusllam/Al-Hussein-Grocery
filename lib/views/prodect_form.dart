import 'package:db/controllers/controller.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductForm extends StatefulWidget {
  final Product? product;
  final VoidCallback onSave;

  const ProductForm({this.product, required this.onSave});

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _categoryController = TextEditingController(text: widget.product?.category ?? '');
    _quantityController = TextEditingController(text: widget.product?.quantity?.toString() ?? '');
    _priceController = TextEditingController(text: widget.product?.price?.toString() ?? '');
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final Product product = Product(
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
    );

    if (widget.product == null) {
      await controller.addProduct(product, 1);
    } else {
      final updatedProduct = Product(
        id: widget.product!.id,
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      );
      await controller.updateProduct(updatedProduct, 1);
    }

    widget.onSave();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFFFFFF), // الأبيض
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Color(0xFFECEFF1), // رمادي فاتح
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Text(
              widget.product == null ? 'إضافة منتج' : 'تعديل منتج',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121), // أسود
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'اسم المنتج'),
              validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم المنتج' : null,
            ),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'الفئة'),
              validator: (value) => value!.isEmpty ? 'الرجاء إدخال الفئة' : null,
            ),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'الكمية'),
              keyboardType: TextInputType.number,
              validator: (value) => (int.tryParse(value ?? '') == null) ? 'أدخل كمية صالحة' : null,
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'السعر'),
              keyboardType: TextInputType.number,
              validator: (value) => (double.tryParse(value ?? '') == null) ? 'أدخل سعرًا صالحًا' : null,
            ),
            ElevatedButton.icon(
              onPressed: _saveProduct,
              icon: Icon(Icons.save),
              label: Text('حفظ'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}