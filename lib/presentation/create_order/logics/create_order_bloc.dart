import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/constants/enums/app_type_enum.dart';
import 'package:trash_pay/services/user_prefs.dart';
import 'create_order_events.dart' as events;
import 'create_order_state.dart' as state;
import '../../../domain/entities/customer/customer.dart';
import '../product_order_key.dart';

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

  int _indexForProductCode(String productCode) {
    return _allProducts.indexWhere(
      (state.ProductOrderItemWrapper w) =>
          w.item.productOrderKey == productCode,
    );
  }

  bool _isSlaughterFromPrefs() {
    return AppType.fromCompanyCode(UserPrefs.instance.getCompany()) ==
        AppType.slaughter;
  }

  void _onInit(events.InitCreateOrder event,
      Emitter<state.CreateOrderState> emit) async {
    _allProducts = event.products
        .map((e) => state.ProductOrderItemWrapper(item: e, quantity: 0))
        .toList();

    emit(state.CreateOrderLoaded(
      products: _allProducts,
      selectedCustomer: _selectedCustomer,
      isSlaughter: _isSlaughterFromPrefs(),
    ));
  }

  void _onAddProduct(
      events.AddProductToCart event, Emitter<state.CreateOrderState> emit) {
    final int index = _indexForProductCode(event.productCode);
    if (index < 0) {
      return;
    }
    _allProducts[index] =
        _allProducts[index].copyWith(quantity: 1);
    emit(_currentLoadedState(isSubmitting: false));
  }

  void _onRemoveProduct(events.RemoveProductFromCart event,
      Emitter<state.CreateOrderState> emit) {
    final int index = _indexForProductCode(event.productCode);
    if (index < 0) {
      return;
    }
    _allProducts[index] =
        _allProducts[index].copyWith(quantity: 0);
    emit(_currentLoadedState(isSubmitting: false));
  }

  void _onUpdateQuantity(events.UpdateProductQuantity event,
      Emitter<state.CreateOrderState> emit) {
    final int index = _indexForProductCode(event.productCode);
    if (index < 0) {
      return;
    }
    final int quantity = event.quantity < 0 ? 0 : event.quantity;
    _allProducts[index] =
        _allProducts[index].copyWith(quantity: quantity);
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
      isSlaughter: _isSlaughterFromPrefs(),
    );
  }
}
