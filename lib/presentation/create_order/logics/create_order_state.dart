// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../../domain/entities/customer/customer.dart';
import '../../../domain/entities/order/order.dart';
import '../../../domain/entities/product/product.dart';

abstract class CreateOrderState {}

class CreateOrderInitial extends CreateOrderState {}

class CreateOrderLoading extends CreateOrderState {}

class CreateOrderLoaded extends CreateOrderState {
  final List<ProductOrderItemWrapper> products;
  final CustomerModel? selectedCustomer;
  final bool isSubmitting;
  final bool isSlaughter;

  /// Đơn giá một dòng: slaughter dùng [ProductModel.priceSale], còn lại dùng [CustomerModel.currentPrice].
  num lineUnitPrice(ProductOrderItemWrapper prod) {
    if (isSlaughter) {
      return prod.item.priceSale ?? 0;
    }
    return selectedCustomer?.currentPrice ?? 0;
  }

  double get subtotal => products.fold<double>(
        0,
        (double sum, ProductOrderItemWrapper prod) =>
            sum +
            (prod.quantity > 0
                ? (lineUnitPrice(prod) * prod.quantity).toDouble()
                : 0),
      );

  double get total => subtotal;

  bool get isSelected => products.any((ProductOrderItemWrapper e) => e.isSelected);

  int get totalUnitCount =>
      products.fold<int>(0, (int sum, ProductOrderItemWrapper e) => sum + e.quantity);

  CreateOrderLoaded({
    required this.products,
    this.selectedCustomer,
    this.isSubmitting = false,
    this.isSlaughter = false,
  });
}

class CreateOrderSuccess extends CreateOrderState {
  final OrderModel order;
  CreateOrderSuccess(this.order);
}

class CreateOrderError extends CreateOrderState {
  final String message;
  CreateOrderError(this.message);
}

class ProductOrderItemWrapper {
  final ProductModel item;
  final int quantity;
  ProductOrderItemWrapper({required this.item, required this.quantity});

  ProductOrderItemWrapper copyWith({
    int? quantity,
  }) {
    return ProductOrderItemWrapper(
      item: item,
      quantity: quantity ?? this.quantity,
    );
  }

  bool get isSelected => quantity > 0;
}
