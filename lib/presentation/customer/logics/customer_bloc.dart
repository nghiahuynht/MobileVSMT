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
  }

  final DomainManager domainManager = GetIt.I<DomainManager>();
  List<CustomerModel> _allCustomers = [];
  final List<Group> _allGroups = [];
  final List<Area> _allAreas = [];
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
      _currentAreaSaleCode = event.areaSaleCode;
      _currentRouteSaleCode = event.routeSaleCode;
      _currentSearchQuery = event.search ?? '';

      final result = await domainManager.customer.getCustomerPaging(
        pageIndex: event.pageIndex ?? 1,
        pageSize: event.pageSize ?? 10,
        searchString: event.search ?? '',
        areaSaleCode: event.areaSaleCode,
        routeSaleCode: event.routeSaleCode,
        saleUserCode: event.saleUserCode,
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
        emit(CustomerError(
            'Không thể tải danh sách khách hàng: ${failureResult.errorResultEntity.message ?? 'Unknown error'}'));
      }
    } catch (e) {
      emit(
          CustomerError('Không thể tải danh sách khách hàng: ${e.toString()}'));
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
          saleUserCode: event.saleUserCode,
        );

        if (result is Success) {
          final successResult = result as Success;
          final newCustomers =
              List<CustomerModel>.from(successResult.data.data);
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
          emit(CustomerError(
              'Lỗi khi tải thêm khách hàng: ${failureResult.errorResultEntity.message ?? 'Unknown error'}'));
        }
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
        emit(CustomerError('Lỗi khi tải thêm khách hàng: ${e.toString()}'));
      }
    }
  }

  Future<void> _handleAddCustomer(
      AddCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      final result = await domainManager.customer
          .addCustomer(event.customer, isEdit: event.isEdit);
      if (result is Success) {
        emit(CustomerOperationSuccess(event.isEdit ? 'Đã cập nhật khách hàng thành công' : 'Đã thêm khách hàng thành công'));
      } else if (result is Failure<bool>) {
        emit(CustomerError(
            'Không thể thêm khách hàng: ${result.errorResultEntity.message ?? 'Unknown error'}'));
      }
    } catch (e) {
      emit(CustomerError('Không thể thêm khách hàng: ${e.toString()}'));
    }
  }
}
