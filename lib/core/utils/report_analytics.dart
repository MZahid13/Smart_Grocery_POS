import '../../data/models/invoice_model.dart';
import '../../data/models/product_model.dart';

class DailySales {
  final DateTime date;
  final double total;
  DailySales(this.date, this.total);
}

class ProductSalesSummary {
  final String productName;
  final int quantitySold;
  final double revenue;
  ProductSalesSummary({
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });
}

class ReportAnalytics {
  ReportAnalytics._();

  /// Sales total grouped by day for the last [days] days (oldest to newest)
  static List<DailySales> salesByDay(
    List<InvoiceModel> invoices, {
    int days = 7,
  }) {
    final now = DateTime.now();
    final result = <DailySales>[];

    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final total = invoices
          .where((inv) =>
              inv.createdAt.year == day.year &&
              inv.createdAt.month == day.month &&
              inv.createdAt.day == day.day)
          .fold(0.0, (sum, inv) => sum + inv.grandTotal);
      result.add(DailySales(day, total));
    }
    return result;
  }

  static double totalSales(List<InvoiceModel> invoices) =>
      invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);

  static double totalGstCollected(List<InvoiceModel> invoices) =>
      invoices.fold(0.0, (sum, inv) => sum + inv.gstAmount);

  /// Aggregates quantity sold and revenue per product across all invoices
  static List<ProductSalesSummary> productSalesSummary(
    List<InvoiceModel> invoices,
  ) {
    final Map<String, ProductSalesSummary> map = {};

    for (final invoice in invoices) {
      for (final item in invoice.items) {
        final existing = map[item.productName];
        if (existing == null) {
          map[item.productName] = ProductSalesSummary(
            productName: item.productName,
            quantitySold: item.quantity,
            revenue: item.total,
          );
        } else {
          map[item.productName] = ProductSalesSummary(
            productName: item.productName,
            quantitySold: existing.quantitySold + item.quantity,
            revenue: existing.revenue + item.total,
          );
        }
      }
    }

    return map.values.toList();
  }

  static List<ProductSalesSummary> bestSellers(
    List<InvoiceModel> invoices, {
    int limit = 5,
  }) {
    final summary = productSalesSummary(invoices);
    summary.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
    return summary.take(limit).toList();
  }

  static List<ProductSalesSummary> leastSellers(
    List<InvoiceModel> invoices, {
    int limit = 5,
  }) {
    final summary = productSalesSummary(invoices);
    summary.sort((a, b) => a.quantitySold.compareTo(b.quantitySold));
    return summary.take(limit).toList();
  }

  /// Approximate profit: (sellingPrice - purchasePrice) x quantity sold,
  /// using current product purchase price as reference.
  static double estimatedProfit(
    List<InvoiceModel> invoices,
    List<ProductModel> products,
  ) {
    double profit = 0;
    final priceMap = {for (final p in products) p.name: p.purchasePrice};

    for (final invoice in invoices) {
      for (final item in invoice.items) {
        final purchasePrice = priceMap[item.productName] ?? 0;
        profit += (item.sellingPrice - purchasePrice) * item.quantity;
      }
    }
    return profit;
  }
}
