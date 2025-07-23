import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/entities/meta_data/arrear.dart';
import 'package:trash_pay/domain/entities/meta_data/payment_type.dart';

part './checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(const CheckoutState());

  void selectArrear(Arrear arrear) {
    emit(state.copyWith(arrearSelected: arrear));
  }

  void selectPaymentType(PaymentType paymentType) {
    emit(state.copyWith(paymentTypeSelected: paymentType));
  }
}
