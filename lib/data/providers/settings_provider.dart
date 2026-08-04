import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopSettings {
  final String shopName;
  final String shopAddress;
  final String gstNumber;
  final String phone;

  const ShopSettings({
    this.shopName = 'Your Shop Name',
    this.shopAddress = 'Shop Address, City, State - Pincode',
    this.gstNumber = 'GSTIN0000000000',
    this.phone = '+91 00000 00000',
  });

  ShopSettings copyWith({
    String? shopName,
    String? shopAddress,
    String? gstNumber,
    String? phone,
  }) {
    return ShopSettings(
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      gstNumber: gstNumber ?? this.gstNumber,
      phone: phone ?? this.phone,
    );
  }
}

class SettingsNotifier extends StateNotifier<ShopSettings> {
  SettingsNotifier() : super(const ShopSettings()) {
    _load();
  }

  static const _keyName = 'shop_name';
  static const _keyAddress = 'shop_address';
  static const _keyGst = 'shop_gst';
  static const _keyPhone = 'shop_phone';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = ShopSettings(
      shopName: prefs.getString(_keyName) ?? state.shopName,
      shopAddress: prefs.getString(_keyAddress) ?? state.shopAddress,
      gstNumber: prefs.getString(_keyGst) ?? state.gstNumber,
      phone: prefs.getString(_keyPhone) ?? state.phone,
    );
  }

  Future<void> updateSettings(ShopSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, settings.shopName);
    await prefs.setString(_keyAddress, settings.shopAddress);
    await prefs.setString(_keyGst, settings.gstNumber);
    await prefs.setString(_keyPhone, settings.phone);
    state = settings;
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, ShopSettings>(
  (ref) => SettingsNotifier(),
);
