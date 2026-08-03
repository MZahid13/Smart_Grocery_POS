import 'dart:convert';
import 'cart_item_model.dart';

class InvoiceModel {
  final int? id;
  final String invoiceNumber;
  final int? customerId;
  final String? customerName;
  final List<CartItemModel> items;
  final double subtotal;
  final double gstAmount;
  final double discount;
  final double grandTotal;
  final String paymentMethod;
  final DateTime createdAt;

  InvoiceModel({
    this.id,
    required this.invoiceNumber,
    this.customerId,
    this.customerName,
    required this.items,
    required this.subtotal,
    required this.gstAmount,
    this.discount = 0.0,
    required this.grandTotal,
    required this.paymentMethod,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
      'subtotal': subtotal,
      'gstAmount': gstAmount,
      'discount': discount,
      'grandTotal': grandTotal,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    final itemsJson = jsonDecode(map['items'] as String) as List;
    return InvoiceModel(
      id: map['id'] as int?,
      invoiceNumber: map['invoiceNumber'] as String,
      customerId: map['customerId'] as int?,
      customerName: map['customerName'] as String?,
      items: itemsJson
          .map((e) => CartItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      subtotal: (map['subtotal'] as num).toDouble(),
      gstAmount: (map['gstAmount'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      grandTotal: (map['grandTotal'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
