import '../../../domain/entities/transaction/transaction.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionsLoaded extends TransactionState {
  final List<TransactionModel> allTransactions;
  final List<TransactionModel> filteredTransactions;
  final String searchQuery;
  final TransactionType? selectedType;
  final TransactionStatus? selectedStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? customerId;

  // Statistics
  final double totalCredit;
  final double totalDebit;
  final double balance;
  final int totalCount;

  TransactionsLoaded({
    required this.allTransactions,
    required this.filteredTransactions,
    this.searchQuery = '',
    this.selectedType,
    this.selectedStatus,
    this.startDate,
    this.endDate,
    this.customerId,
    required this.totalCredit,
    required this.totalDebit,
    required this.balance,
    required this.totalCount,
  });

  TransactionsLoaded copyWith({
    List<TransactionModel>? allTransactions,
    List<TransactionModel>? filteredTransactions,
    String? searchQuery,
    TransactionType? selectedType,
    TransactionStatus? selectedStatus,
    DateTime? startDate,
    DateTime? endDate,
    String? customerId,
    double? totalCredit,
    double? totalDebit,
    double? balance,
    int? totalCount,
    bool clearType = false,
    bool clearStatus = false,
    bool clearDates = false,
  }) {
    return TransactionsLoaded(
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      customerId: customerId ?? this.customerId,
      totalCredit: totalCredit ?? this.totalCredit,
      totalDebit: totalDebit ?? this.totalDebit,
      balance: balance ?? this.balance,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  bool get hasFilters {
    return selectedType != null ||
           selectedStatus != null ||
           startDate != null ||
           endDate != null ||
           searchQuery.isNotEmpty;
  }

  Map<TransactionType, int> get transactionsByType {
    final map = <TransactionType, int>{};
    for (final transaction in filteredTransactions) {
      map[transaction.type] = (map[transaction.type] ?? 0) + 1;
    }
    return map;
  }

  Map<TransactionStatus, int> get transactionsByStatus {
    final map = <TransactionStatus, int>{};
    for (final transaction in filteredTransactions) {
      map[transaction.status] = (map[transaction.status] ?? 0) + 1;
    }
    return map;
  }
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}

class TransactionOperationSuccess extends TransactionState {
  final String message;
  TransactionOperationSuccess(this.message);
} 