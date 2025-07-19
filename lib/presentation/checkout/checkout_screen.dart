import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/font_family.dart';
import '../../domain/entities/checkout/checkout_data.dart';
import '../../domain/entities/order/order_item.dart';
import '../../services/bluetooth_printer_service.dart';
import '../order/logics/order_bloc.dart';
import '../order/logics/order_events.dart';
import '../order/logics/order_state.dart';
import '../widgets/common/professional_header.dart';
import '../widgets/dialogs/printer_selection_dialog.dart';

class CheckoutScreen extends StatefulWidget {
  final CheckoutData checkoutData;

  const CheckoutScreen({
    super.key,
    required this.checkoutData,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _notesController = TextEditingController();
  final BluetoothPrinterService _printerService = BluetoothPrinterService();
  String? _lastOrderNumber;
  bool _isPrinting = false;

  @override
  void dispose() {
    _notesController.dispose();
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
          } else if (state is OrderOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Return to previous screen after successful order
            context.pop();
          } else if (state is OrderCreated) {
            // Save order number for printing
            _lastOrderNumber = state.order.orderNumber;
            // Show order confirmation and return
            _showOrderConfirmationDialog(context, state.order.orderNumber);
          }
        },
        child: Column(
          children: [
            // Professional Header
            ProfessionalHeaders.detail(
              title: 'Thanh Toán',
              subtitle: widget.checkoutData.customer != null 
                ? 'KH: ${widget.checkoutData.customer!.name}'
                : 'Đơn hàng lẻ',
            ),

            // Content
            Expanded(
              child: widget.checkoutData.isEmpty
                ? _buildEmptyCart()
                : _buildCheckoutContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: FontFamily.productSans,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng thêm sản phẩm vào giỏ hàng',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: FontFamily.productSans,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Quay lại đặt hàng',
              style: TextStyle(
                fontFamily: FontFamily.productSans,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutContent() {
    return Column(
      children: [
        // Cart Items Section
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Sản phẩm đã chọn', widget.checkoutData.itemCount),
                const SizedBox(height: 16),
                _buildCartItemsList(),
                
                const SizedBox(height: 24),
                
                // Customer Info Section
                if (widget.checkoutData.customer != null) ...[
                  _buildSectionHeader('Thông tin khách hàng', null),
                  const SizedBox(height: 16),
                  _buildCustomerInfo(),
                  const SizedBox(height: 24),
                ],
                
                // Notes Section
                _buildSectionHeader('Ghi chú đơn hàng', null),
                const SizedBox(height: 16),
                _buildNotesField(),
                
                const SizedBox(height: 24),
                
                // Payment Summary
                _buildSectionHeader('Tổng thanh toán', null),
                const SizedBox(height: 16),
                _buildPaymentSummary(),
              ],
            ),
          ),
        ),
        
        // Bottom Action Bar
        _buildBottomActionBar(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int? count) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
            fontFamily: FontFamily.productSans,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF059669),
                fontFamily: FontFamily.productSans,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCartItemsList() {
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.checkoutData.cartItems.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          final item = widget.checkoutData.cartItems[index];
          return _buildCartItem(item);
        },
      ),
    );
  }

  Widget _buildCartItem(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Product Image Placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.recycling,
              color: Color(0xFF059669),
              size: 30,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                    fontFamily: FontFamily.productSans,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.product.category ?? 'Chưa phân loại',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: FontFamily.productSans,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${item.unitPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                    Text(
                      ' × ${item.quantity}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF059669),
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Total Price
          Text(
            '${item.subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF059669),
              fontFamily: FontFamily.productSans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    final customer = widget.checkoutData.customer!;
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
                 children: [
           _buildInfoRow('Tên khách hàng', customer.name),
           if (customer.phone != null && customer.phone!.isNotEmpty) 
             _buildInfoRow('Số điện thoại', customer.phone!),
           if (customer.email != null && customer.email!.isNotEmpty) 
             _buildInfoRow('Email', customer.email!),
           if (customer.address != null && customer.address!.isNotEmpty) 
             _buildInfoRow('Địa chỉ', customer.address!),
         ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
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
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
                fontFamily: FontFamily.productSans,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
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
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Nhập ghi chú cho đơn hàng (không bắt buộc)',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontFamily: FontFamily.productSans,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: TextStyle(
          fontFamily: FontFamily.productSans,
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
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
        children: [
          _buildSummaryRow(
            'Tổng tiền hàng',
            '${widget.checkoutData.subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
            false,
          ),
          if (widget.checkoutData.discount > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Giảm giá',
              '-${widget.checkoutData.discount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
              false,
            ),
          ],
          if (widget.checkoutData.tax > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Thuế',
              '${widget.checkoutData.tax.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
              false,
            ),
          ],
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.grey[200],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Tổng thanh toán',
            '${widget.checkoutData.total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF1F2937) : Colors.grey[700],
            fontFamily: FontFamily.productSans,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF059669) : const Color(0xFF1F2937),
            fontFamily: FontFamily.productSans,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.grey, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Quay lại',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontFamily: FontFamily.productSans,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                final isLoading = state is OrderLoading;
                
                return ElevatedButton(
                  onPressed: isLoading ? null : _handleCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Xác nhận thanh toán',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckout() {
    context.read<OrderBloc>().add(
      CreateOrderEvent(notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
    );
  }

  void _showOrderConfirmationDialog(BuildContext context, String orderNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF059669),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Đặt hàng thành công!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
                fontFamily: FontFamily.productSans,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Đơn hàng $orderNumber đã được tạo thành công.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: FontFamily.productSans,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isPrinting ? null : () async {
                      Navigator.of(context).pop(); // Close dialog first
                      await _handlePrintReceipt();
                    },
                    icon: _isPrinting 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                          ),
                        )
                      : const Icon(Icons.print),
                    label: Text(
                      _isPrinting ? 'Đang in...' : 'In Hóa Đơn',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF059669),
                      side: const BorderSide(color: Color(0xFF059669)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      context.pop(); // Return to order screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Tiếp tục',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Handle printing receipt
  Future<void> _handlePrintReceipt() async {
    if (_lastOrderNumber == null) {
      _showMessage('Không tìm thấy thông tin đơn hàng để in');
      return;
    }

    try {
      setState(() {
        _isPrinting = true;
      });

      // Check if printer is connected
      if (!_printerService.isConnected) {
        // Show printer selection dialog
        final selectedDevice = await showDialog<BluetoothDevice>(
          context: context,
          builder: (context) => const PrinterSelectionDialog(),
        );

        if (selectedDevice == null) {
          setState(() {
            _isPrinting = false;
          });
          return;
        }
      }

      // Prepare receipt data
      final companyInfo = {
        'name': 'TrashPay',
        'address': '123 Đường ABC, Quận XYZ, TP.HCM',
        'phone': '0123 456 789',
      };

      // Convert cart items to printable format
      final printableItems = widget.checkoutData.cartItems.map((item) {
        return {
          'name': item.product.name,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'subtotal': item.subtotal,
        };
      }).toList();

      // Print the receipt
      final success = await _printerService.printReceipt(
        companyName: companyInfo['name']!,
        address: companyInfo['address']!,
        phone: companyInfo['phone']!,
        orderNumber: _lastOrderNumber!,
        orderDate: DateTime.now(),
        customerName: widget.checkoutData.customer?.name ?? 'Khách lẻ',
        items: printableItems,
        subtotal: widget.checkoutData.subtotal,
        discount: widget.checkoutData.discount,
        tax: widget.checkoutData.tax,
        total: widget.checkoutData.total,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      setState(() {
        _isPrinting = false;
      });

      if (success) {
        _showMessage('In hóa đơn thành công!', isSuccess: true);
      } else {
        _showMessage('Có lỗi xảy ra khi in hóa đơn');
      }
    } catch (e) {
      setState(() {
        _isPrinting = false;
      });
      _showMessage('Lỗi in hóa đơn: $e');
    }
  }

  /// Show message to user
  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: FontFamily.productSans,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 