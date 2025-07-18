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

  OrderBloc() : super(OrderInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<SelectCustomerEvent>(_onSelectCustomer);
    on<CreateOrderEvent>(_onCreateOrder);
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