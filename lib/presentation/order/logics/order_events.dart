import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/presentation/order/enum.dart';


abstract class OrderEvent {}

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
class InitOrderEvent extends OrderEvent {}

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

// Pagination events
class LoadMoreOrdersEvent extends OrderEvent {}

class RefreshOrdersEvent extends OrderEvent {}

class GetOrderDetailEvent extends OrderEvent {
  final String orderId;
  GetOrderDetailEvent(this.orderId);
}

class FilterOrdersByMultipleCriteriaEvent extends OrderEvent {
  final String? areaSaleCode;
  final String? routeSaleCode;
  final String? saleUserCode;
  final int? dateType; // 1: Theo ngày tạo, 2: Theo ngày duyệt
  final DateTime? fromDate;
  final DateTime? toDate;

  FilterOrdersByMultipleCriteriaEvent({
    this.areaSaleCode,
    this.routeSaleCode,
    this.saleUserCode,
    this.dateType,
    this.fromDate,
    this.toDate,
  });
}
