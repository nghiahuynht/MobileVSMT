abstract class HomeEvents {}

class PayWithStripeCardEvent extends HomeEvents {
  final double amount;
  final String currency;

  PayWithStripeCardEvent({required this.amount, required this.currency});
}
