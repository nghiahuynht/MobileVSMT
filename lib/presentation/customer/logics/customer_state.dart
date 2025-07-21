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
  final int totalCustomers;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;
  final int pageSize;
  
  CustomersLoaded(
    this.customers, {
    List<CustomerModel>? filteredCustomers,
    List<Group>? groups,
    List<Area>? areas,
    this.searchQuery = '',
    this.selectedGroupId,
    this.selectedAreaId,
    this.totalCustomers = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.pageSize = 10,
  }) : filteredCustomers = filteredCustomers ?? customers,
       groups = groups ?? [],
       areas = areas ?? [];

  CustomersLoaded copyWith({
    List<CustomerModel>? customers,
    List<CustomerModel>? filteredCustomers,
    List<Group>? groups,
    List<Area>? areas,
    String? searchQuery,
    int? selectedGroupId,
    int? selectedAreaId,
    int? totalCustomers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? currentPage,
    int? pageSize,
  }) {
    return CustomersLoaded(
      customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      groups: groups ?? this.groups,
      areas: areas ?? this.areas,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      selectedAreaId: selectedAreaId ?? this.selectedAreaId,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class CustomerOperationSuccess extends CustomerState {
  final String message;
  CustomerOperationSuccess(this.message);
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
} 