class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Grocery POS';
  static const String dbName = 'smart_grocery_pos.db';
  static const int dbVersion = 1;

  static const String defaultCurrency = '₹';
  static const double defaultGstPercent = 5.0;

  static const List<String> defaultCategories = [
    'Dairy',
    'Beverages',
    'Snacks',
    'Fruits',
    'Vegetables',
    'Bakery',
    'Household Items',
    'Others',
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'UPI',
    'Card',
    'Mixed',
  ];

  static const int lowStockThreshold = 10;
}
