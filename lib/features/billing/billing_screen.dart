import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/providers/customer_provider.dart';
import '../../data/providers/invoice_provider.dart';
import '../../data/providers/product_provider.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final _searchController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  String _paymentMethod = AppConstants.paymentMethods.first;
  CustomerModel? _selectedCustomer;

  final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.defaultCurrency,
    decimalDigits: 2,
  );

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final productNotifier = ref.read(productProvider.notifier);
    final customers = ref.watch(customerProvider);

    final discount = double.tryParse(_discountController.text) ?? 0;
    final subtotal = cartNotifier.subtotal;
    final gst = cartNotifier.totalGst;
    final grandTotal = cartNotifier.grandTotal(discount: discount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear cart',
              onPressed: () => cartNotifier.clearCart(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search + Scan row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search product name or barcode',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (query) async {
                      final results = productNotifier.search(query);
                      if (results.length == 1) {
                        cartNotifier.addProduct(results.first);
                        _searchController.clear();
                      } else if (results.isNotEmpty) {
                        _showSearchResults(context, results, cartNotifier);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () => context.push('/scan'),
                ),
              ],
            ),
          ),

          // Customer selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<CustomerModel?>(
              initialValue: _selectedCustomer,
              decoration: const InputDecoration(
                labelText: 'Customer (optional)',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: [
                const DropdownMenuItem<CustomerModel?>(
                  value: null,
                  child: Text('Walk-in Customer'),
                ),
                ...customers.map(
                  (c) => DropdownMenuItem(value: c, child: Text(c.name)),
                ),
              ],
              onChanged: (value) => setState(() => _selectedCustomer = value),
            ),
          ),

          const SizedBox(height: 12),

          // Cart list
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Text('Cart is empty. Search or scan a product.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item.productName),
                          subtitle: Text(
                            '${_currency.format(item.sellingPrice)} × ${item.quantity} = ${_currency.format(item.total)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => cartNotifier
                                    .decrementQuantity(item.productId),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => cartNotifier
                                    .incrementQuantity(item.productId),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Summary + checkout
          if (cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryRow(label: 'Subtotal', value: _currency.format(subtotal)),
                  _SummaryRow(label: 'GST', value: _currency.format(gst)),
                  Row(
                    children: [
                      const Expanded(child: Text('Discount')),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            prefixText: AppConstants.defaultCurrency,
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Grand Total',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        _currency.format(grandTotal),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Payment method chips
                  Wrap(
                    spacing: 8,
                    children: AppConstants.paymentMethods.map((method) {
                      final selected = _paymentMethod == method;
                      return ChoiceChip(
                        label: Text(method),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _paymentMethod = method),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _checkout(
                        context,
                        cart,
                        subtotal,
                        gst,
                        discount,
                        grandTotal,
                      ),
                      child: const Text('Complete Payment'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showSearchResults(
    BuildContext context,
    List results,
    dynamic cartNotifier,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: results.map((product) {
          return ListTile(
            title: Text(product.name),
            subtitle: Text(_currency.format(product.sellingPrice)),
            onTap: () {
              cartNotifier.addProduct(product);
              _searchController.clear();
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _checkout(
    BuildContext context,
    List<CartItemModel> cart,
    double subtotal,
    double gst,
    double discount,
    double grandTotal,
  ) async {
    final invoiceNotifier = ref.read(invoiceProvider.notifier);
    final productNotifier = ref.read(productProvider.notifier);
    final cartNotifier = ref.read(cartProvider.notifier);

    final invoiceNumber =
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final invoice = InvoiceModel(
      invoiceNumber: invoiceNumber,
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name,
      items: cart,
      subtotal: subtotal,
      gstAmount: gst,
      discount: discount,
      grandTotal: grandTotal,
      paymentMethod: _paymentMethod,
    );

    await invoiceNotifier.addInvoice(invoice);

    for (final item in cart) {
      await productNotifier.reduceStock(item.productId, item.quantity);
    }

    cartNotifier.clearCart();
    _discountController.text = '0';

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text(
          'Invoice: $invoiceNumber\nAmount: ${_currency.format(grandTotal)}\nMethod: $_paymentMethod',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/dashboard');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value),
        ],
      ),
    );
  }
}
