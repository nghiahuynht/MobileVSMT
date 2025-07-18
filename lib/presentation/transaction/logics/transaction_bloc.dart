import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_events.dart';
import 'transaction_state.dart';
import '../../../domain/entities/transaction/transaction.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  List<TransactionModel> _allTransactions = [];
  String? _currentCustomerId;

  TransactionBloc() : super(TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<LoadAllTransactionsEvent>(_onLoadAllTransactions);
    on<FilterTransactionsByTypeEvent>(_onFilterByType);
    on<FilterTransactionsByStatusEvent>(_onFilterByStatus);
    on<FilterTransactionsByDateEvent>(_onFilterByDate);
    on<SearchTransactionsEvent>(_onSearchTransactions);
    on<ClearFiltersEvent>(_onClearFilters);
    on<RefreshTransactionsEvent>(_onRefreshTransactions);
  }

  void _onLoadTransactions(LoadTransactionsEvent event, Emitter<TransactionState> emit) {
    emit(TransactionLoading());
    _currentCustomerId = event.customerId;
    
    // Generate mock data for the specific customer
    _allTransactions = _generateMockTransactions(event.customerId);
    
    _emitTransactionsLoaded(emit);
  }

  void _onLoadAllTransactions(LoadAllTransactionsEvent event, Emitter<TransactionState> emit) {
    emit(TransactionLoading());
    _currentCustomerId = null;
    
    // Generate mock data for all customers
    _allTransactions = _generateAllMockTransactions();
    
    _emitTransactionsLoaded(emit);
  }

  void _onFilterByType(FilterTransactionsByTypeEvent event, Emitter<TransactionState> emit) {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      final newState = currentState.copyWith(selectedType: event.type);
      _emitFilteredTransactions(emit, newState);
    }
  }

  void _onFilterByStatus(FilterTransactionsByStatusEvent event, Emitter<TransactionState> emit) {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      final newState = currentState.copyWith(selectedStatus: event.status);
      _emitFilteredTransactions(emit, newState);
    }
  }

  void _onFilterByDate(FilterTransactionsByDateEvent event, Emitter<TransactionState> emit) {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      final newState = currentState.copyWith(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      _emitFilteredTransactions(emit, newState);
    }
  }

  void _onSearchTransactions(SearchTransactionsEvent event, Emitter<TransactionState> emit) {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      final newState = currentState.copyWith(searchQuery: event.query);
      _emitFilteredTransactions(emit, newState);
    }
  }

  void _onClearFilters(ClearFiltersEvent event, Emitter<TransactionState> emit) {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      final newState = currentState.copyWith(
        searchQuery: '',
        clearType: true,
        clearStatus: true,
        clearDates: true,
      );
      _emitFilteredTransactions(emit, newState);
    }
  }

  void _onRefreshTransactions(RefreshTransactionsEvent event, Emitter<TransactionState> emit) {
    if (event.customerId != null) {
      add(LoadTransactionsEvent(event.customerId!));
    } else {
      add(LoadAllTransactionsEvent());
    }
  }

  void _emitTransactionsLoaded(Emitter<TransactionState> emit) {
    final stats = _calculateStatistics(_allTransactions);
    
    emit(TransactionsLoaded(
      allTransactions: _allTransactions,
      filteredTransactions: _allTransactions,
      customerId: _currentCustomerId,
      totalCredit: stats['credit']!,
      totalDebit: stats['debit']!,
      balance: stats['balance']!,
      totalCount: _allTransactions.length,
    ));
  }

  void _emitFilteredTransactions(Emitter<TransactionState> emit, TransactionsLoaded baseState) {
    final filteredTransactions = _applyFilters(baseState);
    final stats = _calculateStatistics(filteredTransactions);

    emit(baseState.copyWith(
      filteredTransactions: filteredTransactions,
      totalCredit: stats['credit']!,
      totalDebit: stats['debit']!,
      balance: stats['balance']!,
      totalCount: filteredTransactions.length,
    ));
  }

  List<TransactionModel> _applyFilters(TransactionsLoaded state) {
    var transactions = state.allTransactions;

    // Filter by customer if specified
    if (state.customerId != null) {
      transactions = transactions.where((t) => t.customerId == state.customerId).toList();
    }

    // Filter by type
    if (state.selectedType != null) {
      transactions = transactions.where((t) => t.type == state.selectedType).toList();
    }

    // Filter by status
    if (state.selectedStatus != null) {
      transactions = transactions.where((t) => t.status == state.selectedStatus).toList();
    }

    // Filter by date range
    if (state.startDate != null) {
      transactions = transactions.where((t) => 
        t.createdAt.isAfter(state.startDate!) || 
        t.createdAt.isAtSameMomentAs(state.startDate!)
      ).toList();
    }
    if (state.endDate != null) {
      final endOfDay = DateTime(state.endDate!.year, state.endDate!.month, state.endDate!.day, 23, 59, 59);
      transactions = transactions.where((t) => 
        t.createdAt.isBefore(endOfDay) || 
        t.createdAt.isAtSameMomentAs(endOfDay)
      ).toList();
    }

    // Filter by search query
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      transactions = transactions.where((t) =>
        t.description.toLowerCase().contains(query) ||
        t.customerName.toLowerCase().contains(query) ||
        t.reference?.toLowerCase().contains(query) == true ||
        t.typeDisplayName.toLowerCase().contains(query) ||
        t.statusDisplayName.toLowerCase().contains(query)
      ).toList();
    }

    // Sort by date (newest first)
    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return transactions;
  }

  Map<String, double> _calculateStatistics(List<TransactionModel> transactions) {
    double totalCredit = 0;
    double totalDebit = 0;

    for (final transaction in transactions) {
      if (transaction.status == TransactionStatus.completed) {
        if (transaction.isCredit) {
          totalCredit += transaction.amount;
        } else if (transaction.isDebit) {
          totalDebit += transaction.amount;
        }
      }
    }

    return {
      'credit': totalCredit,
      'debit': totalDebit,
      'balance': totalCredit - totalDebit,
    };
  }

  List<TransactionModel> _generateMockTransactions(String customerId) {
    final now = DateTime.now();
    final customerNames = {
      'customer_1': 'Nguyễn Văn An',
      'customer_2': 'Trần Thị Bình',
      'customer_3': 'Lê Minh Cường',
      'customer_4': 'Phạm Thị Dung',
      'customer_5': 'Hoàng Văn Em',
    };

    final customerName = customerNames[customerId] ?? 'Khách hàng';

    return [
      TransactionModel(
        id: 'txn_001',
        customerId: customerId,
        customerName: customerName,
        amount: 500000,
        type: TransactionType.deposit,
        status: TransactionStatus.completed,
        description: 'Nạp tiền vào tài khoản',
        createdAt: now.subtract(const Duration(days: 1)),
        reference: 'DEP001',
        createdBy: 'system',
      ),
      TransactionModel(
        id: 'txn_002',
        customerId: customerId,
        customerName: customerName,
        amount: 135000,
        type: TransactionType.purchase,
        status: TransactionStatus.completed,
        description: 'Mua 3x thùng rác THANG-1',
        createdAt: now.subtract(const Duration(days: 3)),
        orderId: 'order_001',
        reference: 'PUR002',
        createdBy: 'staff_001',
      ),
      TransactionModel(
        id: 'txn_003',
        customerId: customerId,
        customerName: customerName,
        amount: 90000,
        type: TransactionType.purchase,
        status: TransactionStatus.completed,
        description: 'Mua 2x thùng rác THANG-2',
        createdAt: now.subtract(const Duration(days: 7)),
        orderId: 'order_002',
        reference: 'PUR003',
        createdBy: 'staff_002',
      ),
      TransactionModel(
        id: 'txn_004',
        customerId: customerId,
        customerName: customerName,
        amount: 45000,
        type: TransactionType.refund,
        status: TransactionStatus.completed,
        description: 'Hoàn tiền đơn hàng bị hủy',
        createdAt: now.subtract(const Duration(days: 10)),
        orderId: 'order_003',
        reference: 'REF004',
        createdBy: 'manager_001',
      ),
      TransactionModel(
        id: 'txn_005',
        customerId: customerId,
        customerName: customerName,
        amount: 1000000,
        type: TransactionType.deposit,
        status: TransactionStatus.completed,
        description: 'Nạp tiền đầu tháng',
        createdAt: now.subtract(const Duration(days: 15)),
        reference: 'DEP005',
        createdBy: 'system',
      ),
      TransactionModel(
        id: 'txn_006',
        customerId: customerId,
        customerName: customerName,
        amount: 25000,
        type: TransactionType.bonus,
        status: TransactionStatus.completed,
        description: 'Thưởng khách hàng thân thiết',
        createdAt: now.subtract(const Duration(days: 20)),
        reference: 'BON006',
        createdBy: 'system',
      ),
      TransactionModel(
        id: 'txn_007',
        customerId: customerId,
        customerName: customerName,
        amount: 180000,
        type: TransactionType.purchase,
        status: TransactionStatus.pending,
        description: 'Mua 4x thùng rác THANG-3',
        createdAt: now.subtract(const Duration(hours: 2)),
        orderId: 'order_004',
        reference: 'PUR007',
        createdBy: 'staff_003',
      ),
      TransactionModel(
        id: 'txn_008',
        customerId: customerId,
        customerName: customerName,
        amount: 200000,
        type: TransactionType.withdraw,
        status: TransactionStatus.failed,
        description: 'Rút tiền không thành công',
        createdAt: now.subtract(const Duration(days: 5)),
        reference: 'WIT008',
        createdBy: 'customer',
      ),
    ];
  }

  List<TransactionModel> _generateAllMockTransactions() {
    final List<TransactionModel> allTransactions = [];
    final customerIds = ['customer_1', 'customer_2', 'customer_3', 'customer_4', 'customer_5'];
    
    for (final customerId in customerIds) {
      allTransactions.addAll(_generateMockTransactions(customerId));
    }
    
    return allTransactions;
  }
} 