import '../../../domain/entities/product/product.dart';
import '../../../domain/entities/customer/customer.dart';

abstract class CreateOrderEvent {}

class InitCreateOrder extends CreateOrderEvent {
  final List<ProductModel> products;
  InitCreateOrder(this.products);
}

class AddProductToCart extends CreateOrderEvent {
  final String productCode;
  AddProductToCart(this.productCode);
}

class RemoveProductFromCart extends CreateOrderEvent {
  final String productCode;
  RemoveProductFromCart(this.productCode);
}

class UpdateProductQuantity extends CreateOrderEvent {
  final String productCode;
  final int quantity;
  UpdateProductQuantity({required this.productCode, required this.quantity});
}

class SelectCustomerForOrder extends CreateOrderEvent {
  final CustomerModel customer;
  SelectCustomerForOrder(this.customer);
}

class SubmitCreateOrder extends CreateOrderEvent {
  final String? notes;
  SubmitCreateOrder({this.notes});
}
