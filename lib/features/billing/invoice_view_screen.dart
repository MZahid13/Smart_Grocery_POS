import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/invoice_pdf_generator.dart';
import '../../data/models/invoice_model.dart';
import '../../data/providers/settings_provider.dart';

class InvoiceViewScreen extends ConsumerWidget {
  const InvoiceViewScreen({super.key, required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.defaultCurrency,
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () => _printInvoice(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareInvoice(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(dateFormat.format(invoice.createdAt)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customer: ${invoice.customerName ?? 'Walk-in Customer'}',
                  ),
                  const SizedBox(height: 4),
                  Text('Payment: ${invoice.paymentMethod}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Divider(),
                  ...invoice.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(item.productName),
                          ),
                          Expanded(
                            child: Text('×${item.quantity}',
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              currency.format(item.total),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row('Subtotal', currency.format(invoice.subtotal)),
                  _row('GST', currency.format(invoice.gstAmount)),
                  _row('Discount', currency.format(invoice.discount)),
                  const Divider(),
                  _row(
                    'Grand Total',
                    currency.format(invoice.grandTotal),
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Back to Dashboard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.go('/billing'),
                  child: const Text('New Bill'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 16 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  Future<void> _printInvoice(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final doc = await InvoicePdfGenerator.generate(
      invoice: invoice,
      shop: ShopInfo.fromSettings(
        name: settings.shopName,
        address: settings.shopAddress,
        gstNumber: settings.gstNumber,
        phone: settings.phone,
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  Future<void> _shareInvoice(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final doc = await InvoicePdfGenerator.generate(
      invoice: invoice,
      shop: ShopInfo.fromSettings(
        name: settings.shopName,
        address: settings.shopAddress,
        gstNumber: settings.gstNumber,
        phone: settings.phone,
      ),
    );
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: '${invoice.invoiceNumber}.pdf',
    );
  }
}
