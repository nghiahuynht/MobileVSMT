import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_events.dart';
import 'transaction_state.dart';
import '../../../domain/entities/transaction/transaction.dart';
import '../../../domain/entities/order/order.dart';
import '../../../domain/entities/order_history_item/order_history_item.dart';
import '../../../domain/repository/order/order_repository.dart';
import '../../../domain/domain_manager.dart';
import '../../../constants/api_config.dart';
import '../../../presentation/order/enum.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  List<TransactionModel> _allTransactions = [];
  String? _currentCustomerCode;
  int? _selectedYear;
  final OrderRepository _orderRepository;

  TransactionBloc({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? DomainManager().order,
        super(TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<LoadAllTransactionsEvent>(_onLoadAllTransactions);
    on<FilterTransactionsByTypeEvent>(_onFilterByType);
    on<FilterTransactionsByStatusEvent>(_onFilterByStatus);
    on<FilterTransactionsByDateEvent>(_onFilterByDate);
    on<FilterTransactionsByYearEvent>(_onFilterByYear);
    on<SearchTransactionsEvent>(_onSearchTransactions);
    on<ClearFiltersEvent>(_onClearFilters);
    on<RefreshTransactionsEvent>(_onRefreshTransactions);
  }

  Future<void> _onLoadTransactions(LoadTransactionsEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    _currentCustomerCode = event.customerCode;
    _selectedYear = event.year ?? DateTime.now().year;
    try {
      final items = await _orderRepository.getSaleOrderByCustomer(
        event.customerCode,
        _selectedYear!,
      );
      _allTransactions = items.map((item) => _mapOrderHistoryItemToTransaction(item)).toList();
      _allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _emitTransactionsLoaded(emit);
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onLoadAllTransactions(LoadAllTransactionsEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    _currentCustomerCode = null;
    _selectedYear = DateTime.now().year;
    try {
      final response = await _orderRepository.getSaleOrders(
        pageIndex: 1,
        pageSize: ApiConfig.defaultPageSize * 5,
      );
      _allTransactions = response.data.map(_mapOrderToTransaction).toList();
      _allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _emitTransactionsLoaded(emit);
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
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

  void _onFilterByYear(FilterTransactionsByYearEvent event, Emitter<TransactionState> emit) {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      _selectedYear = event.selectedYear;
      if (_currentCustomerCode != null && event.selectedYear != null) {
        add(LoadTransactionsEvent(_currentCustomerCode!, year: event.selectedYear));
        return;
      }
      final newState = currentState.copyWith(selectedYear: event.selectedYear);
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
      _selectedYear = DateTime.now().year;
      final newState = currentState.copyWith(
        searchQuery: '',
        clearType: true,
        clearStatus: true,
        clearDates: true,
        clearYear: true,
      );
      _emitFilteredTransactions(emit, newState);
    }
  }

  void _onRefreshTransactions(RefreshTransactionsEvent event, Emitter<TransactionState> emit) {
    if (event.customerCode != null) {
      add(LoadTransactionsEvent(event.customerCode!));
    } else {
      add(LoadAllTransactionsEvent());
    }
  }

  void _emitTransactionsLoaded(Emitter<TransactionState> emit) {
    final initialFiltered = _applyYearFilter(_allTransactions, _selectedYear);
    final stats = _calculateStatistics(initialFiltered);
    emit(TransactionsLoaded(
      allTransactions: _allTransactions,
      filteredTransactions: initialFiltered,
      customerCode: _currentCustomerCode,
      selectedYear: _selectedYear,
      totalCredit: stats['credit']!,
      totalDebit: stats['debit']!,
      balance: stats['balance']!,
      totalCount: initialFiltered.length,
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

    // Filter by customer code if specified
    if (state.customerCode != null) {
      transactions = transactions.where((t) => t.customerId == state.customerCode).toList();
    }

    // Filter by year
    transactions = _applyYearFilter(transactions, state.selectedYear);

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

  List<TransactionModel> _applyYearFilter(List<TransactionModel> transactions, int? year) {
    if (year == null) return transactions;
    return transactions.where((t) => t.createdAt.year == year).toList();
  }

  TransactionModel _mapOrderHistoryItemToTransaction(OrderHistoryItemModel item) {
    final createdAt = item.orderDate ?? DateTime.now();
    return TransactionModel(
      id: item.id?.toString() ?? '',
      customerId: _currentCustomerCode ?? '',
      customerName: '',
      amount: item.totalWithVAT ?? 0,
      type: TransactionType.deposit,
      status: _orderStatusStringToTransactionStatus(item.orderStatus),
      description: item.products ?? item.code ?? 'Đơn hàng',
      createdAt: createdAt,
      orderId: item.id?.toString(),
      reference: item.code,
      createdBy: '',
    );
  }

  TransactionModel _mapOrderToTransaction(OrderModel order) {
    final createdAt = order.orderDate ?? order.createdDate ?? DateTime.now();
    return TransactionModel(
      id: order.id.toString(),
      customerId: order.customerCode ?? '',
      customerName: order.customerName ?? '',
      amount: (order.totalWithVAT ?? 0).toDouble(),
      type: TransactionType.deposit,
      status: _orderStatusToTransactionStatus(order.orderStatus),
      description: order.note ?? order.code ?? 'Đơn hàng',
      createdAt: createdAt,
      orderId: order.id.toString(),
      reference: order.code,
      createdBy: order.saleUserFullName ?? '',
    );
  }

  TransactionStatus _orderStatusStringToTransactionStatus(String? status) {
    if (status == null) return TransactionStatus.pending;
    switch (status.toLowerCase()) {
      case 'waiting':
        return TransactionStatus.pending;
      case 'approved':
        return TransactionStatus.completed;
      case 'canceled':
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  TransactionStatus _orderStatusToTransactionStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.waiting:
        return TransactionStatus.pending;
      case OrderStatus.approved:
        return TransactionStatus.completed;
      case OrderStatus.canceled:
        return TransactionStatus.cancelled;
    }
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

} 