import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/constants/colors.dart';
import 'package:trash_pay/constants/strings.dart';
import 'package:trash_pay/presentation/order/enum.dart';
import 'package:trash_pay/presentation/order_detail/logics/order_detail_bloc.dart';
import 'package:trash_pay/presentation/order_detail/logics/order_detail_events.dart';
import 'package:trash_pay/presentation/order_detail/logics/order_detail_state.dart';
import 'package:trash_pay/presentation/widgets/common_circular_progess_indicator.dart';
import 'package:trash_pay/services/receipt_printer_service.dart';
import '../../constants/font_family.dart';
import '../../domain/entities/order/order.dart';
import '../../domain/entities/order/order_item.dart';
import '../widgets/common/professional_header.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocProvider(
        create: (BuildContext ctx) =>
            OrderDetailBloc(order)..add(const LoadOrderDetailEvent()),
        child: BlocListener<OrderDetailBloc, OrderDetailState>(
          listener: (context, state) {
            if (state is OrderDetailError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: const Text('Đã có lỗi xảy ra'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Column(
            children: [
              // Header - sử dụng BlocBuilder để cập nhật real-time
              BlocBuilder<OrderDetailBloc, OrderDetailState>(
                builder: (context, state) {
                  return _buildHeader(context, state.order);
                },
              ),

              // Content với loading state
              Expanded(
                child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
                  builder: (context, state) {
                    if (state is OrderDetailLoading) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            XCircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Đang tải thông tin đơn hàng...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Customer info
                                  Text(
                                    'Thông tin chi tiết',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: FontFamily.productSans,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                      'Tên KH',
                                      state.order.customerName ??
                                          Strings.defaultEmpty),
                                  _buildInfoRow(
                                      'Mã KH',
                                      state.order.customerCode ??
                                          Strings.defaultEmpty),
                                  if (state.order.taxAddress != null)
                                    _buildInfoRow(
                                        'Địa chỉ',
                                        state.order.taxAddress ??
                                            Strings.defaultEmpty),
                                  _buildInfoRow(
                                      'Hình thức thanh toán',
                                      state.order.paymentName ??
                                          Strings.defaultEmpty),
                                  _buildInfoRow(
                                      'Truy thu',
                                      state.order.arrearsName ??
                                          Strings.defaultEmpty),
                                  const SizedBox(height: 20),

                                  // Order items
                                  Text(
                                    'Sản phẩm (${state.order.itemCount})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: FontFamily.productSans,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
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
                                    child: Column(
                                      children: state.order.lstSaleOrderItem
                                          .map((item) => _buildCartItem(item))
                                          .toList(),
                                    ),
                                  ),

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
                                  _buildSummaryRow('Tổng tiền hàng',
                                      state.order.totalNoVAT?.toDouble() ?? 0),
                                  _buildSummaryRow('Thuế',
                                      state.order.totalVAT?.toDouble() ?? 0),
                                  const Divider(),
                                  _buildSummaryRow('Tổng thanh toán',
                                      state.order.totalWithVAT?.toDouble() ?? 0,
                                      isTotal: true),

                                  if (state.order.note != null &&
                                      state.order.note!.isNotEmpty) ...[
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
                                        state.order.note!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          fontFamily: FontFamily.productSans,
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(
                                    height: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (state.order.orderStatus != OrderStatus.canceled)
                            Row(
                              children: [
                                if (state.order.orderStatus ==
                                    OrderStatus.waiting) ...[
                                  Expanded(
                                      child: _buildCancelButton(
                                          context, state.order)),
                                  const SizedBox(
                                    width: 5,
                                  )
                                ],
                                Expanded(
                                    child: _buildPrintButton(
                                        context, state.order)),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OrderModel order) {
    return ProfessionalHeaders.detail(
      title: '#${order.code ?? Strings.defaultEmpty}',
      subtitle: 'Tạo lúc: ${_formatDateTime(order.createdDate)}',
      onBackPressed: () => Navigator.pop(context),
      actionWidget: _buildStatusChip(order.orderStatus),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color textColor = Colors.white;

    if (status == OrderStatus.waiting) {
      textColor = Colors.grey[700]!;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusDisplayName(status),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor,
              fontFamily: FontFamily.productSans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, OrderModel order) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          _cancelOrder(context, order);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626),
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(
            color: Colors.white,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cancel_outlined,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Huỷ hoá đơn',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: FontFamily.productSans,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintButton(BuildContext context, OrderModel order) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          _printFullReceipt(context, order);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.primary,
          // foregroundColor: const Color(0xFF0EA5E9),
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(
            color: Colors.white,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.print_outlined,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'In hoá đơn',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: FontFamily.productSans,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printFullReceipt(BuildContext context, OrderModel order) async {
    _showPrintingDialog(context);

    try {
      final printerService = ReceiptPrinterService();
      final success = await printerService.printReceipt(order);

      Navigator.pop(context); // Đóng dialog in

      if (success) {
        _showSuccessMessage(context, 'In hóa đơn thành công!');
      } else {
        _showErrorMessage(
            context, 'Lỗi khi in hóa đơn. Vui lòng kiểm tra máy in.');
      }
    } catch (e) {
      Navigator.pop(context); // Đóng dialog in
      _showErrorMessage(context, 'Lỗi: $e');
    }
  }

  void _showPrintingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
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

  Widget _buildCartItem(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                    fontFamily: FontFamily.productSans,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${(item.priceNoVAT ?? 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                    // if (item.quantity > 0)
                    //   Text(
                    //     ' × ${item.quantity}',
                    //     style: TextStyle(
                    //       fontSize: 14,
                    //       fontWeight: FontWeight.w600,
                    //       color: AppColors.primary,
                    //       fontFamily: FontFamily.productSans,
                    //     ),
                    //   ),
                  ],
                ),
              ],
            ),
          ),

          // Total Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(item.quantity > 0 ? (item.priceWithVAT ?? 0) : 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: FontFamily.productSans,
                ),
              ),
              if (item.vat != null) ...[
                const SizedBox(height: 2),
                Text(
                  '(VAT: ${item.vat}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ]
            ],
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
              color: isTotal ? AppColors.primary : Colors.grey[800],
              fontFamily: FontFamily.productSans,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return Strings.defaultEmpty;
    }

    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double? amount) {
    if (amount == null) {
      return Strings.defaultEmpty;
    }

    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ';
  }

  String _getStatusDisplayName(OrderStatus status) {
    return status.statusDisplayName;
  }

  void _cancelOrder(BuildContext context, OrderModel order) async {
    final result = await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận huỷ hoá đơn'),
        content: const Text('Bạn có chắc chắn muốn huỷ hoá đơn này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Quay về'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Huỷ'),
          ),
        ],
      ),
    );

    if (result == true) {
      context.read<OrderDetailBloc>().add(CancelOrderEvent(order));
    }
  }
}
