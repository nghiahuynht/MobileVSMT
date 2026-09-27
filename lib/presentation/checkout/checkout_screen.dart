import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/constants/colors.dart';
import 'package:trash_pay/constants/enums/app_type_enum.dart';
import 'package:trash_pay/constants/font_family.dart';
import 'package:trash_pay/domain/entities/checkout/checkout_request.dart';
import 'package:trash_pay/domain/entities/meta_data/arrear.dart';
import 'package:trash_pay/domain/entities/meta_data/payment_type.dart';
import 'package:trash_pay/domain/entities/order/order.dart';
import 'package:trash_pay/domain/entities/order/order_item.dart';
import 'package:trash_pay/presentation/app/app_bloc_extension.dart';
import 'package:trash_pay/presentation/checkout/logics/checkout_cubit.dart';
import 'package:trash_pay/presentation/home/home_screen.dart';
import 'package:trash_pay/presentation/order/enum.dart';
import 'package:trash_pay/utils/extension.dart';
import '../../domain/entities/checkout/checkout_data.dart';
import '../widgets/common/professional_header.dart';

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
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController>? _trashLinePriceControllers;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTrashLinePriceControllers();
  }

  @override
  void dispose() {
    _notesController.dispose();
    if (_trashLinePriceControllers != null) {
      for (final TextEditingController c in _trashLinePriceControllers!) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _syncTrashLinePriceControllers() {
    final int itemCount = widget.checkoutData.cartItems.length;
    if (context.appType != AppType.trash) {
      if (_trashLinePriceControllers != null) {
        for (final TextEditingController c in _trashLinePriceControllers!) {
          c.dispose();
        }
        _trashLinePriceControllers = null;
      }
      return;
    }
    _trashLinePriceControllers ??= <TextEditingController>[];
    while (_trashLinePriceControllers!.length < itemCount) {
      final int index = _trashLinePriceControllers!.length;
      final OrderItemModel item = widget.checkoutData.cartItems[index];
      final num defaultLine = (item.priceWithVAT ?? 0) * item.quantity;
      final String digitString =
          defaultLine > 0 ? defaultLine.toStringAsFixed(0) : '';
      final String initialText = digitString.isEmpty
          ? ''
          : _VietnameseThousandsInputFormatter.formatDigits(digitString);
      _trashLinePriceControllers!
          .add(TextEditingController(text: initialText));
    }
    while (_trashLinePriceControllers!.length > itemCount) {
      final TextEditingController removed =
          _trashLinePriceControllers!.removeLast();
      removed.dispose();
    }
  }

  double? _parseMoneyInput(String raw) {
    final String normalized =
        raw.replaceAll('.', '').replaceAll(',', '').trim();
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  List<OrderItemModel> _resolveCartItemsForCheckout(BuildContext context) {
    if (context.appType != AppType.trash) {
      return widget.checkoutData.cartItems;
    }
    final List<TextEditingController>? controllers =
        _trashLinePriceControllers;
    if (controllers == null ||
        controllers.length != widget.checkoutData.cartItems.length) {
      return widget.checkoutData.cartItems;
    }
    return List<OrderItemModel>.generate(
      widget.checkoutData.cartItems.length,
      (int index) {
        final OrderItemModel item = widget.checkoutData.cartItems[index];
        final double lineTotal = _parseMoneyInput(controllers[index].text) ?? 0;
        final int quantity = item.quantity > 0 ? item.quantity : 1;
        final double unitWithVat = lineTotal / quantity;
        final num vatPercent = item.vat ?? 0;
        // Làm tròn về đồng: tránh giá chưa VAT lẻ (vd 20.000 / 1.01 = 19.801,98...)
        // làm lệch tiền VAT khi lưu đơn / xuất hoá đơn điện tử.
        final double unitNoVat = vatPercent > 0
            ? (unitWithVat / (1 + vatPercent.toDouble() / 100)).roundToDouble()
            : unitWithVat;
        return item.copyWith(
          priceWithVAT: unitWithVat,
          priceNoVAT: unitNoVat,
          total: lineTotal,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocProvider(
        create: (context) =>
            CheckoutCubit()..selectArrear(context.arrears.first)..selectPaymentType(context.paymentTypes.first),
        child: BlocBuilder<CheckoutCubit, CheckoutState>(
            builder: (context, state) {
          return Column(
            children: [
              // Professional Header
              BlocBuilder<CheckoutCubit, CheckoutState>(
                buildWhen: (previous, current) => previous.isSuccess != current.isSuccess,
                builder: (context, state) {
                  return ProfessionalHeaders.detail(
                    title: 'Thanh Toán',
                    onBackPressed: () {
                      if (state.isSuccess) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const HomePage()),
                          (route) => true,
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    subtitle: widget.checkoutData.customer != null
                        ? 'KH: ${widget.checkoutData.customer!.name}'
                        : 'Đơn hàng lẻ',
                  );
                }
              ),
          
              // Content
              Expanded(
                child: widget.checkoutData.isEmpty
                    ? _buildEmptyCart()
                    : _buildCheckoutContent(),
              ),
            ],
          );
        }),
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
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      buildWhen: (previous, current) => previous.isLoading != current.isLoading,
      builder: (context, state) {
        return Column(
          children: [
            // Cart Items Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: IgnorePointer(
                  ignoring: state.isSuccess,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                          'Sản phẩm đã chọn', widget.checkoutData.totalQuantity),
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
                          
                      _buildPaymentInfo(),
                          
                      const SizedBox(height: 24),
                          
                      // Payment Summary
                      _buildSectionHeader('Tổng thanh toán', null),
                      const SizedBox(height: 16),
                      _buildPaymentSummary(),
                    ],
                  ),
                ),
              ),
            ),
        
            // Bottom Action Bar
            _buildBottomActionBar(),
          ],
        );
      }
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
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
        padding: EdgeInsets.zero,
        itemCount: widget.checkoutData.cartItems.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          final OrderItemModel item = widget.checkoutData.cartItems[index];
          return _buildCartItem(context, item, index);
        },
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, OrderItemModel item, int index) {
    final bool isTrashApp = context.appType == AppType.trash;
    if (isTrashApp) {
      final List<TextEditingController>? controllers =
          _trashLinePriceControllers;
      if (controllers == null || index >= controllers.length) {
        return const SizedBox.shrink();
      }
      final TextEditingController lineController = controllers[index];
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  if (item.quantity > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '× ${item.quantity}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: TextField(
                controller: lineController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  _VietnameseThousandsInputFormatter(),
                ],
                onChanged: (_) => setState(() {}),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Thành tiền',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontFamily: FontFamily.productSans,
                  ),
                  suffixText: 'đ',
                  suffixStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontFamily: FontFamily.productSans,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                ),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontFamily: FontFamily.productSans,
                ),
              ),
            ),
          ],
        ),
      );
    }
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
                    if (item.quantity > 0)
                      Text(
                        ' × ${item.quantity}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${((item.priceWithVAT ?? 0) * item.quantity).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
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
          _buildInfoRow('Tên khách hàng', customer.name ?? ''),
          if (customer.phone != null && customer.phone!.isNotEmpty)
            _buildInfoRow('Số điện thoại', customer.phone!),
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
    final List<OrderItemModel> itemsForTotals =
        _resolveCartItemsForCheckout(context);
    final double subtotal = itemsForTotals.fold<double>(
        0, (double sum, OrderItemModel item) => sum + (item.priceNoVAT ?? 0) * item.quantity);
    final double total = itemsForTotals.fold<double>(
        0, (double sum, OrderItemModel item) => sum + (item.priceWithVAT ?? 0) * item.quantity);

    final vat = total - subtotal;

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
            '${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
            false,
          ),
          // if (widget.checkoutData.discount > 0) ...[
          //   const SizedBox(height: 12),
          //   _buildSummaryRow(
          //     'Giảm giá',
          //     '-${widget.checkoutData.discount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
          //     false,
          //   ),
          // ],
          if (vat > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              'VAT',
              '${vat.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
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
            '${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          BlocBuilder<CheckoutCubit, CheckoutState>(
              buildWhen: (previous, current) =>
                  previous.arrearSelected != current.arrearSelected,
              builder: (context, s) {
                return _buildDropdownField<Arrear>(
                  label: 'Loại thu',
                  hint: 'Chọn loại thu',
                  icon: Icons.account_balance_wallet_outlined,
                  value: s.arrearSelected,
                  items: context.arrears,
                  isLoading: false,
                  onChanged: (value) async {
                    if (value != null) {
                      context.read<CheckoutCubit>().selectArrear(value);
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn loại thu';
                    }
                    return null;
                  },
                  itemBuilder: (item) => item.label ?? '',
                );
              }),
          const SizedBox(height: 12),
          BlocBuilder<CheckoutCubit, CheckoutState>(
              buildWhen: (previous, current) =>
                  previous.paymentTypeSelected !=
                  current.paymentTypeSelected,
              builder: (context, s) {
                return _buildDropdownField<PaymentType>(
                  label: 'Phương thức thanh toán',
                  hint: 'Chọn PT than toán',
                  icon: Icons.payment,
                  value: s.paymentTypeSelected,
                  items: context.paymentTypes,
                  isLoading: false,
                  onChanged: (value) async {},
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn phương thức thanh toán';
                    }
                    return null;
                  },
                  itemBuilder: (item) => item.label ?? '',
                );
              }),
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
            color: isTotal ? AppColors.primary : const Color(0xFF1F2937),
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
      child: BlocBuilder<CheckoutCubit, CheckoutState>(
        builder: (context, state) {
          final isLoading = state.isLoading;
          final isSuccess = state.isSuccess;

          if (isSuccess) {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => true,
                    ),
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
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      final List<OrderItemModel> itemsForPrint =
                          _resolveCartItemsForCheckout(context);
                      final double totalWithVat = itemsForPrint.fold<double>(
                          0,
                          (double sum, OrderItemModel item) =>
                              sum + (item.priceWithVAT ?? 0) * item.quantity);
                      final double totalNoVat = itemsForPrint.fold<double>(
                          0,
                          (double sum, OrderItemModel item) =>
                              sum + (item.priceNoVAT ?? 0) * item.quantity);
                      context.read<CheckoutCubit>().printReceipt(
                            OrderModel(
                              id: 0,
                              orderStatus: OrderStatus.waiting,
                              isDeleted: false,
                              customerAddress: widget.checkoutData.customer?.address,
                              customerCode: widget.checkoutData.customer?.code,
                              customerName: widget.checkoutData.customer?.name,
                              taxAddress: widget.checkoutData.customer?.taxAddress,
                              paymentName: state.paymentTypeSelected?.label,
                              totalWithVAT: totalWithVat,
                              totalNoVAT: totalNoVat,
                              totalVAT: totalWithVat - totalNoVat,
                              orderDate: DateTime.now(),
                              createdDate: DateTime.now(),
                              createdBy: context.userCode,
                              saleUserCode: context.userCode,
                              saleUserFullName: context.userFullName,
                              arrears: state.arrearSelected?.code,
                              note: _notesController.text.trim().isEmpty
                                  ? null
                                  : _notesController.text.trim(),
                              lstSaleOrderItem: itemsForPrint,
                            ),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'In hoá đơn',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: FontFamily.productSans,
                            ),
                          ),
                  ),
                ),
              ],
            );
          }

          return ElevatedButton(
            onPressed: isLoading ? null : () => _handleCheckout(context, state),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Align(
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
                      'Tạo hoá đơn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required IconData icon,
    required T? value,
    required List<T> items,
    required bool isLoading,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    String Function(T)? itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontFamily: FontFamily.productSans,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: isLoading ? 'Đang tải...' : hint,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 16,
              fontFamily: FontFamily.productSans,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          items: isLoading
              ? []
              : items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      itemBuilder != null ? itemBuilder(item) : item.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: FontFamily.productSans,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
          onChanged: isLoading ? null : onChanged,
          validator: validator,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontFamily: FontFamily.productSans,
          ),
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  void _handleCheckout(BuildContext context, CheckoutState state) {
    bool isValidate = _formKey.currentState!.validate();

    if (isValidate) {
      context.read<CheckoutCubit>().createOrder(
            CheckoutRequest(
              customerCode: widget.checkoutData.customer?.code,
              arrears: state.arrearSelected?.code,
              paymentType: state.paymentTypeSelected?.code,
              saleUserCode: context.userCode,
              note: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              lstSaleOrderItem: _resolveCartItemsForCheckout(context),
              orderDate: DateTime.now().getDateString(),
              createdBy: context.userCode,
              // customerAddress: widget.checkoutData.customer?.address,
            ).toMap(), context
          );
    }
  }

  // void _showOrderConfirmationDialog(BuildContext context, String orderNumber) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: AppColors.primary.withOpacity(0.1),
  //               shape: BoxShape.circle,
  //             ),
  //             child: const Icon(
  //               Icons.check_circle_outline,
  //               color: AppColors.primary,
  //               size: 48,
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           Text(
  //             'Đặt hàng thành công!',
  //             style: TextStyle(
  //               fontSize: 20,
  //               fontWeight: FontWeight.bold,
  //               color: const Color(0xFF1F2937),
  //               fontFamily: FontFamily.productSans,
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           Text(
  //             'Đơn hàng $orderNumber đã được tạo thành công.',
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               fontSize: 16,
  //               color: Colors.grey[600],
  //               fontFamily: FontFamily.productSans,
  //             ),
  //           ),
  //           const SizedBox(height: 24),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: OutlinedButton.icon(
  //                   onPressed: _isPrinting ? null : () async {
  //                     Navigator.of(context).pop(); // Close dialog first
  //                     await _handlePrintReceipt();
  //                   },
  //                   icon: _isPrinting
  //                     ? const SizedBox(
  //                         width: 16,
  //                         height: 16,
  //                         child: CircularProgressIndicator(
  //                           strokeWidth: 2,
  //                           valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
  //                         ),
  //                       )
  //                     : const Icon(Icons.print),
  //                   label: Text(
  //                     _isPrinting ? 'Đang in...' : 'In Hóa Đơn',
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.w600,
  //                       fontFamily: FontFamily.productSans,
  //                     ),
  //                   ),
  //                   style: OutlinedButton.styleFrom(
  //                     foregroundColor: AppColors.primary,
  //                     side: const BorderSide(color: AppColors.primary),
  //                     padding: const EdgeInsets.symmetric(vertical: 12),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.of(context).pop(); // Close dialog
  //                     context.pop(); // Return to order screen
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: AppColors.primary,
  //                     foregroundColor: Colors.white,
  //                     padding: const EdgeInsets.symmetric(vertical: 12),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: Text(
  //                     'Tiếp tục',
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.w600,
  //                       fontFamily: FontFamily.productSans,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // /// Handle printing receipt
  // Future<void> _handlePrintReceipt() async {
  //   if (_lastOrderNumber == null) {
  //     _showMessage('Không tìm thấy thông tin đơn hàng để in');
  //     return;
  //   }

  //   try {
  //     setState(() {
  //       _isPrinting = true;
  //     });

  //     // Check if printer is connected
  //     if (!_printerService.isConnected) {
  //       // Show printer selection dialog
  //       final selectedDevice = await showDialog<BluetoothDevice>(
  //         context: context,
  //         builder: (context) => const PrinterSelectionDialog(),
  //       );

  //       if (selectedDevice == null) {
  //         setState(() {
  //           _isPrinting = false;
  //         });
  //         return;
  //       }
  //     }

  //     // Prepare receipt data
  //     final companyInfo = {
  //       'name': 'TrashPay',
  //       'address': '123 Đường ABC, Quận XYZ, TP.HCM',
  //       'phone': '0123 456 789',
  //     };

  //     // Convert cart items to printable format
  //     final printableItems = widget.checkoutData.cartItems.map((item) {
  //       return {
  //         'name': item.product.name,
  //         'quantity': item.quantity,
  //         'unitPrice': item.unitPrice,
  //         'subtotal': item.subtotal,
  //       };
  //     }).toList();

  //     // Print the receipt
  //     final success = await _printerService.printReceipt(
  //       companyName: companyInfo['name']!,
  //       address: companyInfo['address']!,
  //       phone: companyInfo['phone']!,
  //       orderNumber: _lastOrderNumber!,
  //       orderDate: DateTime.now(),
  //       customerName: widget.checkoutData.customer?.name ?? 'Khách lẻ',
  //       items: printableItems,
  //       subtotal: widget.checkoutData.subtotal,
  //       discount: widget.checkoutData.discount,
  //       tax: widget.checkoutData.tax,
  //       total: widget.checkoutData.total,
  //       notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
  //     );

  //     setState(() {
  //       _isPrinting = false;
  //     });

  //     if (success) {
  //       _showMessage('In hóa đơn thành công!', isSuccess: true);
  //     } else {
  //       _showMessage('Có lỗi xảy ra khi in hóa đơn');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isPrinting = false;
  //     });
  //     _showMessage('Lỗi in hóa đơn: $e');
  //   }
  // }

  // /// Show message to user
  // void _showMessage(String message, {bool isSuccess = false}) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           Icon(
  //             isSuccess ? Icons.check_circle : Icons.error,
  //             color: Colors.white,
  //             size: 20,
  //           ),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             child: Text(
  //               message,
  //               style: TextStyle(
  //                 fontFamily: FontFamily.productSans,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       backgroundColor: isSuccess ? Colors.green : Colors.red,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //     ),
  //   );
  // }
}

/// Formats integer digits with `.` every thousands (e.g. 160000 → 160.000).
class _VietnameseThousandsInputFormatter extends TextInputFormatter {
  const _VietnameseThousandsInputFormatter();

  static String formatDigits(String digitsOnly) {
    if (digitsOnly.isEmpty) {
      return '';
    }
    final StringBuffer buffer = StringBuffer();
    final int length = digitsOnly.length;
    final int firstGroupLength = length % 3 == 0 ? 3 : length % 3;
    buffer.write(digitsOnly.substring(0, firstGroupLength));
    int position = firstGroupLength;
    while (position < length) {
      buffer.write('.');
      buffer.write(digitsOnly.substring(position, position + 3));
      position += 3;
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String newDigits =
        newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newDigits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final String formatted = formatDigits(newDigits);
    final int digitsBeforeCaret = newValue.selection.baseOffset <= 0
        ? 0
        : newValue.text
            .substring(0, newValue.selection.baseOffset.clamp(0, newValue.text.length))
            .replaceAll(RegExp(r'[^0-9]'), '')
            .length;
    final int caretOffset =
        _offsetAfterDigitIndex(formatted, digitsBeforeCaret);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: caretOffset),
    );
  }

  static int _offsetAfterDigitIndex(String formatted, int digitCount) {
    if (digitCount <= 0) {
      return 0;
    }
    int seen = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (formatted.codeUnitAt(i) != 0x2E) {
        seen++;
        if (seen >= digitCount) {
          return i + 1;
        }
      }
    }
    return formatted.length;
  }
}
