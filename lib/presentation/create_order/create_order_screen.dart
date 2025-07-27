import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/constants/colors.dart';
import 'package:trash_pay/domain/entities/order/order_item.dart';
import 'package:trash_pay/presentation/app/logics/app_bloc.dart';
import 'package:trash_pay/presentation/app/logics/app_state.dart';
import 'package:trash_pay/presentation/checkout/checkout_screen.dart';
import 'package:trash_pay/presentation/create_order/logics/create_order_bloc.dart';
import 'package:trash_pay/presentation/create_order/logics/create_order_events.dart'
    as events;
import 'package:trash_pay/presentation/create_order/logics/create_order_state.dart'
    as state;
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
    // Initialize the bloc to load products
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
          if (s is state.CreateOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã có lỗi xảy ra'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (s is state.CreateOrderSuccess) {
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
            // Header
            _buildHeader(),

            _buildSearchBar(),

            _buildTotal(),

            const SizedBox(
              height: 18,
            ),

            // Product List
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
    return BlocBuilder<CreateOrderBloc, state.CreateOrderState>(
        builder: (context, createOrderState) {
      if (createOrderState is state.CreateOrderLoaded) {
        return Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text.rich(TextSpan(
            children: [
              const TextSpan(text: 'Tổng tiền: '),
              TextSpan(
                  text: Utils.formatCurrency(createOrderState.total),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          )),
        );
      }
      return const SizedBox.shrink();
    });
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
          setState(() {
          });
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
    return BlocBuilder<AppBloc, AppState>(builder: (context, appState) {
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
            final products = s.products.where((e) => e.item.name?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false).toList();
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product, index);
              },
            );
          }

          return const SizedBox.shrink();
        },
      );
    });
  }

  Widget _buildProductCard(state.ProductOrderItemWrapper product, int index) {
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
        child: Row(
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

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _iconBtn(
                        icon: Icons.remove,
                        isDisabled: !product.isSelected,
                        onTap: () {
                          context
                              .read<CreateOrderBloc>()
                              .add(events.RemoveProductFromCart(index));
                        }),
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          product.quantity.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontFamily.productSans,
                          ),
                        ),
                      ),
                    ),
                    _iconBtn(
                      icon: Icons.add,
                      onTap: () {
                        context
                            .read<CreateOrderBloc>()
                            .add(events.AddProductToCart(index));
                      },
                    )
                  ],
                ),
                if (product.item.unitCode != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${(product.item.priceSale ?? 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')} đ/${product.item.unitCode}',
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
              'Xem giỏ hàng',
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
    final currentState = context.read<CreateOrderBloc>().state;
    if (currentState is state.CreateOrderLoaded &&
        currentState.isSelected) {

      final List<OrderItemModel> cartItems = currentState.products.where((e) => e.isSelected)
          .map((e) => OrderItemModel(
                quantity: e.quantity,
                productCode: e.item.code,
                productName: e.item.name,
                unitCode: e.item.unitCode,
                priceNoVAT: e.item.priceSale,
                vat: e.item.vat,
                priceWithVAT: (e.item.priceSale ?? 0) + (e.item.vat ?? 0),
              ))
          .toList();

      final checkoutData = CheckoutData(
        cartItems: cartItems,
        customer: currentState.selectedCustomer,
        subtotal: currentState.subtotal,
        total: currentState.total,
      );

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CheckoutScreen(checkoutData: checkoutData),
      ));
    }
  }

  Widget _iconBtn({
    required VoidCallback onTap,
    required IconData icon,
    bool isDisabled = false,
  }) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey : const Color(0xFF0EA5E9),
        borderRadius: BorderRadius.circular(22),
        
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}
