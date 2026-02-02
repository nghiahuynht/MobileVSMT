class OrderHistoryItemModel {
  final int? id;
  final String? code;
  final DateTime? orderDate;
  final String? orderStatus;
  final String? orderStatusName;
  final DateTime? approveDate;
  final double? totalNoVAT;
  final double? totalVAT;
  final double? totalWithVAT;
  final String? products;

  const OrderHistoryItemModel({
    this.id,
    this.code,
    this.orderDate,
    this.orderStatus,
    this.orderStatusName,
    this.approveDate,
    this.totalNoVAT,
    this.totalVAT,
    this.totalWithVAT,
    this.products,
  });


  OrderHistoryItemModel copyWith({
    int? id,
    String? code,
    DateTime? orderDate,
    String? orderStatus,
    String? orderStatusName,
    DateTime? approveDate,
    double? totalNoVAT,
    double? totalVAT,
    double? totalWithVAT,
    String? products,
  }) {
    return OrderHistoryItemModel(
      id: id ?? this.id,
      code: code ?? this.code,
      orderDate: orderDate ?? this.orderDate,
      orderStatus: orderStatus ?? this.orderStatus,
      orderStatusName: orderStatusName ?? this.orderStatusName,
      approveDate: approveDate ?? this.approveDate,
      totalNoVAT: totalNoVAT ?? this.totalNoVAT,
      totalVAT: totalVAT ?? this.totalVAT,
      totalWithVAT: totalWithVAT ?? this.totalWithVAT,
      products: products ?? this.products,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'orderDate': orderDate?.millisecondsSinceEpoch,
      'orderStatus': orderStatus,
      'orderStatusName': orderStatusName,
      'approveDate': approveDate?.millisecondsSinceEpoch,
      'totalNoVAT': totalNoVAT,
      'totalVAT': totalVAT,
      'totalWithVAT': totalWithVAT,
      'products': products,
    };
  }

  factory OrderHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryItemModel(
      id: json['id'] as int?,
      code: json['code'] as String?,
      orderDate: json['orderDate'] != null
          ? (json['orderDate'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['orderDate'] as int)
              : DateTime.tryParse(json['orderDate'] as String))
          : null,
      orderStatus: json['orderStatus'] as String?,
      orderStatusName: json['orderStatusName'] as String?,
      approveDate: json['approveDate'] != null
          ? (json['approveDate'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['approveDate'] as int)
              : DateTime.tryParse(json['approveDate'] as String))
          : null,
      totalNoVAT: (json['totalNoVAT'] as num?)?.toDouble(),
      totalVAT: (json['totalVAT'] as num?)?.toDouble(),
      totalWithVAT: (json['totalWithVAT'] as num?)?.toDouble(),
      products: json['products'] as String?,
    );
  }

  factory OrderHistoryItemModel.fromMap(Map<String, dynamic> map) {
    return OrderHistoryItemModel.fromJson(map);
  }

  @override
  String toString() {
    return '''OrderHistoryItemModel(id: $id, code: $code, orderDate: $orderDate, orderStatus: $orderStatus, orderStatusName: $orderStatusName, approveDate: $approveDate, totalNoVAT: $totalNoVAT, totalVAT: $totalVAT, totalWithVAT: $totalWithVAT, products: $products)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is OrderHistoryItemModel &&
      other.id == id &&
      other.code == code &&
      other.orderDate == orderDate &&
      other.orderStatus == orderStatus &&
      other.orderStatusName == orderStatusName &&
      other.approveDate == approveDate &&
      other.totalNoVAT == totalNoVAT &&
      other.totalVAT == totalVAT &&
      other.totalWithVAT == totalWithVAT &&
      other.products == products;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      code.hashCode ^
      orderDate.hashCode ^
      orderStatus.hashCode ^
      orderStatusName.hashCode ^
      approveDate.hashCode ^
      totalNoVAT.hashCode ^
      totalVAT.hashCode ^
      totalWithVAT.hashCode ^
      products.hashCode;
  }
}
