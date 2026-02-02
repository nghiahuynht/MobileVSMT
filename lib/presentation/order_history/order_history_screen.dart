import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/entities/order_history_item/order_history_item.dart';
import 'package:trash_pay/domain/entities/order/order.dart';
import 'package:trash_pay/presentation/order/enum.dart';
import 'package:trash_pay/presentation/order_detail/order_detail_screen.dart';
import '../../constants/font_family.dart';
import '../widgets/common/professional_header.dart';
import 'logics/order_history_cubit.dart';
import 'logics/order_history_state.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String customerCode;
  final String? customerName;

  const OrderHistoryScreen({
    super.key,
    required this.customerCode,
    this.customerName,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderHistoryCubit>().loadOrderHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocListener<OrderHistoryCubit, OrderHistoryState>(
        listener: (context, state) {
          if (state is OrderHistoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ProfessionalHeaders.detail(
      title: 'Lịch sử đơn hàng',
      subtitle: widget.customerName ?? widget.customerCode,
      onBackPressed: () => Navigator.pop(context),
      actionWidget: IconButton(
        onPressed: () {
          context.read<OrderHistoryCubit>().refresh();
        },
        icon: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
      builder: (context, state) {
        if (state is OrderHistoryLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
            ),
          );
        }
        if (state is OrderHistoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (state is OrderHistoryLoaded) {
          return Column(
            children: [
              const SizedBox(height: 16),
              _buildYearFilter(state),
              Expanded(child: _buildOrderList(state.filteredItems)),
            ],
          );
        }
        return const Center(child: Text('Không có dữ liệu'));
      },
    );
  }

  Widget _buildYearFilter(OrderHistoryLoaded state) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: state.selectedYear,
        decoration: InputDecoration(
          hintText: 'Chọn năm',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontFamily: FontFamily.productSans,
          ),
          prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: [
          const DropdownMenuItem<int>(value: null, child: Text('Tất cả năm')),
          ...years.map(
            (year) => DropdownMenuItem<int>(
              value: year,
              child: Text(year.toString()),
            ),
          ),
        ],
        onChanged: (value) {
          context.read<OrderHistoryCubit>().setYear(value);
        },
        style: TextStyle(
          fontFamily: FontFamily.productSans,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderHistoryItemModel> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có đơn hàng',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: FontFamily.productSans,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildOrderCard(OrderHistoryItemModel order) {
    final statusColor = _getOrderStatusColor(order.orderStatus);
    final orderDate = order.orderDate ?? DateTime.now();
    return GestureDetector(
      onTap: () => _openOrderDetail(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFF059669),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.code ?? '—',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                      Text(
                        order.products ?? '—',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(order.totalWithVAT ?? 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF059669),
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        order.orderStatusName ?? order.orderStatus ?? '—',
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(orderDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  void _openOrderDetail(OrderHistoryItemModel item) {
    if (item.id == null) return;
    final minimalOrder = OrderModel(
      id: item.id!,
      code: item.code,
      orderDate: item.orderDate,
      orderStatus: OrderStatus.fromMap(item.orderStatus ?? 'waiting'),
      isDeleted: false,
      lstSaleOrderItem: [],
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => OrderDetailScreen(order: minimalOrder),
      ),
    );
  }

  Color _getOrderStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'waiting':
        return const Color(0xFFF59E0B);
      case 'approved':
        return const Color(0xFF059669);
      case 'canceled':
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${date.day}/${date.month}/${date.year}';
  }
}
