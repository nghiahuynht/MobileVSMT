import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/common/pagination_wrapper_responsive.dart';
import 'dart:async';
import 'order_events.dart';
import 'order_state.dart';
import '../../../domain/entities/product/product.dart';
import '../../../domain/entities/order/order.dart';
import '../../../domain/entities/order/order_item.dart';
import '../../../domain/entities/customer/customer.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final List<ProductModel> _allProducts = [];
  final List<OrderItemModel> _cartItems = [];
  CustomerModel? _selectedCustomer;

  String? _searchQuery = '';
  String? _areaSaleCode;
  String? _routeSaleCode;
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _dateType;

  // Debounce timer for search
  Timer? _searchDebounceTimer;

  final DomainManager _domainManager = DomainManager();

  OrderBloc() : super(OrderInitial()) {
    on<SelectCustomerEvent>(_onSelectCustomer);
    on<InitOrderEvent>(_onInitOrders);
    on<SearchOrdersEvent>(_onSearchOrders);
    on<LoadMoreOrdersEvent>(_onLoadMoreOrders);
    on<FilterOrdersByMultipleCriteriaEvent>(_onFilterOrdersByMultipleCriteria);
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    return super.close();
  }

  void _onSelectCustomer(SelectCustomerEvent event, Emitter<OrderState> emit) {
    _selectedCustomer = event.customer;
    _emitOrderScreenState(emit);
  }

  Future<void> _onInitOrders(
      InitOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());

    try {
      final PaginationWrapperResponsive<OrderModel> result =
          await _domainManager.order.getSaleOrders();

      // Initialize _allOrders with first page data

      emit(OrderListState(
          orders: result.data,
          isLoading: false,
          currentPage: result.pageIndex,
          pageSize: result.pageSize,
          totalItem: result.totalItem,
          hasReachedMax: result.hasReachedMax));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  void _onSearchOrders(SearchOrdersEvent event, Emitter<OrderState> emit) {
    final currentState = state;
    if (_searchQuery == event.query) {
      return;
    }

    if (currentState is OrderListState) {
      _searchDebounceTimer?.cancel();

      _searchQuery = event.query;

      emit(currentState.copyWith(
        searchQuery: event.query,
        isLoading: true,
      ));

      // Set debounce timer
      _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        _performSearch(emit, currentState);
      });
    }
  }

  Future<void> _performSearch(
      Emitter<OrderState> emit, OrderListState currentState) async {
    try {
      // Call API with search query
      final PaginationWrapperResponsive<OrderModel> result =
          await _domainManager.order.getSaleOrders(
        pageIndex: 1,
        pageSize: currentState.pageSize,
        searchString: _searchQuery ?? '',
        dateType: _dateType ?? 1,
        areaSaleCode: _areaSaleCode,
        routeSaleCode: _routeSaleCode,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      // Update orders with search results

      emit(currentState.copyWith(
        orders: result.data,
        searchQuery: _searchQuery ?? '',
        isLoading: false,
        currentPage: 1, // Reset to first page
        hasReachedMax: result.hasReachedMax,
        totalItem: result.totalItem,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoading: false));
      emit(OrderError('Lỗi khi tìm kiếm: $e'));
    }
  }

  Future<void> _onLoadMoreOrders(
      LoadMoreOrdersEvent event, Emitter<OrderState> emit) async {
    final currentState = state;
    if (currentState is OrderListState) {
      if (currentState.hasReachedMax || currentState.isLoadingMore) {
        return;
      }

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final nextPage = currentState.currentPage + 1;

        // Call API with next page and current search query
        final PaginationWrapperResponsive<OrderModel> result =
            await _domainManager.order.getSaleOrders(
          pageIndex: nextPage,
          pageSize: currentState.pageSize,
          searchString: currentState.searchQuery,
          dateType: _dateType ?? 1,
          areaSaleCode: _areaSaleCode,
          routeSaleCode: _routeSaleCode,
          fromDate: _fromDate,
          toDate: _toDate,
        );

        // Merge new orders with existing ones
        final updatedOrders = [...currentState.orders, ...result.data];

        // Update _allOrders for future filtering

        emit(currentState.copyWith(
          orders: updatedOrders,
          currentPage: nextPage,
          isLoadingMore: false,
          hasReachedMax: result.hasReachedMax,
          totalItem: result.totalItem,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
        emit(OrderError('Lỗi khi tải thêm đơn hàng: $e'));
      }
    }
  }

  void _onFilterOrdersByMultipleCriteria(
      FilterOrdersByMultipleCriteriaEvent event,
      Emitter<OrderState> emit) async {
    final currentState = state;
    if (currentState is OrderListState) {
      emit(currentState.copyWith(isLoading: true));

      _dateType = event.dateType;
      _areaSaleCode = event.selectedArea?.code;
      _routeSaleCode = event.selectedRoute?.code;
      _fromDate = event.fromDate;
      _toDate = event.toDate;

      try {
        // Call API with multiple filter criteria (removed status)
        final PaginationWrapperResponsive<OrderModel> result =
            await _domainManager.order.getSaleOrders(
          pageIndex: 1,
          pageSize: currentState.pageSize,
          searchString: currentState.searchQuery,
          dateType: event.dateType ?? 1,
          areaSaleCode: event.selectedArea?.code,
          routeSaleCode: event.selectedRoute?.code,
          saleUserCode: event.saleUserCode,
          fromDate: event.fromDate,
          toDate: event.toDate,
        );

        // Update orders with filtered results (no status filtering)

        emit(currentState.copyWith(
          orders: result.data,
          isLoading: false,
          currentPage: 1,
          hasReachedMax: result.hasReachedMax,
          totalItem: result.totalItem,
          selectedArea: event.selectedArea,
          selectedRoute: event.selectedRoute,
          dateType: event.dateType,
          fromDate: event.fromDate,
          toDate: event.toDate,
          routes: event.routes,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoading: false));
        emit(OrderError('Lỗi khi lọc đơn hàng: $e'));
      }
    }
  }

  void _emitOrderScreenState(
    Emitter<OrderState> emit, {
    List<ProductModel>? filteredProducts,
    String? searchQuery,
  }) {
    final subtotal = _cartItems.fold<double>(
        0, (sum, item) => sum + (item.total?.toDouble() ?? 0));
    const discount = 0.0;
    const tax = 0.0;
    final total = subtotal - discount + tax;

    emit(OrderScreenState(
      products: _allProducts,
      filteredProducts: filteredProducts ?? _allProducts,
      searchQuery: searchQuery ?? '',
      cartItems: List.from(_cartItems),
      subtotal: subtotal,
      total: total,
      selectedCustomer: _selectedCustomer,
      isLoading: false,
    ));
  }
}
