import '../customer/customer.dart';
import '../order/order_item.dart';

class CheckoutData {
  final List<OrderItemModel> cartItems;
  final CustomerModel? customer;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;

  const CheckoutData({
    required this.cartItems,
    this.customer,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
  });

  CheckoutData copyWith({
    List<OrderItemModel>? cartItems,
    CustomerModel? customer,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
  }) {
    return CheckoutData(
      cartItems: cartItems ?? this.cartItems,
      customer: customer ?? this.customer,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
    );
  }

  bool get isEmpty => cartItems.isEmpty;
  int get itemCount => cartItems.where((item) => item.quantity > 0).length;
} 