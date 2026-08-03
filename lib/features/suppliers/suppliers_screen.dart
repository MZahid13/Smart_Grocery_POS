import 'package:flutter/material.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      body: const Center(
        child: Text('Suppliers screen - baad ke step mein build hoga'),
      ),
    );
  }
}
