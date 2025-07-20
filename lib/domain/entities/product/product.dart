class ProductModel {
  final int id;
  final String? code;
  final String? name;
  final String? unitCode;
  final num? priceSale;
  final String? description;
  final bool? isActive;
  final num? vat;
  final num? priceBox;
  final String? unitCodeBox;
  final int? heSoQuyDoi;

  const ProductModel({
    required this.id,
    this.code,
    this.name,
    this.unitCode,
    this.priceSale,
    this.description,
    this.isActive,
    this.vat,
    this.priceBox,
    this.unitCodeBox,
    this.heSoQuyDoi,
  });

  ProductModel copyWith({
    int? id,
    String? code,
    String? name,
    String? unitCode,
    num? priceSale,
    String? description,
    bool? isActive,
    num? vat,
    num? priceBox,
    String? unitCodeBox,
    int? heSoQuyDoi,
  }) {
    return ProductModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      unitCode: unitCode ?? this.unitCode,
      priceSale: priceSale ?? this.priceSale,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      vat: vat ?? this.vat,
      priceBox: priceBox ?? this.priceBox,
      unitCodeBox: unitCodeBox ?? this.unitCodeBox,
      heSoQuyDoi: heSoQuyDoi ?? this.heSoQuyDoi,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      code: json['code'] as String?,
      name: json['name'] as String?,
      unitCode: json['unitCode'] as String?,
      priceSale: json['priceSale'] as num?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool?,
      vat: json['vat'] as num?,
      priceBox: json['priceBox'] as num?,
      unitCodeBox: json['unitCodeBox'] as String?,
      heSoQuyDoi: json['heSoQuyDoi'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'unitCode': unitCode,
      'priceSale': priceSale,
      'description': description,
      'isActive': isActive,
      'vat': vat,
      'priceBox': priceBox,
      'unitCodeBox': unitCodeBox,
      'heSoQuyDoi': heSoQuyDoi,
    };
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
    return 'ProductModel{id: $id, code: $code, name: $name, priceSale: $priceSale}';
  }
} 