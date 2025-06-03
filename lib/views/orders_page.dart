import 'package:flutter/material.dart';
import '../models/order.dart';
import '../controllers/controller.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:io';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await controller.getLocalOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل الطلبات: $e')),
      );
    }
  }

  Future<void> _toggleOrderStatus(OrderModel order) async {
    try {
      bool newStatus = !order.isPaid;
      await controller.updateOrderStatus(order.id!, newStatus);
      setState(() {
        _orders = _orders.map((o) {
          if (o.id == order.id) {
            return OrderModel(
              id: o.id,
              customerId: o.customerId,
              customerName: o.customerName,
              totalAmount: o.totalAmount,
              createdAt: o.createdAt,
              isPaid: newStatus,
              debtDate: o.debtDate,
              items: o.items,
            );
          }
          return o;
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث حالة الطلب بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحديث حالة الطلب: $e')),
      );
    }
  }

  Future<void> _generateInvoicePdf(OrderModel order) async {
    try {
      print('===== بدء إنشاء فاتورة PDF للطلب ID: ${order.id} =====');
      final pdf = pw.Document();

      final fontData = await DefaultAssetBundle.of(context).load('assets/fonts/RB_Regular.ttf');
      final font = pw.Font.ttf(fontData);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'فاتورة طلب',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'اسم العميل: ${order.customerName ?? 'غير محدد'}',
                    style: pw.TextStyle(font: font, fontSize: 16),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.Text(
                    'تاريخ الطلب: ${DateFormat('yyyy-MM-dd').format(order.createdAt ?? DateTime.now())}',
                    style: pw.TextStyle(font: font, fontSize: 16),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.Text(
                    'تاريخ الدين: ${DateFormat('yyyy-MM-dd').format(order.debtDate ?? DateTime.now())}',
                    style: pw.TextStyle(font: font, fontSize: 16),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.Text(
                    'الحالة: ${order.isPaid ? 'مدفوع' : 'غير مدفوع'}',
                    style: pw.TextStyle(font: font, fontSize: 16),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.SizedBox(height: 20),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    defaultColumnWidth: pw.FractionColumnWidth(0.25),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'اسم المنتج',
                              style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
                              textDirection: pw.TextDirection.rtl,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'السعر',
                              style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
                              textDirection: pw.TextDirection.rtl,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'الكمية',
                              style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
                              textDirection: pw.TextDirection.rtl,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'الإجمالي',
                              style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
                              textDirection: pw.TextDirection.rtl,
                            ),
                          ),
                        ],
                      ),
                      ...(order.items ?? []).map((item) {
                        final total = (item.price ?? 0.0) * (item.quantity ?? 0);
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                item.productName ?? 'غير محدد',
                                style: pw.TextStyle(font: font),
                                textDirection: pw.TextDirection.rtl,
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                '\$${item.price?.toStringAsFixed(2) ?? '0.00'}',
                                style: pw.TextStyle(font: font),
                                textDirection: pw.TextDirection.rtl,
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                '${item.quantity ?? 0}',
                                style: pw.TextStyle(font: font),
                                textDirection: pw.TextDirection.rtl,
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: pw.TextStyle(font: font),
                                textDirection: pw.TextDirection.rtl,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'المبلغ الإجمالي: \$${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ],
              ),
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/invoice_${order.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      print('===== محاولة حفظ PDF في: ${file.path} =====');
      await file.writeAsBytes(await pdf.save());
      print('===== تم حفظ PDF بنجاح في: ${file.path} =====');

      final result = await OpenFile.open(file.path);
      print('===== نتيجة فتح الملف: Type=${result.type}, Message=${result.message} =====');
      if (result.type != ResultType.done) {
        print('===== فشل في فتح الملف، محاولة المشاركة بدلاً من ذلك =====');
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'فاتورة الطلب ${order.id}',
          subject: 'فاتورة الطلب ${order.id}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في فتح الفاتورة: ${result.message}. تمت محاولة المشاركة.'),
            action: SnackBarAction(
              label: 'إغلاق',
              onPressed: () {},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم فتح الفاتورة بنجاح')),
        );
      }
    } catch (e) {
      print('===== خطأ في إنشاء أو حفظ الفاتورة: $e =====');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إنشاء الفاتورة: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // الأبيض
      appBar: AppBar(
        title: Text(
          'الطلبات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)), // الأزرق
                strokeWidth: 4,
              ),
            )
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Color(0xFF212121).withOpacity(0.5), // أسود
                      ),
                      SizedBox(height: 20),
                      Text(
                        'لا توجد طلبات',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF212121), // أسود
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFECEFF1), // رمادي فاتح
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Color(0xFF2196F3), // الأزرق
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    order.customerName ?? 'عميل',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF212121), // أسود
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildActionButton(
                                      icon: Icons.print,
                                      color: Color(0xFF2196F3), // الأزرق
                                      onPressed: () => _generateInvoicePdf(order),
                                      tooltip: 'طباعة الفاتورة',
                                    ),
                                    SizedBox(width: 8),
                                    _buildActionButton(
                                      icon: Icons.delete,
                                      color: Color(0xFFD32F2F), // أحمر
                                      onPressed: () async {
                                        try {
                                          await controller.deleteOrder(order.id!);
                                          _loadOrders();
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('فشل في حذف الطلب: $e')),
                                          );
                                        }
                                      },
                                      tooltip: 'حذف',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.calendar_today,
                              text: 'التاريخ: ${DateFormat('yyyy-MM-dd').format(order.debtDate ?? DateTime.now())}',
                              iconColor: Color(0xFF2196F3), // الأزرق
                            ),
                            SizedBox(height: 8),
                            _buildInfoRow(
                              icon: Icons.attach_money,
                              text: 'المبلغ الإجمالي: \$${order.totalAmount?.toStringAsFixed(2)}',
                              iconColor: Color(0xFFFFCA28), // أصفر
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFECEFF1), // رمادي فاتح
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: order.isPaid ? Color(0xFF4CAF50) : Color(0xFFD32F2F), // أخضر أو أحمر
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'الحالة: ${order.isPaid ? 'مدفوع' : 'غير مدفوع'}',
                                  style: TextStyle(
                                    color: Color(0xFF212121), // أسود
                                    fontSize: 16,
                                  ),
                                ),
                                Spacer(),
                                Switch(
                                  value: order.isPaid,
                                  activeColor: Color(0xFF4CAF50), // أخضر
                                  inactiveThumbColor: Color(0xFFD32F2F), // أحمر
                                  onChanged: (value) => _toggleOrderStatus(order),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFECEFF1), // رمادي فاتح
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: color,
          size: 24,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFECEFF1), // رمادي فاتح
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
        SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Color(0xFF212121), // أسود
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }
}