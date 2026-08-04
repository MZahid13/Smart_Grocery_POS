import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../data/models/invoice_model.dart';
import '../constants/app_constants.dart';

class ShopInfo {
  final String name;
  final String address;
  final String gstNumber;
  final String phone;

  const ShopInfo({
    required this.name,
    required this.address,
    required this.gstNumber,
    required this.phone,
  });

  static const ShopInfo placeholder = ShopInfo(
    name: 'Your Shop Name',
    address: 'Shop Address, City, State - Pincode',
    gstNumber: 'GSTIN0000000000',
    phone: '+91 00000 00000',
  );

  factory ShopInfo.fromSettings({
    required String name,
    required String address,
    required String gstNumber,
    required String phone,
  }) {
    return ShopInfo(
      name: name,
      address: address,
      gstNumber: gstNumber,
      phone: phone,
    );
  }
}

class InvoicePdfGenerator {
  InvoicePdfGenerator._();

  static Future<pw.Document> generate({
    required InvoiceModel invoice,
    ShopInfo shop = ShopInfo.placeholder,
  }) async {
    final doc = pw.Document();

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.defaultCurrency,
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Shop header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      shop.name,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(shop.address, style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('GSTIN: ${shop.gstNumber}',
                        style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('Phone: ${shop.phone}',
                        style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),

              // Invoice meta
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Invoice: ${invoice.invoiceNumber}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(dateFormat.format(invoice.createdAt)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text('Customer: ${invoice.customerName ?? 'Walk-in Customer'}'),
              pw.SizedBox(height: 12),
              pw.Divider(),

              // Items table
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  ...invoice.items.map(
                    (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4),
                          child: pw.Text(item.productName, style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4),
                          child: pw.Text('${item.quantity}', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4),
                          child: pw.Text(currency.format(item.sellingPrice), style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4),
                          child: pw.Text(currency.format(item.total), style: const pw.TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),

              // Totals
              _totalRow('Subtotal', currency.format(invoice.subtotal)),
              _totalRow('GST', currency.format(invoice.gstAmount)),
              _totalRow('Discount', currency.format(invoice.discount)),
              pw.Divider(),
              _totalRow(
                'Grand Total',
                currency.format(invoice.grandTotal),
                bold: true,
                fontSize: 14,
              ),
              pw.SizedBox(height: 8),
              pw.Text('Payment Method: ${invoice.paymentMethod}'),

              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Thank you for shopping with us!',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc;
  }

  static pw.Widget _totalRow(
    String label,
    String value, {
    bool bold = false,
    double fontSize = 11,
  }) {
    final style = pw.TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }
}
