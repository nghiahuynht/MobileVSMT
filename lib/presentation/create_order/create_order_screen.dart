import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/constants/colors.dart';
import 'package:trash_pay/constants/enums/app_type_enum.dart';
import 'package:trash_pay/domain/entities/order/order_item.dart';
import 'package:trash_pay/presentation/app/logics/app_bloc.dart';
import 'package:trash_pay/presentation/app/logics/app_state.dart';
import 'package:trash_pay/presentation/checkout/checkout_screen.dart';
import 'package:trash_pay/presentation/create_order/logics/create_order_bloc.dart';
import 'package:trash_pay/presentation/create_order/logics/create_order_events.dart'
    as events;
import 'package:trash_pay/presentation/create_order/logics/create_order_state.dart'
    as state;
import 'package:trash_pay/presentation/create_order/product_order_key.dart';
import 'package:trash_pay/utils/utils.dart';
import '../../constants/font_family.dart';
import '../../domain/entities/customer/customer.dart';
import '../../domain/entities/checkout/checkout_data.dart';
import '../../domain/entities/product/product.dart';
import '../../presentation/widgets/common/professional_header.dart';

class ProductList extends StatefulWidget {
  final CustomerModel customer;
  final List<ProductModel> products;

  const ProductList({
    super.key,
    required this.customer,
    required this.products,
  });

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context
        .read<CreateOrderBloc>()
        .add(events.InitCreateOrder(widget.products));

    context
        .read<CreateOrderBloc>()
        .add(events.SelectCustomerForOrder(widget.customer));
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
      body: BlocListener<CreateOrderBloc, state.CreateOrderState>(
        listener: (context, s) {
          if (s is state.CreateOrderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tạo đơn hàng thành công!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTotal(),
            const SizedBox(
              height: 18,
            ),
            Expanded(
              child: _buildProductList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildCartFab(),
    );
  }

  Widget _buildTotal() {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return BlocBuilder<CreateOrderBloc, state.CreateOrderState>(
          builder: (context, createOrderState) {
            if (createOrderState is state.CreateOrderLoaded) {
              final List<InlineSpan> spans = <InlineSpan>[];
              if (appState.appType == AppType.slaughter) {
                spans.add(
                  TextSpan(
                    text: 'Tổng SL: ${createOrderState.totalUnitCount}   ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                );
              }
              spans.addAll(<InlineSpan>[
                const TextSpan(text: 'Tổng tiền: '),
                TextSpan(
                  text: Utils.formatCurrency(createOrderState.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ]);
              return Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text.rich(TextSpan(children: spans)),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return ProfessionalHeaders.list(
      title: 'Đặt hàng',
      subtitle: 'Chọn sản phẩm để thêm vào đơn hàng',
      onBackPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
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
    );
  }

  Widget _buildProductList() {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return BlocBuilder<CreateOrderBloc, state.CreateOrderState>(
          builder: (context, s) {
            if (s is state.CreateOrderLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (s is state.CreateOrderLoaded) {
              final List<state.ProductOrderItemWrapper> products = s.products
                  .where((state.ProductOrderItemWrapper e) =>
                      e.item.name
                          ?.toLowerCase()
                          .contains(_searchController.text.toLowerCase()) ??
                      false)
                  .toList();
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy sản phẩm',
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
                padding:
                    const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                itemCount: products.length,
                itemBuilder: (BuildContext context, int index) {
                  final state.ProductOrderItemWrapper product = products[index];
                  return _buildProductCard(product, appState.appType);
                },
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildProductCard(
    state.ProductOrderItemWrapper product,
    AppType appType,
  ) {
    final String productKey = product.item.productOrderKey;
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.item.name ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.item.code ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                      if (product.item.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.item.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontFamily: FontFamily.productSans,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          child: Center(
                            child: Text(
                              product.isSelected ? 'Đã chọn' : 'Chưa chọn',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontFamily.productSans,
                                color: product.isSelected
                                    ? AppColors.primary
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        _toggleButton(
                          isSelected: product.isSelected,
                          onTap: () {
                            if (product.isSelected) {
                              context.read<CreateOrderBloc>().add(
                                    events.RemoveProductFromCart(productKey),
                                  );
                            } else {
                              context.read<CreateOrderBloc>().add(
                                    events.AddProductToCart(productKey),
                                  );
                            }
                          },
                        )
                      ],
                    ),
                    if (product.item.unitCode != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${_unitPriceForDisplay(product, appType).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.')} đ/${product.item.unitCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (appType == AppType.slaughter && product.isSelected) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: _SlaughterQuantityEditor(product: product),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCartFab() {
    return BlocBuilder<CreateOrderBloc, state.CreateOrderState>(
      builder: (context, s) {
        if (s is state.CreateOrderLoaded && s.isSelected) {
          return FloatingActionButton.extended(
            onPressed: () => _navigateToCheckout(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            label: Text(
              'Tạo đơn thu',
              style: TextStyle(
                fontFamily: FontFamily.productSans,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.shopping_cart),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _navigateToCheckout(BuildContext context) {
    final state.CreateOrderState currentState =
        context.read<CreateOrderBloc>().state;
    if (currentState is state.CreateOrderLoaded && currentState.isSelected) {
      final bool isSlaughter = currentState.isSlaughter;
      final List<OrderItemModel> cartItems = currentState.products
          .where((state.ProductOrderItemWrapper e) => e.isSelected)
          .map(
            (state.ProductOrderItemWrapper e) {
              final num unit = currentState.lineUnitPrice(e);
              final num withVat = unit + (e.item.vat ?? 0);
              return OrderItemModel(
                quantity: e.quantity,
                productCode: e.item.code,
                productName: e.item.name,
                unitCode: e.item.unitCode,
                priceNoVAT: unit,
                vat: e.item.vat,
                priceWithVAT: withVat,
              );
            },
          )
          .toList();

      final List<OrderItemModel> pricedForCheckout = isSlaughter
          ? cartItems
          : cartItems
              .map(
                (OrderItemModel e) => e.copyWith(
                  priceNoVAT: widget.customer.currentPrice ?? 0,
                  priceWithVAT: widget.customer.currentPrice ?? 0,
                ),
              )
              .toList();

      final CheckoutData checkoutData = CheckoutData(
        cartItems: pricedForCheckout,
        customer: currentState.selectedCustomer,
        subtotal: currentState.subtotal,
        total: currentState.total,
      );

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              CheckoutScreen(checkoutData: checkoutData),
        ),
      );
    }
  }

  /// Giá hiển thị trên thẻ sản phẩm (đồng bộ với [CreateOrderLoaded.lineUnitPrice]).
  num _unitPriceForDisplay(
    state.ProductOrderItemWrapper product,
    AppType appType,
  ) {
    if (appType == AppType.slaughter) {
      return product.item.priceSale ?? 0;
    }
    return widget.customer.currentPrice ?? 0;
  }

  Widget _toggleButton({
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[400]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            isSelected ? Icons.check : Icons.add,
            color: isSelected ? Colors.white : Colors.grey[600],
            size: 16,
          ),
        ),
      ),
    );
  }
}

class _SlaughterQuantityEditor extends StatefulWidget {
  final state.ProductOrderItemWrapper product;

  const _SlaughterQuantityEditor({required this.product});

  @override
  State<_SlaughterQuantityEditor> createState() =>
      _SlaughterQuantityEditorState();
}

class _SlaughterQuantityEditorState extends State<_SlaughterQuantityEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: '${widget.product.quantity}');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _SlaughterQuantityEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.quantity != oldWidget.product.quantity &&
        !_focusNode.hasFocus) {
      _controller.text = '${widget.product.quantity}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _applyParsedQuantity(BuildContext context) {
    final String key = widget.product.item.productOrderKey;
    final int? parsed = int.tryParse(_controller.text.trim());
    if (parsed == null) {
      _controller.text = '${widget.product.quantity}';
      return;
    }
    if (parsed <= 0) {
      context.read<CreateOrderBloc>().add(
            events.RemoveProductFromCart(key),
          );
      return;
    }
    context.read<CreateOrderBloc>().add(
          events.UpdateProductQuantity(
            productCode: key,
            quantity: parsed,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final String key = widget.product.item.productOrderKey;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          onPressed: () {
            final int next = widget.product.quantity - 1;
            if (next <= 0) {
              context.read<CreateOrderBloc>().add(
                    events.RemoveProductFromCart(key),
                  );
            } else {
              context.read<CreateOrderBloc>().add(
                    events.UpdateProductQuantity(
                      productCode: key,
                      quantity: next,
                    ),
                  );
            }
          },
          icon: Icon(Icons.remove_circle_outline, color: Colors.grey[700]),
        ),
        SizedBox(
          width: 64,
          height: 40,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: FontFamily.productSans,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _applyParsedQuantity(context),
            onEditingComplete: () => _applyParsedQuantity(context),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          onPressed: () {
            context.read<CreateOrderBloc>().add(
                  events.UpdateProductQuantity(
                    productCode: key,
                    quantity: widget.product.quantity + 1,
                  ),
                );
          },
          icon: Icon(Icons.add_circle_outline, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
