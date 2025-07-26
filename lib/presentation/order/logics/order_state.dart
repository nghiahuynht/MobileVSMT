import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/domain/entities/meta_data/route.dart' as MetaRoute;
import 'package:trash_pay/presentation/order/enum.dart';

import '../../../domain/entities/product/product.dart';
import '../../../domain/entities/order/order.dart';
import '../../../domain/entities/order/order_item.dart';
import '../../../domain/entities/customer/customer.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}


// Combined state for order screen
class OrderScreenState extends OrderState {
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final String searchQuery;
  final List<OrderItemModel> cartItems;
  final double subtotal;
  final double total;
  final CustomerModel? selectedCustomer;
  final bool isLoading;

  OrderScreenState({
    required this.products,
    required this.filteredProducts,
    this.searchQuery = '',
    required this.cartItems,
    required this.subtotal,
    required this.total,
    this.selectedCustomer,
    this.isLoading = false,
  });

  OrderScreenState copyWith({
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    String? searchQuery,
    List<OrderItemModel>? cartItems,
    double? subtotal,
    double? total,
    CustomerModel? selectedCustomer,
    bool? isLoading,
  }) {
    return OrderScreenState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      cartItems: cartItems ?? this.cartItems,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get cartItemCount =>
      cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
  bool get isCartEmpty => cartItems.isEmpty;
}

// Order list state
class OrderListState extends OrderState {
  final List<OrderModel> orders;
  final String searchQuery;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;
  final int pageSize;
  final int totalItem;
  final String? saleUserCode;
  final int dateType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final Area? selectedArea;
  final MetaRoute.Route? selectedRoute;
  final List<MetaRoute.Route> routes;

  OrderListState({
    required this.orders,
    this.searchQuery = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalItem = 0,
    this.saleUserCode,
    this.dateType = 1,
    this.fromDate,
    this.toDate,
    this.selectedArea,
    this.selectedRoute,
    this.routes = const [],
  });

  OrderListState copyWith({
    List<OrderModel>? orders,
    String? searchQuery,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? currentPage,
    int? pageSize,
    int? totalItem,
    String? areaSaleCode,
    String? routeSaleCode,
    String? saleUserCode,
    int? dateType,
    DateTime? fromDate,
    DateTime? toDate,
    Area? selectedArea,
    MetaRoute.Route? selectedRoute,
    List<MetaRoute.Route>? routes,
  }) {
    return OrderListState(
      orders: orders ?? this.orders,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalItem: totalItem ?? this.totalItem,
      saleUserCode: saleUserCode ?? this.saleUserCode,
      dateType: dateType ?? this.dateType,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      selectedArea: selectedArea ?? this.selectedArea,
      selectedRoute: selectedRoute ?? this.selectedRoute,
      routes: routes ?? this.routes,
    );
  }
}

class OrdersLoaded extends OrderState {
  final List<OrderModel> orders;
  OrdersLoaded(this.orders);
}

class OrderDetailLoaded extends OrderState {
  final OrderModel order;
  OrderDetailLoaded(this.order);
}

class OrderOperationSuccess extends OrderState {
  final String message;
  OrderOperationSuccess(this.message);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}
