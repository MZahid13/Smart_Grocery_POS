import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/report_analytics.dart';
import '../../core/utils/report_exporter.dart';
import '../../data/providers/invoice_provider.dart';
import '../../data/providers/product_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoiceProvider);
    final products = ref.watch(productProvider);

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.defaultCurrency,
      decimalDigits: 2,
    );

    final salesByDay = ReportAnalytics.salesByDay(invoices, days: 7);
    final bestSellers = ReportAnalytics.bestSellers(invoices);
    final totalSales = ReportAnalytics.totalSales(invoices);
    final totalGst = ReportAnalytics.totalGstCollected(invoices);
    final profit = ReportAnalytics.estimatedProfit(invoices, products);

    final maxSale = salesByDay.isEmpty
        ? 100.0
        : salesByDay.map((d) => d.total).fold(0.0, (a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF',
            onPressed: invoices.isEmpty
                ? null
                : () => _exportPdf(context, invoices, profit),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: 'Export Excel',
            onPressed:
                invoices.isEmpty ? null : () => _exportExcel(context, invoices),
          ),
        ],
      ),
      body: invoices.isEmpty
          ? const Center(child: Text('No sales data yet'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total Sales',
                        value: currency.format(totalSales),
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Total Orders',
                        value: '${invoices.length}',
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'GST Collected',
                        value: currency.format(totalGst),
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Est. Profit',
                        value: currency.format(profit),
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text(
                  'Last 7 Days Sales',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      maxY: maxSale == 0 ? 100 : maxSale * 1.2,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= salesByDay.length) {
                                return const SizedBox();
                              }
                              final day = salesByDay[index].date;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  DateFormat('E').format(day),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: salesByDay.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.total,
                              color: Theme.of(context).colorScheme.primary,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Best Selling Products',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                if (bestSellers.isEmpty)
                  const Text('No sales yet')
                else
                  ...bestSellers.map(
                    (p) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.trending_up, color: Colors.green),
                        title: Text(p.productName),
                        subtitle: Text('${p.quantitySold} units sold'),
                        trailing: Text(
                          currency.format(p.revenue),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    List invoices,
    double profit,
  ) async {
    final doc = await ReportExporter.buildPdfReport(
      invoices: invoices.cast(),
      estimatedProfit: profit,
    );
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'sales_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<void> _exportExcel(BuildContext context, List invoices) async {
    final bytes = ReportExporter.buildExcelReport(invoices.cast());
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/sales_report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
    await file.writeAsBytes(bytes);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel saved: ${file.path}')),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
