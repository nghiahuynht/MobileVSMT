import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/meta_data/arrear.dart';
import 'package:trash_pay/domain/entities/meta_data/payment_type.dart';
import 'package:trash_pay/domain/entities/order/order.dart';
import 'package:trash_pay/services/receipt_printer_service.dart';

part './checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final DomainManager _domainManager = DomainManager();
  CheckoutCubit() : super(const CheckoutState());

  void selectArrear(Arrear arrear) {
    emit(state.copyWith(arrearSelected: arrear));
  }

  void selectPaymentType(PaymentType paymentType) {
    emit(state.copyWith(paymentTypeSelected: paymentType));
  }

  void createOrder(Map<String, dynamic> orderData) async {
    emit(state.copyWith(isLoading: true));
    try {
      final isSuccess = await _domainManager.order.createOrder(orderData);
      if (isSuccess) {
        emit(state.copyWith(isSuccess: true));
      } else {
        emit(state.copyWith(isSuccess: false));
      }
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      emit(state.copyWith(isSuccess: false));
    }
  }

  void printReceipt(OrderModel order) async {
    emit(state.copyWith(isLoading: true));
    try {
      final isSuccess = await ReceiptPrinterService().printReceipt(order);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
