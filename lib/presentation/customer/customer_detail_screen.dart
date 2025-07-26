import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/constants/strings.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/presentation/add_customer_screen/add_customer_screen.dart';
import 'package:trash_pay/presentation/customer/logics/customer_bloc.dart';
import 'package:trash_pay/presentation/customer/logics/customer_state.dart';
import 'package:trash_pay/presentation/widgets/common/professional_header.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trash_pay/utils/extension.dart';

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
          child: Column(
            children: [
              // Professional Header
              ProfessionalHeaders.detail(
                title: 'Chi Tiết Khách Hàng',
                actionWidget: InkWell(
                  onTap: () => _handleMenuAction(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
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
                        context.pop();
                      }
                    } else if (state is CustomerError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã có lỗi xảy ra'),
                          backgroundColor: Color(0xFFDC2626),
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
                      colors: _getAvatarColors(null),
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: _getAvatarColors(null)[0].withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (customer.name?.isNotEmpty ?? false)
                          ? customer.name![0].toUpperCase()
                          : 'U',
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
                  customer.name ?? Strings.defaultEmpty,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),

                if (customer.code != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Mã KH: ${customer.code}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],

                if (customer.createdDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Khách hàng từ ${customer.createdDate!.toDDMMYYY()}',
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
                _buildInfoItem(
                  Icons.phone_outlined,
                  'Số điện thoại',
                  customer.phone!,
                ),
              if (customer.address != null)
                _buildInfoItem(
                  Icons.home_outlined,
                  'Địa chỉ',
                  customer.address!,
                ),
              if (customer.provinceCode != null)
                _buildInfoItem(
                  Icons.location_city_outlined,
                  'Tỉnh/Thành phố',
                  customer.provinceCode!,
                ),
              if (customer.wardCode != null)
                _buildInfoItem(
                  Icons.place_outlined,
                  'Phường/Xã',
                  customer.wardCode!,
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Location Information
          _buildInfoSection(
            'Thông Tin Khu Vực',
            [
              if (customer.areaSaleName != null)
                _buildInfoItem(
                    Icons.explore_outlined, 'Khu vực', customer.areaSaleName!),
              if (customer.routeSaleName != null)
                _buildInfoItem(
                    Icons.route_outlined, 'Tuyến', customer.routeSaleName!),
            ],
          ),

          const SizedBox(height: 20),

          // Service Information
          _buildInfoSection(
            'Thông Tin Dịch Vụ',
            [
              if (customer.customerGroupName != null)
                _buildInfoItem(Icons.group_outlined, 'Loại hình kinh doanh',
                    customer.customerGroupName!),
              if (customer.oldPrice != null)
                _buildInfoItem(
                    Icons.attach_money_outlined,
                    'Giá dịch vụ cũ',
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                        .format(customer.oldPrice)),
              if (customer.currentPrice != null)
                _buildInfoItem(
                    Icons.attach_money_outlined,
                    'Giá dịch vụ hiện tại',
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                        .format(customer.currentPrice)),
              if (customer.price != null)
                _buildInfoItem(
                    Icons.attach_money_outlined,
                    'Giá dịch vụ',
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                        .format(customer.price)),
            ],
          ),

          const SizedBox(height: 20),

          // // Transaction History Section
          // _buildTransactionHistory(context),

          // const SizedBox(height: 20),

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

  Widget _buildInfoItem(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
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

  // Widget _buildTransactionHistory(BuildContext context) {
  //   // Mock transaction data - using customer's service price if available
  //   final basePrice = customer.price ?? 300000; // Default price if not set
  //   final transactions = [
  //     {
  //       'id': 'TXN001',
  //       'date': DateTime.now().subtract(const Duration(days: 2)),
  //       'amount': basePrice,
  //       'description': 'Thu gom rác sinh hoạt',
  //       'status': 'completed'
  //     },
  //     {
  //       'id': 'TXN002',
  //       'date': DateTime.now().subtract(const Duration(days: 15)),
  //       'amount': basePrice * 0.8, // Discount for regular customers
  //       'description': 'Thu gom rác tái chế',
  //       'status': 'completed'
  //     },
  //     {
  //       'id': 'TXN003',
  //       'date': DateTime.now().subtract(const Duration(days: 30)),
  //       'amount': basePrice * 1.2, // Premium service
  //       'description': 'Thu gom rác công nghiệp',
  //       'status': 'completed'
  //     },
  //   ];

  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: const Color(0xFFE2E8F0),
  //         width: 1,
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             const Text(
  //               'Lịch Sử Giao Dịch',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w700,
  //                 color: Color(0xFF1E293B),
  //               ),
  //             ),
  //             const Spacer(),
  //             if (transactions.isNotEmpty)
  //               TextButton(
  //                 onPressed: () {
  //                   context.go('/transaction-history', extra: {
  //                     'customerId': customer.id,
  //                     'customerName': customer.name,
  //                   });
  //                 },
  //                 child: const Text(
  //                   'Xem tất cả',
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: Color(0xFF0EA5E9),
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         if (transactions.isEmpty)
  //           _buildEmptyTransactionState()
  //         else
  //           ...transactions
  //               .map((transaction) => _buildTransactionItem(transaction))
  //               .toList(),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildTransactionItem(Map<String, dynamic> transaction) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 12),
  //     decoration: BoxDecoration(
  //       border: Border(
  //         bottom: BorderSide(
  //           color: Colors.grey.shade200,
  //           width: 1,
  //         ),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF0FDF4),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: const Icon(
  //             Icons.check_circle_outline,
  //             size: 18,
  //             color: Color(0xFF059669),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 transaction['description'],
  //                 style: const TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w600,
  //                   color: Color(0xFF1E293B),
  //                 ),
  //               ),
  //               const SizedBox(height: 2),
  //               Text(
  //                 DateFormat('dd/MM/yyyy').format(transaction['date']),
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   color: Colors.grey.shade600,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Text(
  //           NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
  //               .format(transaction['amount']),
  //           style: const TextStyle(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w700,
  //             color: Color(0xFF059669),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildEmptyTransactionState() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
  //     child: Column(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF8FAFC),
  //             borderRadius: BorderRadius.circular(50),
  //           ),
  //           child: Icon(
  //             Icons.receipt_long_outlined,
  //             size: 40,
  //             color: Colors.grey.shade400,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Text(
  //           'Chưa có giao dịch',
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w600,
  //             color: Colors.grey.shade700,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           'Khách hàng này chưa có giao dịch nào.\nHãy tạo đơn hàng đầu tiên!',
  //           style: TextStyle(
  //             fontSize: 14,
  //             color: Colors.grey.shade600,
  //             height: 1.4,
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildActionButtons(BuildContext context) {

    bool hasPhone = customer.phone != null;

    return Column(
      children: [
        // Contact Customer Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasPhone
                ? () {
                    _showContactOptions(context);
                  }
                : null,
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

  List<Color> _getAvatarColors(String? status) {
    // Default status-based colors
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

  void _handleMenuAction(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddCustomerScreen(
          customer: customer,
        ),
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Liên hệ khách hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
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
                  context.pop();
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
