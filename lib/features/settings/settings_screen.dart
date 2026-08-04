import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _gstController;
  late final TextEditingController _phoneController;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    if (!_initialized) {
      _nameController = TextEditingController(text: settings.shopName);
      _addressController = TextEditingController(text: settings.shopAddress);
      _gstController = TextEditingController(text: settings.gstNumber);
      _phoneController = TextEditingController(text: settings.phone);
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Shop Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Shop Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Shop Address'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _gstController,
                    decoration: const InputDecoration(labelText: 'GST Number'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await settingsNotifier.updateSettings(
                          ShopSettings(
                            shopName: _nameController.text.trim(),
                            shopAddress: _addressController.text.trim(),
                            gstNumber: _gstController.text.trim(),
                            phone: _phoneController.text.trim(),
                          ),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Shop details saved')),
                        );
                      },
                      child: const Text('Save Shop Details'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle light/dark theme'),
              value: themeMode == ThemeMode.dark,
              onChanged: (_) => themeNotifier.toggle(),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Data Backup',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('Backup Database'),
              subtitle: const Text('Save a copy of your store data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _backupDatabase(context),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'About',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(AppConstants.appName),
              subtitle: const Text('Version 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _backupDatabase(BuildContext context) async {
    try {
      final dbPath = await getDatabasesPath();
      final sourceFile = File(p.join(dbPath, AppConstants.dbName));

      if (!await sourceFile.exists()) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No database found to back up')),
        );
        return;
      }

      final backupDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File(
        p.join(backupDir.path, 'pos_backup_$timestamp.db'),
      );

      await sourceFile.copy(backupFile.path);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup saved: ${backupFile.path}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
    }
  }
}
