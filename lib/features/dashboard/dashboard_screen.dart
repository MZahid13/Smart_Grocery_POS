import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../data/providers/product_provider.dart';
import '../../data/providers/invoice_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productProvider);
    ref.watch(invoiceProvider);
    final invoiceNotifier = ref.read(invoiceProvider.notifier);
    final productNotifier = ref.read(productProvider.notifier);

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.defaultCurrency,
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await productNotifier.loadProducts();
          await invoiceNotifier.loadInvoices();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: "Today's Sales",
                    value: currency.format(invoiceNotifier.todaySalesTotal),
                    icon: Icons.currency_rupee,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: "Today's Orders",
                    value: '${invoiceNotifier.todayOrderCount}',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Products',
                    value: '${products.length}',
                    icon: Icons.inventory_2,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Low Stock',
                    value: '${productNotifier.lowStockProducts.length}',
                    icon: Icons.warning_amber,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    label: 'New Bill',
                    icon: Icons.point_of_sale,
                    onTap: () => context.go('/billing'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    label: 'Add Product',
                    icon: Icons.add_box,
                    onTap: () => context.go('/products'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    label: 'Reports',
                    icon: Icons.bar_chart,
                    onTap: () => context.go('/reports'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (productNotifier.lowStockProducts.isNotEmpty) ...[
              const Text(
                'Low Stock Alerts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...productNotifier.lowStockProducts.take(5).map(
                (product) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      product.isOutOfStock
                          ? Icons.remove_shopping_cart
                          : Icons.warning_amber,
                      color: product.isOutOfStock ? Colors.red : Colors.orange,
                    ),
                    title: Text(product.name),
                    subtitle: Text('Stock: ${product.quantity}'),
                    trailing: Text(currency.format(product.sellingPrice)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (invoiceNotifier.recentInvoices.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No transactions yet')),
              )
            else
              ...invoiceNotifier.recentInvoices.map(
                (invoice) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.receipt),
                    title: Text(invoice.invoiceNumber),
                    subtitle: Text(
                      invoice.customerName ?? 'Walk-in Customer',
                    ),
                    trailing: Text(
                      currency.format(invoice.grandTotal),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
