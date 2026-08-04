import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as ex;
import 'package:intl/intl.dart';

import '../../data/models/invoice_model.dart';
import '../constants/app_constants.dart';
import 'report_analytics.dart';

class ReportExporter {
  ReportExporter._();

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.defaultCurrency,
    decimalDigits: 2,
  );

  /// Builds a PDF sales report document
  static Future<pw.Document> buildPdfReport({
    required List<InvoiceModel> invoices,
    required double estimatedProfit,
  }) async {
    final doc = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');
    final bestSellers = ReportAnalytics.bestSellers(invoices);
    final totalSales = ReportAnalytics.totalSales(invoices);
    final totalGst = ReportAnalytics.totalGstCollected(invoices);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Text(
            'Sales Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('Generated: ${dateFormat.format(DateTime.now())}'),
          pw.SizedBox(height: 16),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _statBox('Total Sales', _currency.format(totalSales)),
              _statBox('Total Orders', '${invoices.length}'),
              _statBox('GST Collected', _currency.format(totalGst)),
              _statBox('Est. Profit', _currency.format(estimatedProfit)),
            ],
          ),
          pw.SizedBox(height: 20),

          pw.Text('Top Selling Products',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('Product', bold: true),
                  _cell('Qty Sold', bold: true),
                  _cell('Revenue', bold: true),
                ],
              ),
              ...bestSellers.map(
                (p) => pw.TableRow(
                  children: [
                    _cell(p.productName),
                    _cell('${p.quantitySold}'),
                    _cell(_currency.format(p.revenue)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          pw.Text('All Transactions',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(3),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('Invoice #', bold: true),
                  _cell('Date', bold: true),
                  _cell('Customer', bold: true),
                  _cell('Total', bold: true),
                ],
              ),
              ...invoices.map(
                (inv) => pw.TableRow(
                  children: [
                    _cell(inv.invoiceNumber),
                    _cell(dateFormat.format(inv.createdAt)),
                    _cell(inv.customerName ?? 'Walk-in'),
                    _cell(_currency.format(inv.grandTotal)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return doc;
  }

  static pw.Widget _statBox(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Builds an Excel workbook with all transactions, one row per invoice
  static Uint8List buildExcelReport(List<InvoiceModel> invoices) {
    final workbook = ex.Excel.createExcel();
    final sheet = workbook['Sales Report'];
    workbook.delete('Sheet1');

    sheet.appendRow([
      ex.TextCellValue('Invoice Number'),
      ex.TextCellValue('Date'),
      ex.TextCellValue('Customer'),
      ex.TextCellValue('Subtotal'),
      ex.TextCellValue('GST'),
      ex.TextCellValue('Discount'),
      ex.TextCellValue('Grand Total'),
      ex.TextCellValue('Payment Method'),
    ]);

    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

    for (final inv in invoices) {
      sheet.appendRow([
        ex.TextCellValue(inv.invoiceNumber),
        ex.TextCellValue(dateFormat.format(inv.createdAt)),
        ex.TextCellValue(inv.customerName ?? 'Walk-in'),
        ex.DoubleCellValue(inv.subtotal),
        ex.DoubleCellValue(inv.gstAmount),
        ex.DoubleCellValue(inv.discount),
        ex.DoubleCellValue(inv.grandTotal),
        ex.TextCellValue(inv.paymentMethod),
      ]);
    }

    final bytes = workbook.save();
    return Uint8List.fromList(bytes!);
  }
}
