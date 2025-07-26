part of './checkout_cubit.dart';

class CheckoutState extends Equatable {
  final Arrear? arrearSelected;
  final PaymentType? paymentTypeSelected;
  final bool isLoading;
  final bool isSuccess;
  final bool isError;

  const CheckoutState({
    this.arrearSelected,
    this.paymentTypeSelected,
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
  });

  @override
  List<Object?> get props => [arrearSelected, paymentTypeSelected, isLoading, isSuccess, isError];

  CheckoutState copyWith({
    Arrear? arrearSelected,
    PaymentType? paymentTypeSelected,
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
  }) {
    return CheckoutState(
      arrearSelected: arrearSelected ?? this.arrearSelected,
      paymentTypeSelected: paymentTypeSelected ?? this.paymentTypeSelected,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
    );
  }
}
