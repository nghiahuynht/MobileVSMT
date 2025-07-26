import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/presentation/customer/logics/customer_events.dart';
import 'package:trash_pay/presentation/customer/logics/customer_state.dart';
import 'dart:async';

class CustomerBloc extends Bloc<CustomerEvents, CustomerState> {
  CustomerBloc() : super(CustomerInitial()) {
    on<LoadCustomersEvent>(_handleLoadCustomers);
    on<LoadMoreCustomersEvent>(_handleLoadMoreCustomers);
    on<AddCustomerEvent>(_handleAddCustomer);
    on<UpdateCustomerEvent>(_handleUpdateCustomer);
    on<DeleteCustomerEvent>(_handleDeleteCustomer);
  }

  final DomainManager domainManager = GetIt.I<DomainManager>();
  List<CustomerModel> _allCustomers = [];
  List<Group> _allGroups = [];
  List<Area> _allAreas = [];
  String _currentSearchQuery = '';
  int? _currentGroupId;
  int? _currentAreaId;
  String? _currentAreaSaleCode;
  String? _currentRouteSaleCode;
  
  // Debounce timer for search
  Timer? _searchDebounceTimer;

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    return super.close();
  }

  Future<void> _handleLoadCustomers(
      LoadCustomersEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      final result = await domainManager.customer.getCustomerPaging(
        pageIndex: event.pageIndex ?? 1,
        pageSize: event.pageSize ?? 10,
        searchString: event.search ?? '',
        areaSaleCode: event.routeSaleCode,
        routeSaleCode: event.areaSaleCode,
      );

      if (result is Success) {
        final successResult = result as Success;
        _allCustomers = List<CustomerModel>.from(successResult.data.data);
        emit(CustomersLoaded(
          _allCustomers,
          filteredCustomers: _allCustomers,
          groups: _allGroups,
          areas: _allAreas,
          searchQuery: event.search ?? '',
          selectedGroupId: _currentGroupId,
          selectedAreaId: _currentAreaId,
          totalCustomers: successResult.data.totalItem,
          currentPage: successResult.data.pageIndex,
          pageSize: successResult.data.pageSize,
          hasReachedMax: successResult.data.hasReachedMax,
        ));
      } else if (result is Failure) {
        final failureResult = result as Failure;
        emit(CustomerError('Không thể tải danh sách khách hàng: ${failureResult.errorResultEntity.message ?? 'Unknown error'}'));
      }
    } catch (e) {
      emit(CustomerError('Không thể tải danh sách khách hàng: ${e.toString()}'));
    }
  }

  Future<void> _handleLoadMoreCustomers(
      LoadMoreCustomersEvent event, Emitter<CustomerState> emit) async {
    final currentState = state;
    if (currentState is CustomersLoaded) {
      if (currentState.hasReachedMax || currentState.isLoadingMore) {
        return;
      }

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final nextPage = currentState.currentPage + 1;
        final result = await domainManager.customer.getCustomerPaging(
          pageIndex: nextPage,
          pageSize: currentState.pageSize,
          searchString: _currentSearchQuery,
          areaSaleCode: _currentAreaSaleCode,
          routeSaleCode: _currentRouteSaleCode,
        );

        if (result is Success) {
          final successResult = result as Success;
          final newCustomers = List<CustomerModel>.from(successResult.data.data);
          final updatedCustomers = [...currentState.customers, ...newCustomers];
          _allCustomers = updatedCustomers;

          emit(currentState.copyWith(
            customers: updatedCustomers,
            filteredCustomers: updatedCustomers,
            currentPage: nextPage,
            isLoadingMore: false,
            hasReachedMax: successResult.data.hasReachedMax,
            totalCustomers: successResult.data.totalItem,
          ));
        } else if (result is Failure) {
          final failureResult = result as Failure;
          emit(currentState.copyWith(isLoadingMore: false));
          emit(CustomerError('Lỗi khi tải thêm khách hàng: ${failureResult.errorResultEntity.message ?? 'Unknown error'}'));
        }
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
        emit(CustomerError('Lỗi khi tải thêm khách hàng: ${e.toString()}'));
      }
    }
  }

  List<CustomerModel> _applyFiltersToList(List<CustomerModel> customers) {
    List<CustomerModel> filtered = customers;

    // Apply group filter - find matching group code
    if (_currentGroupId != null) {
      final selectedGroup = _allGroups.firstWhere((group) => group.id == _currentGroupId, orElse: () => Group(id: 0, code: '', name: ''));
      if (selectedGroup.code?.isNotEmpty ?? false) {
        filtered = filtered.where((customer) => customer.customerGroupCode == selectedGroup.code).toList();
      }
    }

    // Apply area filter - find matching area code
    if (_currentAreaId != null) {
      final selectedArea = _allAreas.firstWhere((area) => area.id == _currentAreaId, orElse: () => Area(id: 0, code: '', name: ''));
      if (selectedArea.code.isNotEmpty) {
        filtered = filtered.where((customer) => customer.areaSaleCode == selectedArea.code).toList();
      }
    }

    return filtered;
  }

  List<CustomerModel> _applyFilters() {
    return _applyFiltersToList(_allCustomers);
  }

  Future<void> _handleAddCustomer(
      AddCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      final result = await domainManager.customer.addCustomer(event.customer, isEdit: event.isEdit);
      if (result is Success) {
        emit(CustomerOperationSuccess('Đã thêm khách hàng thành công'));
      } else if (result is Failure<CustomerModel>) {
        emit(CustomerError(
            'Không thể thêm khách hàng: ${result.errorResultEntity.message ?? 'Unknown error'}'));
      }
    } catch (e) {
      emit(CustomerError('Không thể thêm khách hàng: ${e.toString()}'));
    }
  }

  Future<void> _handleUpdateCustomer(
      UpdateCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      // Simulated update - replace with actual repository call
      final index = _allCustomers.indexWhere((c) => c.id == event.customer.id);
      if (index != -1) {
        _allCustomers[index] = event.customer;
        emit(CustomerOperationSuccess('Đã cập nhật khách hàng thành công'));
        
        final currentState = state;
        if (currentState is CustomersLoaded) {
          emit(currentState.copyWith(
            customers: _allCustomers,
            filteredCustomers: _applyFilters(),
          ));
        }
      }
    } catch (e) {
      emit(CustomerError('Không thể cập nhật khách hàng: ${e.toString()}'));
    }
  }

  Future<void> _handleDeleteCustomer(
      DeleteCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      // Simulated delete - replace with actual repository call
      _allCustomers.removeWhere((c) => c.id == event.customerId);
      emit(CustomerOperationSuccess('Đã xóa khách hàng thành công'));
      
      final currentState = state;
      if (currentState is CustomersLoaded) {
        emit(currentState.copyWith(
          customers: _allCustomers,
          filteredCustomers: _applyFilters(),
        ));
      }
    } catch (e) {
      emit(CustomerError('Không thể xóa khách hàng: ${e.toString()}'));
    }
  }
} 