import 'package:equatable/equatable.dart';

abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderDetailEvent extends OrderDetailEvent {
  const LoadOrderDetailEvent();
}
