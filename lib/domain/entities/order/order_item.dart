// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class OrderItemModel {
  final int? id;
  final int? saleOrderId;
  final String? productCode;
  final String? productName;
  final String? unitCode;
  final String? unitName;
  final int quantity;
  final num? priceNoVAT;
  final num? vat;
  final num? priceWithVAT;
  final num? total;
  final bool? isPromotion;
  OrderItemModel({
    this.id,
    this.saleOrderId,
    this.productCode,
    this.productName,
    this.unitCode,
    this.unitName,
    required this.quantity,
    this.priceNoVAT,
    this.vat,
    this.priceWithVAT,
    this.total,
    this.isPromotion,
  });

  OrderItemModel copyWith({
    int? id,
    int? saleOrderId,
    String? productCode,
    String? productName,
    String? unitCode,
    String? unitName,
    int? quantity,
    num? priceNoVAT,
    num? vat,
    num? priceWithVAT,
    num? total,
    bool? isPromotion,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      saleOrderId: saleOrderId ?? this.saleOrderId,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      unitCode: unitCode ?? this.unitCode,
      unitName: unitName ?? this.unitName,
      quantity: quantity ?? this.quantity,
      priceNoVAT: priceNoVAT ?? this.priceNoVAT,
      vat: vat ?? this.vat,
      priceWithVAT: priceWithVAT ?? this.priceWithVAT,
      total: total ?? this.total,
      isPromotion: isPromotion ?? this.isPromotion,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'saleOrderId': saleOrderId,
      'productCode': productCode,
      'productName': productName,
      'unitCode': unitCode,
      'unitName': unitName,
      'quantity': quantity,
      'priceNoVAT': priceNoVAT,
      'vat': vat,
      'priceWithVAT': priceWithVAT,
      'total': total,
      'isPromotion': isPromotion,
    };
  }

  Map<String, dynamic> toCreateRequest() {
    return <String, dynamic>{
      'productCode': productCode,
      'unitCode': unitCode,
      'quantity': quantity,
      'priceNoVAT': priceNoVAT,
      'vat': vat,
      'priceWithVAT': priceWithVAT,
      'total': total,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as int,
      saleOrderId: map['saleOrderId'] as int,
      productCode: map['productCode'] != null ? map['productCode'] as String : null,
      productName: map['productName'] != null ? map['productName'] as String : null,
      unitCode: map['unitCode'] != null ? map['unitCode'] as String : null,
      unitName: map['unitName'] != null ? map['unitName'] as String : null,
      quantity: map['quantity'] as int,
      priceNoVAT: map['priceNoVAT'] != null ? map['priceNoVAT'] as num : null,
      vat: map['vat'] != null ? map['vat'] as num : null,
      priceWithVAT: map['priceWithVAT'] != null ? map['priceWithVAT'] as num : null,
      total: map['total'] != null ? map['total'] as num : null,
      isPromotion: map['isPromotion'] != null ? map['isPromotion'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItemModel.fromJson(String source) => OrderItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderItemModel(id: $id, saleOrderId: $saleOrderId, productCode: $productCode, productName: $productName, unitCode: $unitCode, unitName: $unitName, quantity: $quantity, priceNoVAT: $priceNoVAT, vat: $vat, priceWithVAT: $priceWithVAT, total: $total, isPromotion: $isPromotion)';
  }

  @override
  bool operator ==(covariant OrderItemModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.saleOrderId == saleOrderId &&
      other.productCode == productCode &&
      other.productName == productName &&
      other.unitCode == unitCode &&
      other.unitName == unitName &&
      other.quantity == quantity &&
      other.priceNoVAT == priceNoVAT &&
      other.vat == vat &&
      other.priceWithVAT == priceWithVAT &&
      other.total == total &&
      other.isPromotion == isPromotion;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      saleOrderId.hashCode ^
      productCode.hashCode ^
      productName.hashCode ^
      unitCode.hashCode ^
      unitName.hashCode ^
      quantity.hashCode ^
      priceNoVAT.hashCode ^
      vat.hashCode ^
      priceWithVAT.hashCode ^
      total.hashCode ^
      isPromotion.hashCode;
  }
} 
