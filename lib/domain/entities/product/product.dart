class ProductModel {
  final String id;
  final String code; // Mã SP như THANG-1, THANG-2
  final String name;
  final double price;
  final String? description;
  final String? category;
  final String? unit; // đơn vị tính: kg, thùng, lít
  final bool isActive;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
    this.description,
    this.category,
    this.unit,
    this.isActive = true,
    required this.createdAt,
  });

  ProductModel copyWith({
    String? id,
    String? code,
    String? name,
    double? price,
    String? description,
    String? category,
    String? unit,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductModel{id: $id, code: $code, name: $name, price: $price}';
  }
} 