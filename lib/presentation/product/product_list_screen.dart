import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/constants/font_family.dart';
import 'package:trash_pay/domain/entities/product/product.dart';
import 'package:trash_pay/presentation/widgets/common/professional_header.dart';
import 'logics/product_bloc.dart';
import 'logics/product_events.dart';
import 'logics/product_state.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    context.read<ProductBloc>().add(const LoadProductsEvent());
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
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
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
            // Header
            ProfessionalHeaders.list(
              title: 'Danh sách sản phẩm',
              subtitle: 'Quản lý sản phẩm từ API',
              onBackPressed: () => Navigator.pop(context),
            ),
            
            // Search Section
            _buildSearchSection(),
            
            // Product List
            Expanded(
              child: _buildProductList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
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
            if (value.isNotEmpty) {
              context.read<ProductBloc>().add(SearchProductsEvent(value));
            } else {
              context.read<ProductBloc>().add(const LoadProductsEvent());
            }
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
      ),
    );
  }

  Widget _buildProductList() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
            ),
          );
        }

        if (state is ProductLoaded) {
          if (state.products.isEmpty) {
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
                    'Không có sản phẩm nào',
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
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return _buildProductCard(product);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
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
            // Product name and code
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? 'Không có tên',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                      if (product.code != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Mã: ${product.code}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: FontFamily.productSans,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (product.isActive == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Hoạt động',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Price and unit info
            Row(
              children: [
                if (product.priceSale != null) ...[
                  Text(
                    'Giá: ${_formatCurrency(product.priceSale!.toDouble())}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF059669),
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (product.unitCode != null)
                  Text(
                    'Đơn vị: ${product.unitCode}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
              ],
            ),
            
            // Additional info
            if (product.description != null && product.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                product.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontFamily: FontFamily.productSans,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // VAT and Box info
            if (product.vat != null || product.priceBox != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (product.vat != null) ...[
                    Text(
                      'VAT: ${product.vat!.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (product.priceBox != null) ...[
                    Text(
                      'Giá hộp: ${_formatCurrency(product.priceBox!.toDouble())}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ';
  }
} 