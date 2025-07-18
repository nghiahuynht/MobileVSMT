import 'package:trash_pay/domain/entities/customer/customer.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomersLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final List<CustomerModel> filteredCustomers;
  
  CustomersLoaded(this.customers, {List<CustomerModel>? filteredCustomers})
      : filteredCustomers = filteredCustomers ?? customers;
}

class CustomerOperationSuccess extends CustomerState {
  final String message;
  CustomerOperationSuccess(this.message);
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
} 