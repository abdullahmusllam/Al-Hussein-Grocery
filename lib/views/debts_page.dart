// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../services/service.dart';
// import '../models/debt.dart';
// import 'dart:ui';

// class DebtsPage extends StatefulWidget {
//   @override
//   _DebtsPageState createState() => _DebtsPageState();
// }

// class _DebtsPageState extends State<DebtsPage> {
//   final Service _service = Service();
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _amountController = TextEditingController();
//   final _discountController = TextEditingController();
//   final _increaseAmountController = TextEditingController();

//   void _showAddDebtDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//         title: Text('إضافة دين جديد',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//             color: Colors.blue[900],
//           ),
//         ),
//         content: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'اسم العميل',
//                   labelStyle: TextStyle(
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   filled: true,
//                   fillColor: Colors.blue[50]!.withOpacity(0.3),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال اسم العميل';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: InputDecoration(
//                   labelText: 'رقم الهاتف',
//                   labelStyle: TextStyle(
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   prefixIcon: Icon(Icons.phone, color: Colors.blue[700]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   filled: true,
//                   fillColor: Colors.blue[50]!.withOpacity(0.3),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال رقم الهاتف';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: 'المبلغ',
//                   labelStyle: TextStyle(
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   prefixIcon: Icon(Icons.attach_money, color: Colors.blue[700]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   filled: true,
//                   fillColor: Colors.blue[50]!.withOpacity(0.3),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال المبلغ';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'الرجاء إدخال مبلغ صحيح';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _discountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: 'الخصم',
//                   labelStyle: TextStyle(
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   prefixIcon: Icon(Icons.discount, color: Colors.blue[700]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   filled: true,
//                   fillColor: Colors.blue[50]!.withOpacity(0.3),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال قيمة الخصم';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'الرجاء إدخال قيمة صحيحة';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _nameController.clear();
//               _phoneController.clear();
//               _amountController.clear();
//               _discountController.clear();
//             },
//             child: Text('إلغاء',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (_formKey.currentState!.validate()) {
//                 final debt = Debt(
//                   id: '', // سيتم تعيينه من قبل Firebase
//                   customerId: '', // سيتم تعيينه من قبل Firebase
//                   customerName: _nameController.text,
//                   customerPhone: _phoneController.text,
//                   totalDebt: double.parse(_amountController.text),
//                   debtDiscount: double.parse(_discountController.text),
//                   debtDate: DateTime.now(),
//                 );
//                 await _service.addDebt(debt);
//                 Navigator.pop(context);
//                 _nameController.clear();
//                 _phoneController.clear();
//                 _amountController.clear();
//                 _discountController.clear();
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue[900],
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             child: Text('إضافة',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditDebtDialog(Debt debt) {
//     _nameController.text = debt.customerName;
//     _phoneController.text = debt.customerPhone;
//     _amountController.text = debt.totalDebt.toString();
//     _discountController.text = debt.debtDiscount.toString();
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text('تعديل الدين',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//             color: Colors.blue[900],
//           ),
//         ),
//         content: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'اسم العميل',
//                   labelStyle: TextStyle(
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال اسم العميل';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: InputDecoration(
//                   labelText: 'رقم الهاتف',
//                   labelStyle: TextStyle(
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   prefixIcon: Icon(Icons.phone, color: Colors.blue[700]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال رقم الهاتف';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: 'المبلغ',
//                   labelStyle: TextStyle(
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   prefixIcon: Icon(Icons.attach_money, color: Colors.blue[700]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال المبلغ';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'الرجاء إدخال مبلغ صحيح';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _discountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: 'الخصم',
//                   labelStyle: TextStyle(
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   prefixIcon: Icon(Icons.discount, color: Colors.blue[700]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال قيمة الخصم';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'الرجاء إدخال قيمة صحيحة';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _nameController.clear();
//               _phoneController.clear();
//               _amountController.clear();
//               _discountController.clear();
//             },
//             child: Text('إلغاء',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (_formKey.currentState!.validate()) {
//                 final updatedDebt = Debt(
//                   id: debt.id,
//                   customerId: debt.customerId,
//                   customerName: _nameController.text,
//                   customerPhone: _phoneController.text,
//                   totalDebt: double.parse(_amountController.text),
//                   debtDiscount: double.parse(_discountController.text),
//                   debtDate: debt.debtDate,
//                 );
//                 await _service.updateDebt(updatedDebt);
//                 Navigator.pop(context);
//                 _nameController.clear();
//                 _phoneController.clear();
//                 _amountController.clear();
//                 _discountController.clear();
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue[900],
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//             child: Text('تحديث',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showIncreaseDebtDialog(Debt debt) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//         title: Text('زيادة الدين',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//             color: Colors.blue[900],
//           ),
//         ),
//         content: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50]!.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('العميل: ${debt.customerName}',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text('الدين الحالي: \$${debt.remainingAmount.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _increaseAmountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: 'المبلغ المراد إضافته',
//                   labelStyle: TextStyle(
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   prefixIcon: Icon(Icons.add, color: Colors.blue[700]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   filled: true,
//                   fillColor: Colors.blue[50]!.withOpacity(0.3),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال المبلغ';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'الرجاء إدخال مبلغ صحيح';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _increaseAmountController.dispose();
//             },
//             child: Text('إلغاء',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (_formKey.currentState!.validate()) {
//                 final increaseAmount = double.parse(_increaseAmountController.text);
//                 debt.increaseDebt(increaseAmount, 'زيادة الدين');
//                 await _service.updateDebt(debt);
//                 Navigator.pop(context);
//                 _increaseAmountController.dispose();
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue[900],
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             child: Text('زيادة',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _deleteDebt(String id) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text('تأكيد الحذف', 
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.red[700],
//             fontSize: 20,
//           ),
//         ),
//         content: Text('هل أنت متأكد من حذف هذا الدين؟',
//           style: TextStyle(fontSize: 16),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('إلغاء', 
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text('حذف', 
//               style: TextStyle(
//                 color: Colors.red[700],
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       await _service.deleteDebt(int.parse(id));
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _amountController.dispose();
//     _discountController.dispose();
//     _increaseAmountController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       appBar: AppBar(
//         title: Text('الديون'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Theme.of(context).colorScheme.primary,
//               Theme.of(context).colorScheme.background,
//             ],
//           ),
//         ),
//         child: StreamBuilder<List<Debt>>(
//           stream: _service.getDebts(),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline, 
//                       color: Colors.red[700], 
//                       size: 80,
//                     ),
//                     SizedBox(height: 20),
//                     Text('حدث خطأ: ${snapshot.error}',
//                       style: TextStyle(
//                         color: Colors.red[700],
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             if (!snapshot.hasData) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
//                   strokeWidth: 4,
//                 ),
//               );
//             }

//             final debts = snapshot.data!;
            
//             if (debts.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.credit_card_off, 
//                       size: 80, 
//                       color: Colors.grey[400],
//                     ),
//                     SizedBox(height: 20),
//                     Text('لا توجد ديون',
//                       style: TextStyle(
//                         fontSize: 20, 
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return ListView.builder(
//               padding: EdgeInsets.all(16),
//               itemCount: debts.length,
//               itemBuilder: (context, index) {
//                 final debt = debts[index];
//                 return Card(
//                   margin: EdgeInsets.only(bottom: 16),
//                   elevation: 8,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(25),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           Colors.white,
//                           Colors.blue[50]!,
//                         ],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.blue.withOpacity(0.1),
//                           blurRadius: 15,
//                           offset: Offset(0, 8),
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 padding: EdgeInsets.all(10),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue[50],
//                                   borderRadius: BorderRadius.circular(12),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.blue.withOpacity(0.2),
//                                       blurRadius: 8,
//                                       offset: Offset(0, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Icon(
//                                   Icons.account_circle,
//                                   color: Colors.blue[700],
//                                   size: 28,
//                                 ),
//                               ),
//                               SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   debt.customerName,
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                     color: Colors.blue[900],
//                                   ),
//                                 ),
//                               ),
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.blue[50],
//                                       borderRadius: BorderRadius.circular(12),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.blue.withOpacity(0.3),
//                                           blurRadius: 10,
//                                           offset: Offset(0, 4),
//                                         ),
//                                       ],
//                                     ),
//                                     child: IconButton(
//                                       icon: Icon(
//                                         Icons.add,
//                                         color: Colors.blue[800],
//                                         size: 24,
//                                       ),
//                                       onPressed: () => _showIncreaseDebtDialog(debt),
//                                       tooltip: 'زيادة الدين',
//                                     ),
//                                   ),
//                                   SizedBox(width: 8),
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.blue[50],
//                                       borderRadius: BorderRadius.circular(12),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.blue.withOpacity(0.3),
//                                           blurRadius: 10,
//                                           offset: Offset(0, 4),
//                                         ),
//                                       ],
//                                     ),
//                                     child: IconButton(
//                                       icon: Icon(
//                                         Icons.edit,
//                                         color: Colors.blue[800],
//                                         size: 24,
//                                       ),
//                                       onPressed: () => _showEditDebtDialog(debt),
//                                       tooltip: 'تعديل',
//                                     ),
//                                   ),
//                                   SizedBox(width: 8),
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.red[50],
//                                       borderRadius: BorderRadius.circular(12),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.red.withOpacity(0.3),
//                                           blurRadius: 10,
//                                           offset: Offset(0, 4),
//                                         ),
//                                       ],
//                                     ),
//                                     child: IconButton(
//                                       icon: Icon(
//                                         Icons.delete,
//                                         color: Colors.red[800],
//                                         size: 24,
//                                       ),
//                                       onPressed: () => _deleteDebt(debt.id),
//                                       tooltip: 'حذف',
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 12),
//                           _buildInfoRow(
//                             icon: Icons.phone,
//                             text: debt.customerPhone,
//                             iconColor: Colors.blue[700]!,
//                           ),
//                           SizedBox(height: 8),
//                           _buildInfoRow(
//                             icon: Icons.attach_money,
//                             text: 'المبلغ المستحق: \$${debt.remainingAmount.toStringAsFixed(2)}',
//                             iconColor: Colors.red[700]!,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddDebtDialog,
//         child: Icon(Icons.add, size: 28),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         elevation: 6,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow({
//     required IconData icon,
//     required String text,
//     required Color iconColor,
//   }) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             icon,
//             size: 18,
//             color: iconColor,
//           ),
//         ),
//         SizedBox(width: 12),
//         Text(
//           text,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//           ),
//         ),
//       ],
//     );
//   }
// }
