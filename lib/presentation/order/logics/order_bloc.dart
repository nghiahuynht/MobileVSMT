import 'package:flutter_bloc/flutter_bloc.dart';
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

  OrderBloc() : super(OrderInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<SelectCustomerEvent>(_onSelectCustomer);
    on<CreateOrderEvent>(_onCreateOrder);
    on<LoadOrdersEvent>(_onLoadOrders);
    on<SearchOrdersEvent>(_onSearchOrders);
    on<FilterOrdersByStatusEvent>(_onFilterOrdersByStatus);
    on<ClearOrderFiltersEvent>(_onClearOrderFilters);
  }

  void _onLoadProducts(LoadProductsEvent event, Emitter<OrderState> emit) {
    emit(OrderLoading());
    
    // Mock data - tương tự như trong hình ảnh
    _allProducts = [
      ProductModel(
        id: '1',
        code: 'THANG-1',
        name: 'Thùng rác loại 1',
        price: 45000,
        description: 'Thùng rác nhựa cao cấp',
        category: 'Thùng rác',
        unit: 'cái',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ProductModel(
        id: '2',
        code: 'THANG-2',
        name: 'Thùng rác loại 2',
        price: 45000,
        description: 'Thùng rác inox',
        category: 'Thùng rác',
        unit: 'cái',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      ProductModel(
        id: '3',
        code: 'THANG-3',
        name: 'Thùng rác loại 3',
        price: 45000,
        description: 'Thùng rác có nắp đậy',
        category: 'Thùng rác',
        unit: 'cái',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      ProductModel(
        id: '4',
        code: 'THANG-4',
        name: 'Thùng rác loại 4',
        price: 45000,
        description: 'Thùng rác có bánh xe',
        category: 'Thùng rác',
        unit: 'cái',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ProductModel(
        id: '5',
        code: 'THANG-5',
        name: 'Thùng rác loại 5',
        price: 45000,
        description: 'Thùng rác công nghiệp',
        category: 'Thùng rác',
        unit: 'cái',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ProductModel(
        id: '6',
        code: 'THANG-6',
        name: 'Thùng rác loại 6',
        price: 45000,
        description: 'Thùng rác phân loại',
        category: 'Thùng rác',
        unit: 'cái',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      ProductModel(
        id: '7',
        code: 'THANG-7',
        name: 'Thùng rác loại 7',
        price: 45000,
        description: 'Thùng rác thông minh',
        category: 'Thùng rác',
        unit: 'cái',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ProductModel(
        id: '8',
        code: 'THANG-8',
        name: 'Thùng rác loại 8',
        price: 45000,
        description: 'Thùng rác màu xanh',
        category: 'Thùng rác',
        unit: 'cái',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ProductModel(
        id: '9',
        code: 'THANG-9',
        name: 'Thùng rác loại 9',
        price: 45000,
        description: 'Thùng rác siêu bền',
        category: 'Thùng rác',
        unit: 'cái',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    _emitOrderScreenState(emit);
  }

  void _onSearchProducts(SearchProductsEvent event, Emitter<OrderState> emit) {
    final query = event.query.toLowerCase();
    List<ProductModel> filteredProducts;
    
    if (query.isEmpty) {
      filteredProducts = _allProducts;
    } else {
      filteredProducts = _allProducts.where((product) {
        return product.code.toLowerCase().contains(query) ||
               product.name.toLowerCase().contains(query) ||
               (product.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    _emitOrderScreenState(emit, 
      filteredProducts: filteredProducts, 
      searchQuery: query
    );
  }

  void _onAddToCart(AddToCartEvent event, Emitter<OrderState> emit) {
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.product.id == event.product.id,
    );

    if (existingItemIndex >= 0) {
      // Cập nhật số lượng nếu sản phẩm đã có trong giỏ
      final existingItem = _cartItems[existingItemIndex];
      final newQuantity = existingItem.quantity + event.quantity;
      
      _cartItems[existingItemIndex] = existingItem.updateQuantity(newQuantity);
    } else {
      // Thêm sản phẩm mới vào giỏ
      final newItem = OrderItemModel.fromProduct(
        id: '${event.product.id}_${DateTime.now().millisecondsSinceEpoch}',
        product: event.product,
        quantity: event.quantity,
      );
      _cartItems.add(newItem);
    }

    _emitOrderScreenState(emit);
  }

  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<OrderState> emit) {
    _cartItems.removeWhere((item) => item.product.id == event.productId);
    _emitOrderScreenState(emit);
  }

  void _onUpdateCartItemQuantity(UpdateCartItemQuantityEvent event, Emitter<OrderState> emit) {
    final itemIndex = _cartItems.indexWhere(
      (item) => item.product.id == event.productId,
    );

    if (itemIndex >= 0) {
      if (event.quantity <= 0) {
        _cartItems.removeAt(itemIndex);
      } else {
        _cartItems[itemIndex] = _cartItems[itemIndex].updateQuantity(event.quantity);
      }
      _emitOrderScreenState(emit);
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<OrderState> emit) {
    _cartItems.clear();
    _selectedCustomer = null;
    _emitOrderScreenState(emit);
  }

  void _onSelectCustomer(SelectCustomerEvent event, Emitter<OrderState> emit) {
    _selectedCustomer = event.customer;
    _emitOrderScreenState(emit);
  }

  void _onCreateOrder(CreateOrderEvent event, Emitter<OrderState> emit) {
    if (_cartItems.isEmpty) {
      emit(OrderError('Giỏ hàng trống. Vui lòng thêm sản phẩm.'));
      return;
    }

    try {
      emit(OrderLoading());

      final orderNumber = 'DH${DateTime.now().millisecondsSinceEpoch}';
      final order = OrderModel.createNew(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        orderNumber: orderNumber,
        customer: _selectedCustomer,
        items: List.from(_cartItems),
        notes: event.notes,
        createdBy: 'current_user', // Thay bằng user hiện tại
      );

      // Sau khi tạo đơn thành công, xóa giỏ hàng
      _cartItems.clear();
      _selectedCustomer = null;

      emit(OrderCreated(order));
      emit(OrderOperationSuccess('Đơn hàng $orderNumber đã được tạo thành công!'));
      
      // Về lại trạng thái bình thường
      _emitOrderScreenState(emit);
    } catch (e) {
      emit(OrderError('Có lỗi xảy ra khi tạo đơn hàng: $e'));
      _emitOrderScreenState(emit);
    }
  }

  void _onLoadOrders(LoadOrdersEvent event, Emitter<OrderState> emit) {
    emit(OrderLoading());
    
    // Mock data cho đơn hàng
    _allOrders = _generateMockOrders();
    
    emit(OrderListState(
      orders: _allOrders,
      filteredOrders: _allOrders,
      isLoading: false,
    ));
  }

  void _onSearchOrders(SearchOrdersEvent event, Emitter<OrderState> emit) {
    final currentState = state;
    if (currentState is OrderListState) {
      final query = event.query.toLowerCase();
      List<OrderModel> filteredOrders = _allOrders;
      
      // Lọc theo trạng thái trước
      if (currentState.selectedStatus != null) {
        filteredOrders = filteredOrders.where(
          (order) => order.status == currentState.selectedStatus
        ).toList();
      }
      
      // Sau đó lọc theo từ khóa tìm kiếm
      if (query.isNotEmpty) {
        filteredOrders = filteredOrders.where((order) {
          return order.orderNumber.toLowerCase().contains(query) ||
                 (order.customer?.name.toLowerCase().contains(query) ?? false) ||
                 (order.customer?.phone?.contains(query) ?? false);
        }).toList();
      }
      
      emit(currentState.copyWith(
        filteredOrders: filteredOrders,
        searchQuery: query,
      ));
    }
  }

  void _onFilterOrdersByStatus(FilterOrdersByStatusEvent event, Emitter<OrderState> emit) {
    final currentState = state;
    if (currentState is OrderListState) {
      List<OrderModel> filteredOrders = _allOrders;
      
      // Lọc theo trạng thái
      if (event.status != null) {
        filteredOrders = filteredOrders.where(
          (order) => order.status == event.status
        ).toList();
      }
      
      // Sau đó lọc theo từ khóa tìm kiếm
      if (currentState.searchQuery.isNotEmpty) {
        filteredOrders = filteredOrders.where((order) {
          return order.orderNumber.toLowerCase().contains(currentState.searchQuery) ||
                 (order.customer?.name.toLowerCase().contains(currentState.searchQuery) ?? false) ||
                 (order.customer?.phone?.contains(currentState.searchQuery) ?? false);
        }).toList();
      }
      
      emit(currentState.copyWith(
        filteredOrders: filteredOrders,
        selectedStatus: event.status,
      ));
    }
  }

  void _onClearOrderFilters(ClearOrderFiltersEvent event, Emitter<OrderState> emit) {
    final currentState = state;
    if (currentState is OrderListState) {
      emit(currentState.copyWith(
        filteredOrders: _allOrders,
        selectedStatus: null,
        searchQuery: '',
      ));
    }
  }

  List<OrderModel> _generateMockOrders() {
    final customers = [
      CustomerModel(
        id: 'C001',
        name: 'Nguyễn Văn An',
        phone: '0123456789',
        address: '123 Đường ABC, Quận 1, TP.HCM',
        email: 'nguyenvanan@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      CustomerModel(
        id: 'C002',
        name: 'Trần Thị Bình',
        phone: '0987654321',
        address: '456 Đường XYZ, Quận 2, TP.HCM',
        email: 'tranthibinh@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      CustomerModel(
        id: 'C003',
        name: 'Lê Văn Cường',
        phone: '0369852147',
        address: '789 Đường DEF, Quận 3, TP.HCM',
        email: 'levancuong@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];

    final products = [
      ProductModel(
        id: '1',
        code: 'THANG-1',
        name: 'Thùng rác loại 1',
        price: 45000,
        description: 'Thùng rác nhựa cao cấp',
        category: 'Thùng rác',
        unit: 'cái',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ProductModel(
        id: '2',
        code: 'THANG-2',
        name: 'Thùng rác loại 2',
        price: 45000,
        description: 'Thùng rác inox',
        category: 'Thùng rác',
        unit: 'cái',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
    ];

    return [
      OrderModel(
        id: 'order_1',
        orderNumber: 'DH001',
        customer: customers[0],
        items: [
          OrderItemModel.fromProduct(
            id: 'item_1',
            product: products[0],
            quantity: 2,
          ),
          OrderItemModel.fromProduct(
            id: 'item_2',
            product: products[1],
            quantity: 1,
          ),
        ],
        subtotal: 135000,
        total: 135000,
        status: OrderStatus.confirmed,
        notes: 'Giao hàng vào buổi sáng',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        createdBy: 'admin',
      ),
      OrderModel(
        id: 'order_2',
        orderNumber: 'DH002',
        customer: customers[1],
        items: [
          OrderItemModel.fromProduct(
            id: 'item_3',
            product: products[0],
            quantity: 3,
          ),
        ],
        subtotal: 135000,
        total: 135000,
        status: OrderStatus.cancelled,
        notes: 'Khách hàng hủy đơn',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        createdBy: 'admin',
      ),
      OrderModel(
        id: 'order_3',
        orderNumber: 'DH003',
        customer: customers[2],
        items: [
          OrderItemModel.fromProduct(
            id: 'item_4',
            product: products[1],
            quantity: 1,
          ),
        ],
        subtotal: 45000,
        total: 45000,
        status: OrderStatus.completed,
        notes: 'Đã giao hàng thành công',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        createdBy: 'admin',
      ),
      OrderModel(
        id: 'order_4',
        orderNumber: 'DH004',
        customer: customers[0],
        items: [
          OrderItemModel.fromProduct(
            id: 'item_5',
            product: products[0],
            quantity: 1,
          ),
        ],
        subtotal: 45000,
        total: 45000,
        status: OrderStatus.pending,
        notes: 'Chờ xác nhận từ khách hàng',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        createdBy: 'admin',
      ),
      OrderModel(
        id: 'order_5',
        orderNumber: 'DH005',
        customer: customers[1],
        items: [
          OrderItemModel.fromProduct(
            id: 'item_6',
            product: products[1],
            quantity: 2,
          ),
        ],
        subtotal: 90000,
        total: 90000,
        status: OrderStatus.processing,
        notes: 'Đang chuẩn bị giao hàng',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        createdBy: 'admin',
      ),
    ];
  }

  void _emitOrderScreenState(
    Emitter<OrderState> emit, {
    List<ProductModel>? filteredProducts,
    String? searchQuery,
  }) {
    final subtotal = _cartItems.fold<double>(0, (sum, item) => sum + item.subtotal);
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