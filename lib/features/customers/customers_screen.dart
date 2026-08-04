import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/customer_model.dart';
import '../../data/providers/customer_provider.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerProvider);
    final notifier = ref.read(customerProvider.notifier);

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.defaultCurrency,
      decimalDigits: 2,
    );

    final filtered =
        _searchQuery.isEmpty ? customers : notifier.search(_searchQuery);

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
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
                ? const Center(child: Text('No customers found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final customer = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              customer.name.isNotEmpty
                                  ? customer.name[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(customer.name),
                          subtitle: Text(
                            '${customer.phoneNumber} · ${customer.loyaltyPoints} pts',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (customer.creditBalance > 0)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    currency.format(customer.creditBalance),
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
                                  customer: customer,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 18, color: Colors.red),
                                onPressed: () =>
                                    _confirmDelete(context, notifier, customer),
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
    CustomerNotifier notifier,
    CustomerModel customer,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Delete "${customer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteCustomer(customer.id!);
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
    CustomerNotifier notifier, {
    CustomerModel? customer,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CustomerForm(notifier: notifier, customer: customer),
    );
  }
}

class _CustomerForm extends StatefulWidget {
  const _CustomerForm({required this.notifier, this.customer});

  final CustomerNotifier notifier;
  final CustomerModel? customer;

  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _creditController;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phoneNumber ?? '');
    _creditController =
        TextEditingController(text: c?.creditBalance.toString() ?? '0');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;

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
                isEditing ? 'Edit Customer' : 'Add Customer',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
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
                controller: _creditController,
                decoration: const InputDecoration(
                  labelText: 'Credit Balance (Udhar)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEditing ? 'Update Customer' : 'Add Customer'),
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

    final customer = CustomerModel(
      id: widget.customer?.id,
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      creditBalance: double.tryParse(_creditController.text) ?? 0,
      loyaltyPoints: widget.customer?.loyaltyPoints ?? 0,
    );

    if (widget.customer != null) {
      widget.notifier.updateCustomer(customer);
    } else {
      widget.notifier.addCustomer(customer);
    }

    Navigator.pop(context);
  }
}
