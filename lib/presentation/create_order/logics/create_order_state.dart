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
  final double subtotal;
  final bool isSubmitting;

  double get total => products.fold(0, (sum, prod) => 
    sum + (prod.isSelected ? (selectedCustomer?.currentPrice ?? 0) : 0));

  bool get isSelected => products.any((e) => e.isSelected);

  CreateOrderLoaded({
    required this.products,
    this.selectedCustomer,
    this.subtotal = 0,
    this.isSubmitting = false,
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
