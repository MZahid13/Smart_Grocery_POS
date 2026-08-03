import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/product_model.dart';
import '../models/customer_model.dart';
import '../models/supplier_model.dart';
import '../models/invoice_model.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_grocery_pos.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        barcode TEXT NOT NULL,
        category TEXT NOT NULL,
        purchasePrice REAL NOT NULL,
        sellingPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        gstPercent REAL NOT NULL,
        imagePath TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        creditBalance REAL NOT NULL DEFAULT 0,
        loyaltyPoints INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        address TEXT NOT NULL,
        outstandingPayment REAL NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceNumber TEXT NOT NULL,
        customerId INTEGER,
        customerName TEXT,
        items TEXT NOT NULL,
        subtotal REAL NOT NULL,
        gstAmount REAL NOT NULL,
        discount REAL NOT NULL DEFAULT 0,
        grandTotal REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // ---------------- PRODUCT CRUD ----------------

  Future<int> insertProduct(ProductModel product) async {
    final db = await database;
    return db.insert('products', product.toMap()..remove('id'));
  }

  Future<List<ProductModel>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'name ASC');
    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return ProductModel.fromMap(result.first);
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'name LIKE ? OR barcode LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateProductStock(int productId, int newQuantity) async {
    final db = await database;
    return db.update(
      'products',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // ---------------- CUSTOMER CRUD ----------------

  Future<int> insertCustomer(CustomerModel customer) async {
    final db = await database;
    return db.insert('customers', customer.toMap()..remove('id'));
  }

  Future<List<CustomerModel>> getAllCustomers() async {
    final db = await database;
    final result = await db.query('customers', orderBy: 'name ASC');
    return result.map((e) => CustomerModel.fromMap(e)).toList();
  }

  Future<int> updateCustomer(CustomerModel customer) async {
    final db = await database;
    return db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- SUPPLIER CRUD ----------------

  Future<int> insertSupplier(SupplierModel supplier) async {
    final db = await database;
    return db.insert('suppliers', supplier.toMap()..remove('id'));
  }

  Future<List<SupplierModel>> getAllSuppliers() async {
    final db = await database;
    final result = await db.query('suppliers', orderBy: 'name ASC');
    return result.map((e) => SupplierModel.fromMap(e)).toList();
  }

  Future<int> updateSupplier(SupplierModel supplier) async {
    final db = await database;
    return db.update(
      'suppliers',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> deleteSupplier(int id) async {
    final db = await database;
    return db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- INVOICE CRUD ----------------

  Future<int> insertInvoice(InvoiceModel invoice) async {
    final db = await database;
    return db.insert('invoices', invoice.toMap()..remove('id'));
  }

  Future<List<InvoiceModel>> getAllInvoices() async {
    final db = await database;
    final result = await db.query('invoices', orderBy: 'createdAt DESC');
    return result.map((e) => InvoiceModel.fromMap(e)).toList();
  }

  Future<List<InvoiceModel>> getInvoicesBetween(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      'invoices',
      where: 'createdAt BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'createdAt DESC',
    );
    return result.map((e) => InvoiceModel.fromMap(e)).toList();
  }

  Future<int> deleteInvoice(int id) async {
    final db = await database;
    return db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }
}
