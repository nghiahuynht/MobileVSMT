import '../../../domain/entities/product/product.dart';
import '../../../domain/entities/customer/customer.dart';

abstract class CreateOrderEvent {}

class InitCreateOrder extends CreateOrderEvent {
  final List<ProductModel> products;
  InitCreateOrder(this.products);
}
class AddProductToCart extends CreateOrderEvent {
  final int index;
  AddProductToCart(this.index);
}
class RemoveProductFromCart extends CreateOrderEvent {
   final int index;
  RemoveProductFromCart(this.index);
}
class UpdateProductQuantity extends CreateOrderEvent {
  final ProductModel product;
  final int quantity;
  UpdateProductQuantity(this.product, this.quantity);
}
class SelectCustomerForOrder extends CreateOrderEvent {
  final CustomerModel customer;
  SelectCustomerForOrder(this.customer);
}
class SubmitCreateOrder extends CreateOrderEvent {
  final String? notes;
  SubmitCreateOrder({this.notes});
} 