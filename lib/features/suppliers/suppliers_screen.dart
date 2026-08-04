import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/supplier_model.dart';
import '../../data/providers/supplier_provider.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierProvider);
    final notifier = ref.read(supplierProvider.notifier);

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.defaultCurrency,
      decimalDigits: 2,
    );

    final filtered =
        _searchQuery.isEmpty ? suppliers : notifier.search(_searchQuery);

    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or phone',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No suppliers found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final supplier = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              supplier.name.isNotEmpty
                                  ? supplier.name[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(supplier.name),
                          subtitle: Text(
                            '${supplier.phoneNumber}\n${supplier.address}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (supplier.outstandingPayment > 0)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    currency.format(supplier.outstandingPayment),
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () => _showForm(
                                  context,
                                  notifier,
                                  supplier: supplier,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 18, color: Colors.red),
                                onPressed: () =>
                                    _confirmDelete(context, notifier, supplier),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, notifier),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SupplierNotifier notifier,
    SupplierModel supplier,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Delete "${supplier.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteSupplier(supplier.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showForm(
    BuildContext context,
    SupplierNotifier notifier, {
    SupplierModel? supplier,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SupplierForm(notifier: notifier, supplier: supplier),
    );
  }
}

class _SupplierForm extends StatefulWidget {
  const _SupplierForm({required this.notifier, this.supplier});

  final SupplierNotifier notifier;
  final SupplierModel? supplier;

  @override
  State<_SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<_SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _outstandingController;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _nameController = TextEditingController(text: s?.name ?? '');
    _phoneController = TextEditingController(text: s?.phoneNumber ?? '');
    _addressController = TextEditingController(text: s?.address ?? '');
    _outstandingController =
        TextEditingController(text: s?.outstandingPayment.toString() ?? '0');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.supplier != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'Edit Supplier' : 'Add Supplier',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Supplier Name'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Phone is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Address is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _outstandingController,
                decoration: const InputDecoration(
                  labelText: 'Outstanding Payment',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEditing ? 'Update Supplier' : 'Add Supplier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final supplier = SupplierModel(
      id: widget.supplier?.id,
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      outstandingPayment: double.tryParse(_outstandingController.text) ?? 0,
    );

    if (widget.supplier != null) {
      widget.notifier.updateSupplier(supplier);
    } else {
      widget.notifier.addSupplier(supplier);
    }

    Navigator.pop(context);
  }
}
