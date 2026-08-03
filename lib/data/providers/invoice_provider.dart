import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../models/invoice_model.dart';

class InvoiceNotifier extends StateNotifier<List<InvoiceModel>> {
  InvoiceNotifier() : super([]) {
    loadInvoices();
  }

  final _db = DBHelper.instance;

  Future<void> loadInvoices() async {
    final invoices = await _db.getAllInvoices();
    state = invoices;
  }

  Future<void> addInvoice(InvoiceModel invoice) async {
    await _db.insertInvoice(invoice);
    await loadInvoices();
  }

  Future<void> deleteInvoice(int id) async {
    await _db.deleteInvoice(id);
    await loadInvoices();
  }

  List<InvoiceModel> get todayInvoices {
    final now = DateTime.now();
    return state.where((inv) =>
        inv.createdAt.year == now.year &&
        inv.createdAt.month == now.month &&
        inv.createdAt.day == now.day).toList();
  }

  double get todaySalesTotal =>
      todayInvoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);

  int get todayOrderCount => todayInvoices.length;

  List<InvoiceModel> get recentInvoices {
    final sorted = [...state]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }
}

final invoiceProvider =
    StateNotifierProvider<InvoiceNotifier, List<InvoiceModel>>(
  (ref) => InvoiceNotifier(),
);
