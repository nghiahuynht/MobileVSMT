import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/order_history_item/order_history_item.dart';
import '../../../domain/repository/order/order_repository.dart';
import '../../../domain/domain_manager.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final OrderRepository _orderRepository;
  final String _customerCode;
  List<OrderHistoryItemModel> _allItems = [];
  int? _selectedYear;

  OrderHistoryCubit({
    required String customerCode,
    OrderRepository? orderRepository,
  })  : _customerCode = customerCode,
        _orderRepository = orderRepository ?? DomainManager().order,
        super(OrderHistoryInitial());

  Future<void> loadOrderHistory() async {
    emit(OrderHistoryLoading());
    _selectedYear = DateTime.now().year;
    await _fetchAndEmit();
  }

  Future<void> refresh() async {
    if (state is OrderHistoryLoaded) {
      await _fetchAndEmit();
    } else {
      await loadOrderHistory();
    }
  }

  Future<void> setYear(int? year) async {
    _selectedYear = year;
    if (year != null) {
      emit(OrderHistoryLoading());
      try {
        final items = await _orderRepository.getSaleOrderByCustomer(
          _customerCode,
          year,
        );
        _allItems = items;
        _allItems.sort(
          (a, b) =>
              (b.orderDate ?? DateTime(0)).compareTo(a.orderDate ?? DateTime(0)),
        );
        _emitFiltered();
      } catch (e) {
        emit(OrderHistoryError(e.toString()));
      }
    } else {
      if (_allItems.isEmpty) return;
      _emitFiltered();
    }
  }

  Future<void> _fetchAndEmit() async {
    try {
      final year = _selectedYear ?? DateTime.now().year;
      final items = await _orderRepository.getSaleOrderByCustomer(
        _customerCode,
        year,
      );
      _allItems = items;
      _allItems.sort(
        (a, b) =>
            (b.orderDate ?? DateTime(0)).compareTo(a.orderDate ?? DateTime(0)),
      );
      _emitFiltered();
    } catch (e) {
      emit(OrderHistoryError(e.toString()));
    }
  }

  void _emitFiltered() {
    final filtered = _applyYearFilter(_allItems, _selectedYear);
    final totalAmount = filtered.fold<double>(
      0,
      (sum, item) => sum + (item.totalWithVAT ?? 0),
    );
    emit(OrderHistoryLoaded(
      allItems: _allItems,
      filteredItems: filtered,
      selectedYear: _selectedYear,
      totalAmount: totalAmount,
      totalCount: filtered.length,
    ));
  }

  List<OrderHistoryItemModel> _applyYearFilter(
    List<OrderHistoryItemModel> items,
    int? year,
  ) {
    if (year == null) return List.from(items);
    return items.where((i) => i.orderDate?.year == year).toList();
  }
}
