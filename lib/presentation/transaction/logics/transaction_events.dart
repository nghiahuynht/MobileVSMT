import '../../../domain/entities/transaction/transaction.dart';

abstract class TransactionEvent {}

// Load transactions for a customer
class LoadTransactionsEvent extends TransactionEvent {
  final String customerCode;
  final int? year;
  LoadTransactionsEvent(this.customerCode, {this.year});
}

// Load all transactions (for admin view)
class LoadAllTransactionsEvent extends TransactionEvent {}

// Filter transactions by type
class FilterTransactionsByTypeEvent extends TransactionEvent {
  final TransactionType? type;
  FilterTransactionsByTypeEvent(this.type);
}

// Filter transactions by status
class FilterTransactionsByStatusEvent extends TransactionEvent {
  final TransactionStatus? status;
  FilterTransactionsByStatusEvent(this.status);
}

// Filter transactions by date range
class FilterTransactionsByDateEvent extends TransactionEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  FilterTransactionsByDateEvent({
    this.startDate,
    this.endDate,
  });
}

// Filter transactions by year
class FilterTransactionsByYearEvent extends TransactionEvent {
  final int? selectedYear;
  FilterTransactionsByYearEvent(this.selectedYear);
}

// Search transactions
class SearchTransactionsEvent extends TransactionEvent {
  final String query;
  SearchTransactionsEvent(this.query);
}

// Clear all filters
class ClearFiltersEvent extends TransactionEvent {}

// Refresh transactions
class RefreshTransactionsEvent extends TransactionEvent {
  final String? customerCode;
  RefreshTransactionsEvent({this.customerCode});
} 