import '../../../domain/entities/product/product.dart';
import '../../../domain/entities/order/order.dart';
import '../../../domain/entities/order/order_item.dart';
import '../../../domain/entities/customer/customer.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

// Product states
class ProductsLoaded extends OrderState {
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final String searchQuery;

  ProductsLoaded({
    required this.products,
    required this.filteredProducts,
    this.searchQuery = '',
  });

  ProductsLoaded copyWith({
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    String? searchQuery,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Cart states
class CartUpdated extends OrderState {
  final List<OrderItemModel> cartItems;
  final double subtotal;
  final double total;
  final CustomerModel? selectedCustomer;

  CartUpdated({
    required this.cartItems,
    required this.subtotal,
    required this.total,
    this.selectedCustomer,
  });

  CartUpdated copyWith({
    List<OrderItemModel>? cartItems,
    double? subtotal,
    double? total,
    CustomerModel? selectedCustomer,
  }) {
    return CartUpdated(
      cartItems: cartItems ?? this.cartItems,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
    );
  }

  int get itemCount => cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => cartItems.isEmpty;
}

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

  int get cartItemCount => cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
  bool get isCartEmpty => cartItems.isEmpty;
}

// Order list state
class OrderListState extends OrderState {
  final List<OrderModel> orders;
  final List<OrderModel> filteredOrders;
  final String searchQuery;
  final OrderStatus? selectedStatus;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;
  final int pageSize;
  final int totalItem;

  OrderListState({
    required this.orders,
    required this.filteredOrders,
    this.searchQuery = '',
    this.selectedStatus,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalItem = 0,
  });

  OrderListState copyWith({
    List<OrderModel>? orders,
    List<OrderModel>? filteredOrders,
    String? searchQuery,
    OrderStatus? selectedStatus,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? currentPage,
    int? pageSize,
    int? totalItem,
  }) {
    return OrderListState(
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalItem: totalItem ?? this.totalItem,
    );
  }
}

// Order operation states
class OrderCreated extends OrderState {
  final OrderModel order;
  OrderCreated(this.order);
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