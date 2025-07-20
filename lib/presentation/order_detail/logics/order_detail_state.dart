import 'package:equatable/equatable.dart';
import '../../../domain/entities/order/order.dart';

abstract class OrderDetailState extends Equatable {
  final OrderModel order;

  const OrderDetailState(this.order);

  OrderDetailLoading getLoading() => OrderDetailLoading(order);
  OrderDetailError getError(String message) => OrderDetailError(order, message: message);
  OrderDetailLoaded getLoaded(OrderModel order) => OrderDetailLoaded(order);

  @override
  List<Object?> get props => [order];
}

class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial(super.order);
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading(super.order);
}

class OrderDetailLoaded extends OrderDetailState {
  const OrderDetailLoaded(super.order);
}

class OrderDetailError extends OrderDetailState {
  final String message;

  const OrderDetailError(super.order, {required this.message});

  @override
  List<Object?> get props => [message];
}
