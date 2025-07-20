import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/entities/order/order.dart';
import '../../../domain/domain_manager.dart';
import 'order_detail_events.dart';
import 'order_detail_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final DomainManager _domainManager = DomainManager();

  OrderDetailBloc(OrderModel order) : super(OrderDetailInitial(order)) {
    on<LoadOrderDetailEvent>(_onLoadOrderDetail);
  }

  Future<void> _onLoadOrderDetail(
    LoadOrderDetailEvent event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(state.getLoading());

    try {
      final order = await _domainManager.order.getOrderById(state.order.id);

      emit(state.getLoaded(order));
    } catch (e) {
      emit(state.getError('Lỗi khi tải thông tin đơn hàng: $e'));
    }
  }
}
