import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../models/supplier_model.dart';

class SupplierNotifier extends StateNotifier<List<SupplierModel>> {
  SupplierNotifier() : super([]) {
    loadSuppliers();
  }

  final _db = DBHelper.instance;

  Future<void> loadSuppliers() async {
    final suppliers = await _db.getAllSuppliers();
    state = suppliers;
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    await _db.insertSupplier(supplier);
    await loadSuppliers();
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    await _db.updateSupplier(supplier);
    await loadSuppliers();
  }

  Future<void> deleteSupplier(int id) async {
    await _db.deleteSupplier(id);
    await loadSuppliers();
  }

  List<SupplierModel> search(String query) {
    if (query.isEmpty) return state;
    final q = query.toLowerCase();
    return state
        .where((s) =>
            s.name.toLowerCase().contains(q) || s.phoneNumber.contains(q))
        .toList();
  }
}

final supplierProvider =
    StateNotifierProvider<SupplierNotifier, List<SupplierModel>>(
  (ref) => SupplierNotifier(),
);
