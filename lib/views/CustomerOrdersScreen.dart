import 'package:customer_alhussain/controller/controllerFile.dart';
import 'package:customer_alhussain/model/debt.dart';
import 'package:customer_alhussain/model/orderItem.dart';
import 'package:customer_alhussain/model/orders.dart';
import 'package:flutter/material.dart';

class CustomerOrdersScreen extends StatefulWidget {
  final String customerId;

  const CustomerOrdersScreen({Key? key, required this.customerId}) : super(key: key);

  @override
  _CustomerOrdersScreenState createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  final Controller controller = Controller();
  List<OrderModel> orders = [];
  List<Debt> debts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      orders = await controller.getOrdersByCustomer(widget.customerId);
    } catch (e) {
      print('Error fetching data: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  // حوار تعديل الطلب
  Future<void> showEditOrderDialog(OrderModel order) async {
    // نسخة من العناصر للتعديل
    List<OrderItem> editedItems = order.items != null ? List.from(order.items!) : [];
    // إجمالي المبلغ بناءً على العناصر
    TextEditingController totalAmountController = TextEditingController(
      text: editedItems.fold<double>(
              0.0,
              (sum, item) => sum + (item.price ?? 0.0) * (item.quantity ?? 0))
          .toStringAsFixed(2),
    );
    bool isPaid = order.isPaid;
    DateTime? debtDate = order.debtDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل الطلب رقم ${order.id}'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // عرض العناصر
                  if (editedItems.isNotEmpty)
                    ...editedItems.asMap().entries.map((entry) {
                      int index = entry.key;
                      OrderItem item = entry.value;
                      TextEditingController quantityController = TextEditingController(
                        text: item.quantity.toString(),
                      );
                      return ListTile(
                        title: Text(item.productName ?? 'منتج غير معروف'),
                        subtitle: Text('السعر: ${item.price?.toStringAsFixed(2) ?? '0.00'} \$'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: quantityController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: 'الكمية'),
                                onChanged: (value) {
                                  setDialogState(() {
                                    int? newQuantity = int.tryParse(value);
                                    if (newQuantity != null && newQuantity >= 0) {
                                      editedItems[index].quantity = newQuantity;
                                      // إعادة حساب الإجمالي
                                      double newTotal = editedItems.fold<double>(
                                        0.0,
                                        (sum, item) => sum + (item.price ?? 0.0) * (item.quantity ?? 0),
                                      );
                                      totalAmountController.text = newTotal.toStringAsFixed(2);
                                    }
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Color(0xFFD32F2F)),
                              onPressed: () {
                                setDialogState(() {
                                  editedItems.removeAt(index);
                                  // إعادة حساب الإجمالي
                                  double newTotal = editedItems.fold<double>(
                                    0.0,
                                    (sum, item) => sum + (item.price ?? 0.0) * (item.quantity ?? 0),
                                  );
                                  totalAmountController.text = newTotal.toStringAsFixed(2);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  else
                    ListTile(
                      title: Text('لا توجد عناصر في هذا الطلب'),
                    ),
                  // إجمالي المبلغ
                  TextField(
                    controller: totalAmountController,
                    decoration: InputDecoration(labelText: 'إجمالي المبلغ'),
                    keyboardType: TextInputType.number,
                    enabled: false, // غير قابل للتعديل يدويًا
                  ),
                  // حالة الدفع
                  CheckboxListTile(
                    title: Text('مدفوع؟'),
                    value: isPaid,
                    onChanged: (value) {
                      setDialogState(() {
                        isPaid = value ?? false;
                      });
                    },
                  ),
                  // تاريخ الدفع المستحق
                  ListTile(
                    title: Text(debtDate != null
                        ? 'تاريخ الدفع المستحق: ${debtDate.toString().substring(0, 16)}'
                        : 'اختر تاريخ الدفع'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: debtDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          debtDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              final updatedOrder = OrderModel(
                id: order.id,
                customerId: order.customerId,
                customerName: order.customerName,
                totalAmount: double.tryParse(totalAmountController.text) ?? 0.0,
                createdAt: order.createdAt,
                isPaid: isPaid,
                debtDate: debtDate,
                items: editedItems, // العناصر المحدثة
              );
              await controller.updateOrder(updatedOrder);
              Navigator.pop(context);
              await fetchData(); // إعادة جلب البيانات لتحديث الواجهة
              setState(() {
                isLoading = false;
              });
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalDebt = debts.fold(0.0, (sum, debt) => sum + debt.remainingAmount);

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text("طلباتي"),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              ),
            )
          : Column(
              children: [
                if (totalDebt > 0)
                  Container(
                    color: Color(0xFFECEFF1),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إجمالي الدين المستحق:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                        Text(
                          '${totalDebt.toStringAsFixed(2)} \$',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: orders.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد طلبات',
                            style: TextStyle(color: Color(0xFF212121)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return Card(
                              child: ExpansionTile(
                                title: Text(
                                  'طلب رقم ${order.id ?? 'غير معروف'}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                                subtitle: Text(
                                  'الإجمالي: ${order.totalAmount?.toStringAsFixed(2) ?? '0.00'} \$ | '
                                  'الحالة: ${order.isPaid ? 'مدفوع' : 'غير مدفوع'}',
                                  style: TextStyle(
                                    color: order.isPaid ? Color(0xFF4CAF50) : Color(0xFFD32F2F),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Color(0xFF2196F3)),
                                      onPressed: () => showEditOrderDialog(order),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Color(0xFFD32F2F)),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('تأكيد الحذف'),
                                            content: Text('هل أنت متأكد من حذف الطلب رقم ${order.id}?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: Text('إلغاء'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: Text('حذف'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await controller.deleteOrder(order.id!);
                                          await fetchData(); // إعادة جلب البيانات لتحديث الواجهة
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                children: [
                                  if (order.items != null && order.items!.isNotEmpty)
                                    ...order.items!.map((item) => ListTile(
                                          leading: Icon(Icons.shopping_bag, color: Color(0xFF2196F3)),
                                          title: Text(
                                            item.productName ?? 'منتج غير معروف',
                                            style: TextStyle(color: Color(0xFF212121)),
                                          ),
                                          subtitle: Text(
                                            'السعر: ${item.price?.toStringAsFixed(2) ?? '0.00'} \$ | '
                                            'الكمية: ${item.quantity ?? 0}',
                                            style: TextStyle(color: Color(0xFF212121)),
                                          ),
                                        )).toList()
                                  else
                                    ListTile(
                                      title: Text(
                                        'لا توجد عناصر في هذا الطلب',
                                        style: TextStyle(color: Color(0xFF212121)),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'تاريخ الطلب: ${order.createdAt != null ? order.createdAt!.toString().substring(0, 16) : 'غير معروف'}',
                                          style: TextStyle(color: Color(0xFF212121).withOpacity(0.6)),
                                        ),
                                        if (order.debtDate != null)
                                          Text(
                                            'تاريخ الدفع المستحق: ${order.debtDate!.toString().substring(0, 16)}',
                                            style: TextStyle(color: Color(0xFF212121).withOpacity(0.6)),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}