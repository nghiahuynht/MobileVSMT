import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_order_events.dart' as events;
import 'create_order_state.dart' as state;
import '../../../domain/entities/order/order_item.dart';
import '../../../domain/entities/customer/customer.dart';

class CreateOrderBloc
    extends Bloc<events.CreateOrderEvent, state.CreateOrderState> {
  List<state.ProductOrderItemWrapper> _allProducts = [];
  CustomerModel? _selectedCustomer;

  CreateOrderBloc() : super(state.CreateOrderInitial()) {
    on<events.InitCreateOrder>(_onInit);
    on<events.AddProductToCart>(_onAddProduct);
    on<events.RemoveProductFromCart>(_onRemoveProduct);
    on<events.UpdateProductQuantity>(_onUpdateQuantity);
    on<events.SelectCustomerForOrder>(_onSelectCustomer);
    on<events.SubmitCreateOrder>(_onSubmitOrder);
  }

  void _onInit(events.InitCreateOrder event,
      Emitter<state.CreateOrderState> emit) async {
    _allProducts = event.products
        .map((e) => state.ProductOrderItemWrapper(item: e, quantity: 0))
        .toList();

    emit(state.CreateOrderLoaded(
      products: _allProducts,
      selectedCustomer: _selectedCustomer,
    ));
  }

  void _onAddProduct(
      events.AddProductToCart event, Emitter<state.CreateOrderState> emit) {
    // Đảm bảo mỗi sản phẩm chỉ được chọn tối đa 1 lần
    _allProducts[event.index] = _allProducts[event.index]
        .copyWith(quantity: 1);
    emit(_currentLoadedState(isSubmitting: false));
  }

  void _onRemoveProduct(events.RemoveProductFromCart event,
      Emitter<state.CreateOrderState> emit) {
    // Đảm bảo mỗi sản phẩm chỉ được chọn tối đa 1 lần
    _allProducts[event.index] =
        _allProducts[event.index].copyWith(quantity: 0);
    emit(_currentLoadedState(isSubmitting: false));
  }

  void _onUpdateQuantity(events.UpdateProductQuantity event,
      Emitter<state.CreateOrderState> emit) {
    // TODO: Update product quantity in cart
    emit(_currentLoadedState(isSubmitting: false));
  }

  void _onSelectCustomer(events.SelectCustomerForOrder event,
      Emitter<state.CreateOrderState> emit) {
    _selectedCustomer = event.customer;
    emit(_currentLoadedState(isSubmitting: false));
  }

  void _onSubmitOrder(events.SubmitCreateOrder event,
      Emitter<state.CreateOrderState> emit) async {
    emit(_currentLoadedState(isSubmitting: true));
    // TODO: Submit order to API
    // On success:
    // emit(state.CreateOrderSuccess(order));
    // On error:
    // emit(state.CreateOrderError('Lỗi khi tạo đơn hàng'));
  }

  state.CreateOrderLoaded _currentLoadedState({bool isSubmitting = false}) {
    return state.CreateOrderLoaded(
      products: _allProducts,
      selectedCustomer: _selectedCustomer,
      isSubmitting: isSubmitting,
    );
  }

}
