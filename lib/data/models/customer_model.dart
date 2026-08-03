class CustomerModel {
  final int? id;
  final String name;
  final String phoneNumber;
  final double creditBalance;
  final int loyaltyPoints;
  final DateTime createdAt;

  CustomerModel({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.creditBalance = 0.0,
    this.loyaltyPoints = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'creditBalance': creditBalance,
      'loyaltyPoints': loyaltyPoints,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      creditBalance: (map['creditBalance'] as num).toDouble(),
      loyaltyPoints: map['loyaltyPoints'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  CustomerModel copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    double? creditBalance,
    int? loyaltyPoints,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      creditBalance: creditBalance ?? this.creditBalance,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      createdAt: createdAt,
    );
  }
}
