import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/presentation/customer/logics/customer_bloc.dart';
import 'package:trash_pay/presentation/customer/logics/customer_events.dart';
import 'package:trash_pay/presentation/customer/logics/customer_state.dart';
import 'package:trash_pay/presentation/transaction/transaction_history_screen.dart';
import 'package:trash_pay/presentation/transaction/logics/transaction_bloc.dart';
import 'package:trash_pay/presentation/widgets/common/professional_header.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CustomerDetailScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerBloc(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8F9FA),
                Color(0xFFE9ECEF),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Professional Header
                ProfessionalHeaders.detail(
                  title: 'Chi Tiết Khách Hàng',
                  subtitle: 'Thông tin và lịch sử giao dịch',
                  actionWidget: PopupMenuButton(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.more_vert_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleMenuAction(context, value),
                  ),
                ),
                
                // Customer Detail Content
                Expanded(
                  child: BlocConsumer<CustomerBloc, CustomerState>(
                    listener: (context, state) {
                      if (state is CustomerOperationSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: const Color(0xFF059669),
                          ),
                        );
                        // Go back after delete success
                        if (state.message.contains('xóa')) {
                          Navigator.of(context).pop();
                        }
                      } else if (state is CustomerError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: const Color(0xFFDC2626),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return _buildCustomerDetailContent(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCustomerDetailContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Customer Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getAvatarColors(customer.status),
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: _getAvatarColors(customer.status)[0].withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Name and Status
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                _buildStatusBadge(customer.status),
                
                if (customer.createdAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Khách hàng từ ${DateFormat('dd/MM/yyyy').format(customer.createdAt!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Contact Information
          _buildInfoSection(
            'Thông Tin Liên Hệ',
            [
              if (customer.phone != null)
                _buildInfoItem(Icons.phone_outlined, 'Số điện thoại', customer.phone!, 
                  onTap: () {
                    // TODO: Open phone dialer
                  }),
              if (customer.email != null)
                _buildInfoItem(Icons.email_outlined, 'Email', customer.email!,
                  onTap: () {
                    // TODO: Open email client
                  }),
              if (customer.address != null)
                _buildInfoItem(Icons.location_on_outlined, 'Địa chỉ', customer.address!,
                  onTap: () {
                    // TODO: Open maps
                  }),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Financial Information
          _buildInfoSection(
            'Thông Tin Tài Chính',
            [
              if (customer.totalSpent != null)
                _buildInfoItem(
                  Icons.account_balance_wallet_outlined, 
                  'Tổng chi tiêu', 
                  NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(customer.totalSpent)
                ),
              _buildInfoItem(
                Icons.history_outlined, 
                'Lần thanh toán cuối', 
                customer.createdAt != null 
                    ? DateFormat('dd/MM/yyyy HH:mm').format(customer.createdAt!)
                    : 'Chưa có giao dịch'
              ),
              _buildInfoItem(
                Icons.trending_up_outlined, 
                'Trạng thái tài khoản', 
                _getAccountStatusText(customer.status)
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Transaction History Section
          _buildTransactionHistory(context),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          _buildActionButtons(context),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(String title, List<Widget> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTransactionHistory(BuildContext context) {
    // Mock transaction data
    final transactions = [
      {
        'id': 'TXN001',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'amount': 450000,
        'description': 'Thu gom rác sinh hoạt',
        'status': 'completed'
      },
      {
        'id': 'TXN002', 
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'amount': 320000,
        'description': 'Thu gom rác tái chế',
        'status': 'completed'
      },
      {
        'id': 'TXN003',
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'amount': 680000,
        'description': 'Thu gom rác công nghiệp',
        'status': 'completed'
      },
    ];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Lịch Sử Giao Dịch',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => TransactionBloc(),
                        child: TransactionHistoryScreen(
                          customerId: customer.id,
                          customerName: customer.name,
                        ),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0EA5E9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...transactions.map((transaction) => _buildTransactionItem(transaction)).toList(),
        ],
      ),
    );
  }
  
  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 18,
              color: Color(0xFF059669),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd/MM/yyyy').format(transaction['date']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction['amount']),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Contact Customer Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _showContactOptions(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.contact_phone_outlined, size: 18),
                SizedBox(width: 8),
                Text(
                  'Liên Hệ Khách Hàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Create New Order Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              context.go('/order', extra: customer);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0EA5E9),
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(
                color: Color(0xFF0EA5E9),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_shopping_cart_outlined, size: 18),
                SizedBox(width: 8),
                Text(
                  'Tạo Đơn Hàng Mới',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String text;
    
    switch (status) {
      case 'active':
        backgroundColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF059669);
        text = 'Hoạt động';
        break;
      case 'inactive':
        backgroundColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        text = 'Không hoạt động';
        break;
      case 'pending':
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        text = 'Chờ xử lý';
        break;
      default:
        backgroundColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        text = 'Không xác định';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
  
  List<Color> _getAvatarColors(String status) {
    switch (status) {
      case 'active':
        return [const Color(0xFF059669), const Color(0xFF10B981)];
      case 'inactive':
        return [const Color(0xFFDC2626), const Color(0xFFEF4444)];
      case 'pending':
        return [const Color(0xFFD97706), const Color(0xFFF59E0B)];
      default:
        return [const Color(0xFF64748B), const Color(0xFF94A3B8)];
    }
  }
  
  String _getAccountStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Tài khoản tốt';
      case 'inactive':
        return 'Tài khoản tạm ngưng';
      case 'pending':
        return 'Đang xem xét';
      default:
        return 'Chưa xác định';
    }
  }
  
  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit customer screen
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa khách hàng "${customer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CustomerBloc>().add(DeleteCustomerEvent(customer.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
  
  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Liên hệ khách hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            if (customer.phone != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF059669),
                    size: 20,
                  ),
                ),
                title: const Text('Gọi điện'),
                subtitle: Text(customer.phone!),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open phone dialer
                },
              ),
            if (customer.email != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF0EA5E9),
                    size: 20,
                  ),
                ),
                title: const Text('Gửi email'),
                subtitle: Text(customer.email!),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open email client
                },
              ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.message_outlined,
                  color: Color(0xFF7C3AED),
                  size: 20,
                ),
              ),
              title: const Text('Gửi tin nhắn'),
              subtitle: const Text('Gửi thông báo trong app'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Send in-app message
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 