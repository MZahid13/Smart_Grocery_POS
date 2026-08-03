class ProductModel {
  final int? id;
  final String name;
  final String barcode;
  final String category;
  final double purchasePrice;
  final double sellingPrice;
  final int quantity;
  final double gstPercent;
  final String? imagePath;
  final DateTime createdAt;

  ProductModel({
    this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.quantity,
    this.gstPercent = 5.0,
    this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isLowStock => quantity <= 10;
  bool get isOutOfStock => quantity <= 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'category': category,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'gstPercent': gstPercent,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      barcode: map['barcode'] as String,
      category: map['category'] as String,
      purchasePrice: (map['purchasePrice'] as num).toDouble(),
      sellingPrice: (map['sellingPrice'] as num).toDouble(),
      quantity: map['quantity'] as int,
      gstPercent: (map['gstPercent'] as num).toDouble(),
      imagePath: map['imagePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? barcode,
    String? category,
    double? purchasePrice,
    double? sellingPrice,
    int? quantity,
    double? gstPercent,
    String? imagePath,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      gstPercent: gstPercent ?? this.gstPercent,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt,
    );
  }
}
