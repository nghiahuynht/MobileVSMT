
part of './add_customer_cubit.dart';

class AddCustomerState extends Equatable {

  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final CustomerModel? customer;
  final List<Province> provinces;
  final List<Area> areas;
  const AddCustomerState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.customer,
    this.provinces = const [],
    this.areas = const [],
  });

  @override
  List<Object?> get props => [isLoading, isSuccess, isError, customer, provinces, areas];
  

  AddCustomerState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    CustomerModel? customer,
    List<Province>? provinces,
    List<Area>? areas,
  }) {
    return AddCustomerState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      customer: customer ?? this.customer,
      provinces: provinces ?? this.provinces,
      areas: areas ?? this.areas,
    );
  }
}
