import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/location/area.dart';
import 'package:trash_pay/presentation/customer/logics/customer_events.dart';
import 'package:trash_pay/presentation/customer/logics/customer_state.dart';
import 'dart:async';

class CustomerBloc extends Bloc<CustomerEvents, CustomerState> {
  CustomerBloc() : super(CustomerInitial()) {
    on<LoadCustomersEvent>(_handleLoadCustomers);
    on<LoadMoreCustomersEvent>(_handleLoadMoreCustomers);
    on<SearchCustomersEvent>(_handleSearchCustomers);
    on<FilterCustomersByGroupEvent>(_handleFilterByGroup);
    on<FilterCustomersByAreaEvent>(_handleFilterByArea);
    on<ClearFiltersEvent>(_handleClearFilters);
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
        searchString: _currentSearchQuery,
      );

      if (result is Success) {
        final successResult = result as Success;
        _allCustomers = List<CustomerModel>.from(successResult.data.data);
        
        emit(CustomersLoaded(
          _allCustomers,
          filteredCustomers: _allCustomers,
          groups: _allGroups,
          areas: _allAreas,
          searchQuery: _currentSearchQuery,
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
        
        // Call API with next page and current search query
        final result = await domainManager.customer.getCustomerPaging(
          pageIndex: nextPage,
          pageSize: currentState.pageSize,
          searchString: currentState.searchQuery,
        );

        if (result is Success) {
          final successResult = result as Success;
          
          // Merge new customers with existing ones
          final newCustomers = List<CustomerModel>.from(successResult.data.data);
          final updatedCustomers = [...currentState.customers, ...newCustomers];
          
          // Apply current filters to the updated list
          List<CustomerModel> filteredCustomers = _applyFiltersToList(updatedCustomers);
          
          // Update _allCustomers for future filtering
          _allCustomers = updatedCustomers;

          emit(currentState.copyWith(
            customers: updatedCustomers,
            filteredCustomers: filteredCustomers,
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

  Future<void> _handleSearchCustomers(
      SearchCustomersEvent event, Emitter<CustomerState> emit) async {
    final currentState = state;
    if (currentState is CustomersLoaded) {
      // Cancel previous timer
      _searchDebounceTimer?.cancel();
      
      // Update search query immediately in UI
      emit(currentState.copyWith(
        searchQuery: event.query,
        isLoading: event.query != _currentSearchQuery && event.query.isNotEmpty,
      ));
      
      // Set debounce timer
      _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        _performSearch(event.query, emit, currentState);
      });
    }
  }

  Future<void> _performSearch(String query, Emitter<CustomerState> emit, CustomersLoaded currentState) async {
    try {
      _currentSearchQuery = query;
      
      // Call API with search query
      final result = await domainManager.customer.getCustomerPaging(
        pageIndex: 1,
        pageSize: currentState.pageSize,
        searchString: query,
      );

      if (result is Success) {
        final successResult = result as Success;
        
        // Update customers with search results
        _allCustomers = List<CustomerModel>.from(successResult.data.data);
        
        // Apply filters to search results
        List<CustomerModel> filteredCustomers = _applyFiltersToList(_allCustomers);

        emit(currentState.copyWith(
          customers: _allCustomers,
          filteredCustomers: filteredCustomers,
          searchQuery: query,
          isLoading: false,
          currentPage: 1, // Reset to first page
          hasReachedMax: successResult.data.hasReachedMax,
          totalCustomers: successResult.data.totalItem,
        ));
      } else if (result is Failure) {
        final failureResult = result as Failure;
        emit(currentState.copyWith(isLoading: false));
        emit(CustomerError('Lỗi khi tìm kiếm: ${failureResult.errorResultEntity.message ?? 'Unknown error'}'));
      }
    } catch (e) {
      emit(currentState.copyWith(isLoading: false));
      emit(CustomerError('Lỗi khi tìm kiếm: $e'));
    }
  }

  Future<void> _handleFilterByGroup(
      FilterCustomersByGroupEvent event, Emitter<CustomerState> emit) async {
    final currentState = state;
    if (currentState is CustomersLoaded) {
      _currentGroupId = event.groupId;
      final filteredCustomers = _applyFiltersToList(currentState.customers);
      
      emit(currentState.copyWith(
        filteredCustomers: filteredCustomers,
        selectedGroupId: _currentGroupId,
      ));
    }
  }

  Future<void> _handleFilterByArea(
      FilterCustomersByAreaEvent event, Emitter<CustomerState> emit) async {
    final currentState = state;
    if (currentState is CustomersLoaded) {
      _currentAreaId = event.areaId;
      final filteredCustomers = _applyFiltersToList(currentState.customers);
      
      emit(currentState.copyWith(
        filteredCustomers: filteredCustomers,
        selectedAreaId: _currentAreaId,
      ));
    }
  }

  Future<void> _handleClearFilters(
      ClearFiltersEvent event, Emitter<CustomerState> emit) async {
    final currentState = state;
    if (currentState is CustomersLoaded) {
      _currentSearchQuery = '';
      _currentGroupId = null;
      _currentAreaId = null;
      
      emit(currentState.copyWith(
        filteredCustomers: currentState.customers,
        searchQuery: '',
        selectedGroupId: null,
        selectedAreaId: null,
      ));
    }
  }

  List<CustomerModel> _applyFiltersToList(List<CustomerModel> customers) {
    List<CustomerModel> filtered = customers;

    // Apply group filter - find matching group code
    if (_currentGroupId != null) {
      final selectedGroup = _allGroups.firstWhere((group) => group.id == _currentGroupId, orElse: () => Group(id: 0, code: '', name: ''));
      if (selectedGroup.code.isNotEmpty) {
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
      // Simulated add - replace with actual repository call
      _allCustomers.add(event.customer);
      emit(CustomerOperationSuccess('Đã thêm khách hàng thành công'));
      
      final currentState = state;
      if (currentState is CustomersLoaded) {
        emit(currentState.copyWith(
          customers: _allCustomers,
          filteredCustomers: _applyFilters(),
        ));
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