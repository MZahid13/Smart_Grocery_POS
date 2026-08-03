import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addProduct(ProductModel product) {
    final index = state.indexWhere((item) => item.productId == product.id);

    if (index != -1) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + 1,
      );
      state = updated;
    } else {
      state = [
        ...state,
        CartItemModel(
          productId: product.id!,
          productName: product.name,
          sellingPrice: product.sellingPrice,
          gstPercent: product.gstPercent,
          quantity: 1,
        ),
      ];
    }
  }

  void incrementQuantity(int productId) {
    state = state
        .map((item) => item.productId == productId
            ? item.copyWith(quantity: item.quantity + 1)
            : item)
        .toList();
  }

  void decrementQuantity(int productId) {
    final index = state.indexWhere((item) => item.productId == productId);
    if (index == -1) return;

    if (state[index].quantity <= 1) {
      removeItem(productId);
    } else {
      final updated = [...state];
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity - 1,
      );
      state = updated;
    }
  }

  void removeItem(int productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void clearCart() {
    state = [];
  }

  double get subtotal =>
      state.fold(0.0, (sum, item) => sum + item.subtotal);

  double get totalGst =>
      state.fold(0.0, (sum, item) => sum + item.gstAmount);

  double grandTotal({double discount = 0.0}) =>
      subtotal + totalGst - discount;

  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItemModel>>(
  (ref) => CartNotifier(),
);
