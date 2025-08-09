import 'package:equatable/equatable.dart';
import 'package:trash_pay/domain/entities/order/order.dart';

abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderDetailEvent extends OrderDetailEvent {
  const LoadOrderDetailEvent();
}

class CancelOrderEvent extends OrderDetailEvent {
  final OrderModel order;

  const CancelOrderEvent(this.order);
}