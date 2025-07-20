import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/location/area.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomersLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final List<CustomerModel> filteredCustomers;
  final List<Group> groups;
  final List<Area> areas;
  final String searchQuery;
  final int? selectedGroupId;
  final int? selectedAreaId;
  
  CustomersLoaded(
    this.customers, {
    List<CustomerModel>? filteredCustomers,
    List<Group>? groups,
    List<Area>? areas,
    this.searchQuery = '',
    this.selectedGroupId,
    this.selectedAreaId,
  }) : filteredCustomers = filteredCustomers ?? customers,
       groups = groups ?? [],
       areas = areas ?? [];
}

class CustomerOperationSuccess extends CustomerState {
  final String message;
  CustomerOperationSuccess(this.message);
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
} 