import '../product/product.dart';

class OrderItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final double unitPrice; // Giá tại thời điểm đặt hàng
  final double subtotal; // Thành tiền = quantity * unitPrice

  const OrderItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromProduct({
    required String id,
    required ProductModel product,
    required int quantity,
  }) {
    final unitPrice = product.price;
    final subtotal = quantity * unitPrice;
    
    return OrderItemModel(
      id: id,
      product: product,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
    );
  }

  OrderItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  OrderItemModel updateQuantity(int newQuantity) {
    return OrderItemModel(
      id: id,
      product: product,
      quantity: newQuantity,
      unitPrice: unitPrice,
      subtotal: newQuantity * unitPrice,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItemModel && 
           other.id == id && 
           other.product.id == product.id;
  }

  @override
  int get hashCode => id.hashCode ^ product.id.hashCode;

  @override
  String toString() {
    return 'OrderItemModel{id: $id, product: ${product.code}, quantity: $quantity, subtotal: $subtotal}';
  }
} 