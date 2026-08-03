import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../models/customer_model.dart';

class CustomerNotifier extends StateNotifier<List<CustomerModel>> {
  CustomerNotifier() : super([]) {
    loadCustomers();
  }

  final _db = DBHelper.instance;

  Future<void> loadCustomers() async {
    final customers = await _db.getAllCustomers();
    state = customers;
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _db.insertCustomer(customer);
    await loadCustomers();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _db.updateCustomer(customer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(int id) async {
    await _db.deleteCustomer(id);
    await loadCustomers();
  }

  List<CustomerModel> search(String query) {
    if (query.isEmpty) return state;
    final q = query.toLowerCase();
    return state
        .where((c) =>
            c.name.toLowerCase().contains(q) || c.phoneNumber.contains(q))
        .toList();
  }
}

final customerProvider =
    StateNotifierProvider<CustomerNotifier, List<CustomerModel>>(
  (ref) => CustomerNotifier(),
);
