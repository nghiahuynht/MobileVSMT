import 'order_item.dart';
import '../customer/customer.dart';

enum OrderStatus {
  draft,      // Đang soạn thảo
  pending,    // Chờ xác nhận
  confirmed,  // Đã xác nhận
  processing, // Đang xử lý
  completed,  // Hoàn thành
  cancelled,  // Đã hủy
}

class OrderModel {
  final String id;
  final String orderNumber; // Số đơn hàng
  final CustomerModel? customer; // Khách hàng (có thể null cho đơn lẻ)
  final List<OrderItemModel> items;
  final double subtotal;   // Tổng tiền hàng
  final double discount;   // Giảm giá
  final double tax;        // Thuế
  final double total;      // Tổng thanh toán
  final OrderStatus status;
  final String? notes;     // Ghi chú
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;  // Người tạo đơn

  const OrderModel({
    required this.id,
    required this.orderNumber,
    this.customer,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
  });

  factory OrderModel.createNew({
    required String id,
    required String orderNumber,
    CustomerModel? customer,
    List<OrderItemModel> items = const [],
    String? notes,
    required String createdBy,
  }) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    const discount = 0.0;
    const tax = 0.0;
    final total = subtotal - discount + tax;

    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      customer: customer,
      items: items,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      status: OrderStatus.draft,
      notes: notes,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    CustomerModel? customer,
    List<OrderItemModel>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    OrderStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
    );
  }

  OrderModel updateItems(List<OrderItemModel> newItems) {
    final newSubtotal = newItems.fold<double>(0, (sum, item) => sum + item.subtotal);
    final newTotal = newSubtotal - discount + tax;

    return copyWith(
      items: newItems,
      subtotal: newSubtotal,
      total: newTotal,
      updatedAt: DateTime.now(),
    );
  }

  String get statusDisplayName {
    switch (status) {
      case OrderStatus.draft:
        return 'Đang soạn thảo';
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderModel{id: $id, orderNumber: $orderNumber, total: $total, status: $status}';
  }
} 