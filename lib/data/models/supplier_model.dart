class SupplierModel {
  final int? id;
  final String name;
  final String phoneNumber;
  final String address;
  final double outstandingPayment;
  final DateTime createdAt;

  SupplierModel({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    this.outstandingPayment = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'outstandingPayment': outstandingPayment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      address: map['address'] as String,
      outstandingPayment: (map['outstandingPayment'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  SupplierModel copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? address,
    double? outstandingPayment,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      outstandingPayment: outstandingPayment ?? this.outstandingPayment,
      createdAt: createdAt,
    );
  }
}
