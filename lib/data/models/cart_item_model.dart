class CartItemModel {
  final int productId;
  final String productName;
  final double sellingPrice;
  final double gstPercent;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.sellingPrice,
    required this.gstPercent,
    this.quantity = 1,
  });

  double get subtotal => sellingPrice * quantity;
  double get gstAmount => subtotal * (gstPercent / 100);
  double get total => subtotal + gstAmount;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'sellingPrice': sellingPrice,
      'gstPercent': gstPercent,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'] as int,
      productName: map['productName'] as String,
      sellingPrice: (map['sellingPrice'] as num).toDouble(),
      gstPercent: (map['gstPercent'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      productId: productId,
      productName: productName,
      sellingPrice: sellingPrice,
      gstPercent: gstPercent,
      quantity: quantity ?? this.quantity,
    );
  }
}
