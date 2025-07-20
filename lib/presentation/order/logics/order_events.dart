import '../../../domain/entities/product/product.dart';
import '../../../domain/entities/customer/customer.dart';
import '../../../domain/entities/order/order.dart';

abstract class OrderEvent {}

// Product related events
class LoadProductsEvent extends OrderEvent {}

class SearchProductsEvent extends OrderEvent {
  final String query;
  SearchProductsEvent(this.query);
}

// Cart management events
class AddToCartEvent extends OrderEvent {
  final ProductModel product;
  final int quantity;

  AddToCartEvent({
    required this.product,
    this.quantity = 1,
  });
}

class RemoveFromCartEvent extends OrderEvent {
  final String productId;
  RemoveFromCartEvent(this.productId);
}

class UpdateCartItemQuantityEvent extends OrderEvent {
  final String productId;
  final int quantity;

  UpdateCartItemQuantityEvent({
    required this.productId,
    required this.quantity,
  });
}

class ClearCartEvent extends OrderEvent {}

// Customer selection
class SelectCustomerEvent extends OrderEvent {
  final CustomerModel? customer;
  SelectCustomerEvent(this.customer);
}

// Order creation
class CreateOrderEvent extends OrderEvent {
  final String? notes;
  CreateOrderEvent({this.notes});
}

// Order management
class LoadOrdersEvent extends OrderEvent {}

class LoadOrderDetailEvent extends OrderEvent {
  final String orderId;
  LoadOrderDetailEvent(this.orderId);
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final String status;

  UpdateOrderStatusEvent({
    required this.orderId,
    required this.status,
  });
}

class CancelOrderEvent extends OrderEvent {
  final String orderId;
  CancelOrderEvent(this.orderId);
}

// Order list management
class SearchOrdersEvent extends OrderEvent {
  final String query;
  SearchOrdersEvent(this.query);
}

class FilterOrdersByStatusEvent extends OrderEvent {
  final OrderStatus? status;
  FilterOrdersByStatusEvent(this.status);
}

class ClearOrderFiltersEvent extends OrderEvent {} 