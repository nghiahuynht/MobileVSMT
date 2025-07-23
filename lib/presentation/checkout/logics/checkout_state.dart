part of './checkout_cubit.dart';

class CheckoutState extends Equatable {
  final Arrear? arrearSelected;
  final PaymentType? paymentTypeSelected;

  const CheckoutState({
    this.arrearSelected,
    this.paymentTypeSelected,
  });

  @override
  List<Object?> get props => [arrearSelected, paymentTypeSelected];

  CheckoutState copyWith({
    Arrear? arrearSelected,
    PaymentType? paymentTypeSelected,
  }) {
    return CheckoutState(
      arrearSelected: arrearSelected ?? this.arrearSelected,
      paymentTypeSelected: paymentTypeSelected ?? this.paymentTypeSelected,
    );
  }
}
