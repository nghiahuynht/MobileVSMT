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
  List<ProductModel> _allProducts = [];
  List<OrderItemModel> _cartItems = [];
  CustomerModel? _selectedCustomer;
  List<OrderModel> _allOrders = [];
  
  // Debounce timer for search
  Timer? _searchDebounceTimer;
  String _currentSearchQuery = '';

  final DomainManager _domainManager = DomainManager();

  OrderBloc() : super(OrderInitial()) {
    on<SelectCustomerEvent>(_onSelectCustomer);
    on<CreateOrderEvent>(_onCreateOrder);
    on<InitOrderEvent>(_onInitOrders);
    on<SearchOrdersEvent>(_onSearchOrders);
    on<FilterOrdersByStatusEvent>(_onFilterOrdersByStatus);
    on<ClearOrderFiltersEvent>(_onClearOrderFilters);
    on<LoadMoreOrdersEvent>(_onLoadMoreOrders);
    on<RefreshOrdersEvent>(_onRefreshOrders);
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

  void _onCreateOrder(CreateOrderEvent event, Emitter<OrderState> emit) {
    // if (_cartItems.isEmpty) {
    //   emit(OrderError('Giỏ hàng trống. Vui lòng thêm sản phẩm.'));
    //   return;
    // }

    // try {
    //   emit(OrderLoading());

    //   final orderNumber = 'DH${DateTime.now().millisecondsSinceEpoch}';
    //   final order = OrderModel.createNew(
    //     id: 'order_${DateTime.now().millisecondsSinceEpoch}',
    //     orderNumber: orderNumber,
    //     customer: _selectedCustomer,
    //     items: List.from(_cartItems),
    //     notes: event.notes,
    //     createdBy: 'current_user', // Thay bằng user hiện tại
    //   );

    //   // Sau khi tạo đơn thành công, xóa giỏ hàng
    //   _cartItems.clear();
    //   _selectedCustomer = null;

    //   emit(OrderCreated(order));
    //   emit(OrderOperationSuccess('Đơn hàng $orderNumber đã được tạo thành công!'));

    //   // Về lại trạng thái bình thường
    //   _emitOrderScreenState(emit);
    // } catch (e) {
    //   emit(OrderError('Có lỗi xảy ra khi tạo đơn hàng: $e'));
    //   _emitOrderScreenState(emit);
    // }
  }

  Future<void> _onInitOrders(
      InitOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());

    try {
      final PaginationWrapperResponsive<OrderModel> result =
          await _domainManager.order.getSaleOrders();

      // Initialize _allOrders with first page data
      _allOrders = result.data;

      emit(OrderListState(
          orders: result.data,
          filteredOrders: result.data,
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
    if (currentState is OrderListState) {
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

  Future<void> _performSearch(String query, Emitter<OrderState> emit, OrderListState currentState) async {
    try {
      _currentSearchQuery = query;
      
      // Call API with search query
      final PaginationWrapperResponsive<OrderModel> result =
          await _domainManager.order.getSaleOrders(
        pageIndex: 1,
        pageSize: currentState.pageSize,
        searchString: query,
      );

      // Update orders with search results
      _allOrders = result.data;
      
      // Apply status filter if selected
      List<OrderModel> filteredOrders = result.data;


      emit(currentState.copyWith(
        orders: result.data,
        filteredOrders: filteredOrders,
        searchQuery: query,
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

  void _onFilterOrdersByStatus(
      FilterOrdersByStatusEvent event, Emitter<OrderState> emit) {
    final currentState = state;
    if (currentState is OrderListState) {
      List<OrderModel> filteredOrders = _allOrders;

      // Lọc theo trạng thái
      if (event.status != null) {
        filteredOrders = filteredOrders
            .where((order) => order.orderStatus == event.status)
            .toList();
      }

      // Sau đó lọc theo từ khóa tìm kiếm
      if (currentState.searchQuery.isNotEmpty) {
        filteredOrders = filteredOrders.where((order) {
          return (order.code
                      ?.toLowerCase()
                      .contains(currentState.searchQuery) ??
                  false) ||
              (order.customerName
                      ?.toLowerCase()
                      .contains(currentState.searchQuery) ??
                  false) ||
              (order.customerGroupName
                      ?.toLowerCase()
                      .contains(currentState.searchQuery) ??
                  false);
        }).toList();
      }

      emit(currentState.copyWith(
        filteredOrders: filteredOrders,
        selectedStatus: event.status,
      ));
    }
  }

  void _onClearOrderFilters(
      ClearOrderFiltersEvent event, Emitter<OrderState> emit) {
    final currentState = state;
    if (currentState is OrderListState) {
      emit(currentState.copyWith(
        filteredOrders: _allOrders,
        selectedStatus: null,
        searchQuery: '',
      ));
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
          searchString: currentState.searchQuery, // Include search query in load more
        );

        // Merge new orders with existing ones
        final updatedOrders = [...currentState.orders, ...result.data];
        
        // Apply current filters to the updated list
        List<OrderModel> filteredOrders = updatedOrders;
        
        // Apply status filter
        if (currentState.selectedStatus != null) {
          filteredOrders = filteredOrders
              .where((order) => order.orderStatus == currentState.selectedStatus)
              .toList();
        }
        
        // Update _allOrders for future filtering
        _allOrders = updatedOrders;

        emit(currentState.copyWith(
          orders: updatedOrders,
          filteredOrders: filteredOrders,
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

  void _onRefreshOrders(
      RefreshOrdersEvent event, Emitter<OrderState> emit) async {
    final currentState = state;
    if (currentState is OrderListState) {
      emit(currentState.copyWith(isLoading: true));

      // Simulate refresh
      await Future.delayed(const Duration(milliseconds: 500));

      final displayedOrders =
          currentState.filteredOrders.take(currentState.pageSize).toList();

      emit(currentState.copyWith(
        currentPage: 1,
        isLoading: false,
        isLoadingMore: false,
        hasReachedMax:
            currentState.filteredOrders.length <= currentState.pageSize,
      ));
    }
  }

  void _onFilterOrdersByMultipleCriteria(
      FilterOrdersByMultipleCriteriaEvent event, Emitter<OrderState> emit) async {
    final currentState = state;
    if (currentState is OrderListState) {
      emit(currentState.copyWith(isLoading: true));
      
      try {
        // Call API with multiple filter criteria (removed status)
        final PaginationWrapperResponsive<OrderModel> result =
            await _domainManager.order.getSaleOrders(
          pageIndex: 1,
          pageSize: currentState.pageSize,
          searchString: currentState.searchQuery,
          dateType: event.dateType ?? 1,
          areaSaleCode: event.areaSaleCode,
          routeSaleCode: event.routeSaleCode,
          saleUserCode: event.saleUserCode,
          fromDate: event.fromDate,
          toDate: event.toDate,
        );

        // Update orders with filtered results (no status filtering)
        _allOrders = result.data;

        emit(currentState.copyWith(
          orders: result.data,
          filteredOrders: result.data, // No local status filtering
          isLoading: false,
          currentPage: 1,
          hasReachedMax: result.hasReachedMax,
          totalItem: result.totalItem,
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
