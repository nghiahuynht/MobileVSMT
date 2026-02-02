import '../../../domain/entities/order_history_item/order_history_item.dart';

abstract class OrderHistoryState {}

class OrderHistoryInitial extends OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

class OrderHistoryLoaded extends OrderHistoryState {
  final List<OrderHistoryItemModel> allItems;
  final List<OrderHistoryItemModel> filteredItems;
  final int? selectedYear;
  final double totalAmount;
  final int totalCount;

  OrderHistoryLoaded({
    required this.allItems,
    required this.filteredItems,
    this.selectedYear,
    required this.totalAmount,
    required this.totalCount,
  });

  double get averageAmount =>
      totalCount > 0 ? totalAmount / totalCount : 0;
}

class OrderHistoryError extends OrderHistoryState {
  final String message;
  OrderHistoryError(this.message);
}
