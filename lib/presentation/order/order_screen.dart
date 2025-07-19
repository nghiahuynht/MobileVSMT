import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/font_family.dart';
import '../../domain/entities/customer/customer.dart';
import '../../domain/entities/checkout/checkout_data.dart';
import 'logics/order_bloc.dart';
import 'logics/order_events.dart';
import 'logics/order_state.dart';

class OrderScreen extends StatefulWidget {
  final CustomerModel? customer;
  
  const OrderScreen({
    super.key,
    this.customer,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadProductsEvent());
    
    // Pre-select customer if provided
    if (widget.customer != null) {
      context.read<OrderBloc>().add(SelectCustomerEvent(widget.customer));
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
          }
        },
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search Bar
            _buildSearchBar(),
            
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
                    widget.customer != null 
                      ? 'Đơn hàng cho ${widget.customer!.name}'
                      : 'Đặt hàng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                  Text(
                    widget.customer != null
                      ? 'Mã KH: ${widget.customer!.id} • ${widget.customer!.phone ?? "Chưa có SĐT"}'
                      : 'Chọn sản phẩm để thêm vào đơn hàng',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                int cartItemCount = 0;
                if (state is OrderScreenState) {
                  cartItemCount = state.cartItemCount;
                }
                
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () => _navigateToCheckout(context),
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    ),
                    if (cartItemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$cartItemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
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
          context.read<OrderBloc>().add(SearchProductsEvent(value));
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
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
            ),
          );
        }

        if (state is OrderScreenState) {
          if (state.filteredProducts.isEmpty) {
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
                  if (state.searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Thử tìm kiếm với từ khóa khác',
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
            itemCount: state.filteredProducts.length,
            itemBuilder: (context, index) {
              final product = state.filteredProducts[index];
              return _buildProductCard(product);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductCard(product) {
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
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.code,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                  if (product.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.description!,
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
                Text(
                  '${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                    fontFamily: FontFamily.productSans,
                  ),
                ),
                if (product.unit != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'đ/${product.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(width: 12),
            
            // Add to Cart Button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0EA5E9).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.read<OrderBloc>().add(
                      AddToCartEvent(product: product),
                    );
                    
                    // Show success feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.code} đã được thêm vào giỏ hàng'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartFab() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderScreenState && !state.isCartEmpty) {
          return FloatingActionButton.extended(
            onPressed: () => _navigateToCheckout(context),
            backgroundColor: const Color(0xFF059669),
            foregroundColor: Colors.white,
            label: Text(
              'Xem giỏ hàng (${state.cartItemCount})',
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
    final currentState = context.read<OrderBloc>().state;
    if (currentState is OrderScreenState && !currentState.isCartEmpty) {
      final checkoutData = CheckoutData(
        cartItems: currentState.cartItems,
        customer: currentState.selectedCustomer,
        subtotal: currentState.subtotal,
        total: currentState.total,
      );
      
      context.go('/checkout', extra: checkoutData);
    }
  }
} 