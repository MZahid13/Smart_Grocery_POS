import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../models/product_model.dart';

class ProductNotifier extends StateNotifier<List<ProductModel>> {
  ProductNotifier() : super([]) {
    loadProducts();
  }

  final _db = DBHelper.instance;

  Future<void> loadProducts() async {
    final products = await _db.getAllProducts();
    state = products;
  }

  Future<void> addProduct(ProductModel product) async {
    await _db.insertProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _db.deleteProduct(id);
    await loadProducts();
  }

  Future<ProductModel?> findByBarcode(String barcode) async {
    return _db.getProductByBarcode(barcode);
  }

  Future<void> reduceStock(int productId, int soldQty) async {
    final product = state.firstWhere((p) => p.id == productId);
    final newQty = product.quantity - soldQty;
    await _db.updateProductStock(productId, newQty);
    await loadProducts();
  }

  List<ProductModel> search(String query) {
    if (query.isEmpty) return state;
    final q = query.toLowerCase();
    return state
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.barcode.contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  List<ProductModel> get lowStockProducts =>
      state.where((p) => p.isLowStock).toList();

  List<ProductModel> get outOfStockProducts =>
      state.where((p) => p.isOutOfStock).toList();
}

final productProvider =
    StateNotifierProvider<ProductNotifier, List<ProductModel>>(
  (ref) => ProductNotifier(),
);
