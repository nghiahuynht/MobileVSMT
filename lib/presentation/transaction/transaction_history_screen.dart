import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/font_family.dart';
import '../widgets/common/professional_header.dart';
import 'logics/transaction_bloc.dart';
import 'logics/transaction_events.dart';
import 'logics/transaction_state.dart';
import '../../domain/entities/transaction/transaction.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String? customerId;
  final String? customerName;

  const TransactionHistoryScreen({
    super.key,
    this.customerId,
    this.customerName,
  });

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    if (widget.customerId != null) {
      context.read<TransactionBloc>().add(LoadTransactionsEvent(widget.customerId!));
    } else {
      context.read<TransactionBloc>().add(LoadAllTransactionsEvent());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          // if (state is TransactionError) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: Text(state.message),
          //       backgroundColor: Colors.red,
          //     ),
          //   );
          // } else 
          if (state is TransactionOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ProfessionalHeaders.detail(
      title: widget.customerId != null 
        ? 'Lịch sử thu tiền'
        : 'Tất cả thu tiền',
      subtitle: widget.customerName ?? 'Quản lý lịch sử thu tiền hệ thống',
      onBackPressed: () => Navigator.pop(context),
      actionWidget: IconButton(
        onPressed: () {
          if (widget.customerId != null) {
            context.read<TransactionBloc>().add(RefreshTransactionsEvent(customerId: widget.customerId));
          } else {
            context.read<TransactionBloc>().add(RefreshTransactionsEvent());
          }
        },
        icon: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
            ),
          );
        }

        if (state is TransactionsLoaded) {
          // Lọc chỉ các giao dịch thu tiền (credit transactions)
          final creditTransactions = state.allTransactions.where((t) => t.isCredit).toList();
          final filteredCreditTransactions = _filterTransactionsByYear(creditTransactions);
          
          return Column(
            children: [
              // Statistics Section
              _buildStatistics(filteredCreditTransactions),
              
              // Filters and Search
              _buildFiltersAndSearch(state, filteredCreditTransactions),
              
              // Transaction List
              Expanded(
                child: _buildTransactionList(filteredCreditTransactions),
              ),
            ],
          );
        }

        return const Center(
          child: Text('Không có dữ liệu'),
        );
      },
    );
  }

  List<TransactionModel> _filterTransactionsByYear(List<TransactionModel> transactions) {
    if (_selectedYear == null) return transactions;
    return transactions.where((t) => t.createdAt.year == _selectedYear).toList();
  }

  Widget _buildStatistics(List<TransactionModel> transactions) {
    final totalAmount = transactions.fold<double>(0, (sum, t) => sum + t.amount);
    final totalCount = transactions.length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Thống kê thu tiền',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.productSans,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tổng thu',
                  totalAmount,
                  const Color(0xFF059669),
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Số giao dịch',
                  totalCount.toDouble(),
                  const Color(0xFF3B82F6),
                  Icons.receipt_long,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Trung bình',
                  totalCount > 0 ? totalAmount / totalCount : 0,
                  const Color(0xFF8B5CF6),
                  Icons.analytics,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Năm ${_selectedYear ?? "Tất cả"}',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: FontFamily.productSans,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title == 'Số giao dịch' 
              ? value.toInt().toString()
              : '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: FontFamily.productSans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch(TransactionsLoaded state, List<TransactionModel> filteredTransactions) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Bar
          Container(
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
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<TransactionBloc>().add(SearchTransactionsEvent(value));
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm giao dịch thu tiền...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: FontFamily.productSans,
                ),
                prefixIcon: Icon(Icons.search_outlined, color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Year Filter
          Row(
            children: [
              Expanded(
                child: _buildYearFilter(),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Trạng thái',
                state.selectedStatus != null,
                () => _showStatusFilter(context, state),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearFilter() {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);
    
    return Container(
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
        value: _selectedYear,
        decoration: InputDecoration(
          hintText: 'Chọn năm',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontFamily: FontFamily.productSans,
          ),
          prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items: [
          const DropdownMenuItem<int>(
            value: null,
            child: Text('Tất cả năm'),
          ),
          ...years.map((year) => DropdownMenuItem<int>(
            value: year,
            child: Text(year.toString()),
          )),
        ],
        onChanged: (value) {
          setState(() {
            _selectedYear = value;
          });
        },
        style: TextStyle(
          fontFamily: FontFamily.productSans,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : Colors.grey[300]!,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF059669).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: FontFamily.productSans,
          ),
        ),
      ),
    );
  }

  Widget _buildClearFiltersButton() {
    return GestureDetector(
      onTap: () {
        _searchController.clear();
        setState(() {
          _selectedYear = DateTime.now().year;
        });
        context.read<TransactionBloc>().add(ClearFiltersEvent());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear, size: 14, color: Colors.red[600]),
            const SizedBox(width: 4),
            Text(
              'Xóa bộ lọc',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: FontFamily.productSans,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có giao dịch thu tiền',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: FontFamily.productSans,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi bộ lọc hoặc năm',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontFamily: FontFamily.productSans,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final statusColor = _getStatusColor(transaction.status);
    
    return Container(
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
            // Header row
            Row(
              children: [
                // Type icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getTypeIcon(transaction.type),
                    color: const Color(0xFF059669),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Transaction info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.typeDisplayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                      Text(
                        transaction.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Amount and status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+${transaction.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
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
                        transaction.statusDisplayName,
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
            
            // Details row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          transaction.customerName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: FontFamily.productSans,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(transaction.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            if (transaction.reference != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.tag, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Mã: ${transaction.reference}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.add_circle_outline;
      case TransactionType.refund:
        return Icons.refresh;
      case TransactionType.bonus:
        return Icons.star_outline;
      default:
        return Icons.payment;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return const Color(0xFFF59E0B);
      case TransactionStatus.completed:
        return const Color(0xFF059669);
      case TransactionStatus.failed:
        return const Color(0xFFDC2626);
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showStatusFilter(BuildContext context, TransactionsLoaded state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lọc theo trạng thái',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: FontFamily.productSans,
              ),
            ),
            const SizedBox(height: 16),
            ...TransactionStatus.values.map((status) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(
                _getStatusDisplayName(status),
                style: TextStyle(
                  fontFamily: FontFamily.productSans,
                ),
              ),
              trailing: state.selectedStatus == status 
                ? const Icon(Icons.check, color: Color(0xFF059669))
                : null,
              onTap: () {
                context.read<TransactionBloc>().add(
                  FilterTransactionsByStatusEvent(
                    state.selectedStatus == status ? null : status
                  )
                );
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<TransactionBloc>().add(FilterTransactionsByStatusEvent(null));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  elevation: 0,
                ),
                child: Text(
                  'Xóa bộ lọc trạng thái',
                  style: TextStyle(
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDisplayName(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Chờ xử lý';
      case TransactionStatus.completed:
        return 'Hoàn thành';
      case TransactionStatus.failed:
        return 'Thất bại';
      case TransactionStatus.cancelled:
        return 'Đã hủy';
    }
  }
} 