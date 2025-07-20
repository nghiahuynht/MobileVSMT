import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/services/receipt_printer_service.dart';
import '../../constants/font_family.dart';
import '../../domain/entities/order/order.dart';
import '../../domain/entities/order/order_item.dart';
import 'logics/order_bloc.dart';
import 'logics/order_events.dart';
import 'logics/order_state.dart';
import 'order_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  OrderStatus? _selectedStatus;
  bool _showFilter = false;

  @override
  void initState() {
    super.initState();
    // Load orders when screen initializes
    context.read<OrderBloc>().add(LoadOrdersEvent());
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
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
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
            // Header
            _buildHeader(),
            
            // Search and Filter Section
            _buildSearchAndFilterSection(),
            
            // Order List
            Expanded(
              child: _buildOrderList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => OrderBloc(),
                child: const OrderScreen(),
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danh sách đơn hàng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                  Text(
                    'Quản lý và theo dõi đơn hàng',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _showFilter = !_showFilter;
                });
              },
              icon: Icon(
                _showFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                context.read<OrderBloc>().add(SearchOrdersEvent(value));
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đơn hàng...',
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
          
          // Filter Section
          if (_showFilter) ...[
            const SizedBox(height: 16),
            _buildFilterSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            'Lọc theo trạng thái',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: FontFamily.productSans,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Tất cả', null),
              _buildFilterChip('Đã duyệt', OrderStatus.confirmed),
              _buildFilterChip('Đã hủy', OrderStatus.cancelled),
              _buildFilterChip('Hoàn thành', OrderStatus.completed),
              _buildFilterChip('Chờ xác nhận', OrderStatus.pending),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, OrderStatus? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontFamily: FontFamily.productSans,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
        context.read<OrderBloc>().add(FilterOrdersByStatusEvent(status));
      },
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF059669),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF059669) : Colors.grey[300]!,
        width: 1,
      ),
    );
  }

  Widget _buildOrderList() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
            ),
          );
        }

        if (state is OrderListState) {
          if (state.filteredOrders.isEmpty) {
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
                    'Không có đơn hàng nào',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                  if (state.searchQuery.isNotEmpty || _selectedStatus != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Thử thay đổi bộ lọc hoặc tìm kiếm',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.filteredOrders.length,
            itemBuilder: (context, index) {
              final order = state.filteredOrders[index];
              return _buildOrderCard(order);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to order detail
            _showOrderDetail(order);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with order number and status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đơn hàng #${order.orderNumber}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: FontFamily.productSans,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tạo lúc: ${_formatDateTime(order.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: FontFamily.productSans,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(order.status),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Customer info
                if (order.customer != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.customer!.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontFamily: FontFamily.productSans,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Order summary
                Row(
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${order.itemCount} sản phẩm',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Tổng: ${_formatCurrency(order.total)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF059669),
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case OrderStatus.confirmed:
        backgroundColor = const Color(0xFF059669);
        textColor = Colors.white;
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.cancelled:
        backgroundColor = const Color(0xFFDC2626);
        textColor = Colors.white;
        icon = Icons.cancel_outlined;
        break;
      case OrderStatus.completed:
        backgroundColor = const Color(0xFF0EA5E9);
        textColor = Colors.white;
        icon = Icons.done_all;
        break;
      case OrderStatus.pending:
        backgroundColor = const Color(0xFFF59E0B);
        textColor = Colors.white;
        icon = Icons.schedule;
        break;
      case OrderStatus.processing:
        backgroundColor = const Color(0xFF8B5CF6);
        textColor = Colors.white;
        icon = Icons.pending;
        break;
      case OrderStatus.draft:
        backgroundColor = Colors.grey[300]!;
        textColor = Colors.grey[700]!;
        icon = Icons.edit_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusDisplayName(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
              fontFamily: FontFamily.productSans,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ';
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return 'Đang soạn thảo';
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  Widget _buildPrintButton(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF059669),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPrintOptions(order),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.print_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPrintOptions(OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Chọn loại hóa đơn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nút in hóa đơn đầy đủ
                  _buildPrintOptionButton(
                    title: 'Hóa đơn đầy đủ',
                    subtitle: 'In chi tiết tất cả thông tin',
                    icon: Icons.receipt_long,
                    onTap: () {
                      Navigator.pop(context);
                      _printFullReceipt(order);
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Nút in hóa đơn đơn giản
                  _buildPrintOptionButton(
                    title: 'Hóa đơn đơn giản',
                    subtitle: 'In thông tin cơ bản',
                    icon: Icons.receipt,
                    onTap: () {
                      Navigator.pop(context);
                      _printSimpleReceipt(order);
                    },
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintOptionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _printFullReceipt(OrderModel order) async {
    _showPrintingDialog();
    
    try {
      final printerService = ReceiptPrinterService();
      final success = await printerService.printReceipt(order);
      
      Navigator.pop(context); // Đóng dialog in
      
      if (success) {
        _showSuccessMessage('In hóa đơn thành công!');
      } else {
        _showErrorMessage('Lỗi khi in hóa đơn. Vui lòng kiểm tra máy in.');
      }
    } catch (e) {
      Navigator.pop(context); // Đóng dialog in
      _showErrorMessage('Lỗi: $e');
    }
  }

  Future<void> _printSimpleReceipt(OrderModel order) async {
    _showPrintingDialog();
    
    try {
      final printerService = ReceiptPrinterService();
      final success = await printerService.printSimpleReceipt(order);
      
      Navigator.pop(context); // Đóng dialog in
      
      if (success) {
        _showSuccessMessage('In hóa đơn đơn giản thành công!');
      } else {
        _showErrorMessage('Lỗi khi in hóa đơn. Vui lòng kiểm tra máy in.');
      }
    } catch (e) {
      Navigator.pop(context); // Đóng dialog in
      _showErrorMessage('Lỗi: $e');
    }
  }

  void _showPrintingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
            ),
            const SizedBox(width: 16),
            Text(
              'Đang in hóa đơn...',
              style: TextStyle(
                fontFamily: FontFamily.productSans,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showOrderDetail(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderDetailSheet(order),
    );
  }

  Widget _buildOrderDetailSheet(OrderModel order) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn hàng #${order.orderNumber}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tạo lúc: ${_formatDateTime(order.createdAt)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _buildStatusChip(order.status),
                    const SizedBox(height: 8),
                    _buildPrintButton(order),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer info
                  if (order.customer != null) ...[
                    Text(
                      'Thông tin khách hàng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Tên', order.customer!.name),
                    if (order.customer!.phone != null)
                      _buildInfoRow('SĐT', order.customer!.phone!),
                    if (order.customer!.address != null)
                      _buildInfoRow('Địa chỉ', order.customer!.address!),
                    const SizedBox(height: 20),
                  ],
                  
                  // Order items
                  Text(
                    'Sản phẩm (${order.itemCount})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => _buildOrderItemTile(item)),
                  
                  const SizedBox(height: 20),
                  
                  // Order summary
                  Text(
                    'Tổng kết',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Tổng tiền hàng', order.subtotal),
                  if (order.discount > 0)
                    _buildSummaryRow('Giảm giá', -order.discount),
                  if (order.tax > 0)
                    _buildSummaryRow('Thuế', order.tax),
                  const Divider(),
                  _buildSummaryRow('Tổng thanh toán', order.total, isTotal: true),
                  
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Ghi chú',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontFamily: FontFamily.productSans,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontFamily: FontFamily.productSans,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: FontFamily.productSans,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} x ${_formatCurrency(item.unitPrice)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(item.subtotal),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF059669),
              fontFamily: FontFamily.productSans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
                fontFamily: FontFamily.productSans,
              ),
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF059669) : Colors.grey[800],
              fontFamily: FontFamily.productSans,
            ),
          ),
        ],
      ),
    );
  }
} 