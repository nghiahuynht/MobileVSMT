import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/font_family.dart';
import '../../domain/entities/report/report_period.dart';
import '../widgets/common/professional_header.dart';
import 'logics/report_bloc.dart';
import 'logics/report_events.dart';
import 'logics/report_state.dart';
import 'widgets/period_selector.dart';
import 'widgets/statistic_tile.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<ReportBloc>().add(LoadReportsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocListener<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ReportExported) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã xuất báo cáo: ${state.filePath}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Header
            ProfessionalHeaders.detail(
              title: 'Báo cáo',
              subtitle: 'Thống kê và phân tích doanh thu',
              actionWidget: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: GestureDetector(
                  onTap: () => context.read<ReportBloc>().add(RefreshReportsEvent()),
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Period Selector
            BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state is ReportsLoaded) {
                  return PeriodSelector(
                    selectedPeriod: state.currentPeriod,
                    onPeriodChanged: (period) {
                      context.read<ReportBloc>().add(ChangePeriodEvent(period: period));
                    },
                    isLoading: state.isRefreshing,
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (index) => context.read<ReportBloc>().add(SwitchReportTabEvent(index)),
                tabs: const [
                  Tab(text: 'Tổng quan'),
                  Tab(text: 'Doanh thu'),
                  Tab(text: 'Khách hàng'),
                  Tab(text: 'Sản phẩm'),
                ],
                labelColor: const Color(0xFF059669),
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.productSans,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.productSans,
                ),
                indicator: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                dividerColor: Colors.transparent,
              ),
            ),

            const SizedBox(height: 24),

            // Tab Content
            Expanded(
              child: BlocBuilder<ReportBloc, ReportState>(
                builder: (context, state) {
                  if (state is ReportLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                      ),
                    );
                  } else if (state is ReportsLoaded) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(state),
                        _buildRevenueTab(state),
                        _buildCustomerTab(state),
                        _buildProductTab(state),
                      ],
                    );
                  } else if (state is ReportError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Có lỗi xảy ra',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                              fontFamily: FontFamily.productSans,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontFamily: FontFamily.productSans,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context.read<ReportBloc>().add(LoadReportsEvent()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ReportsLoaded state) {
    final summary = state.summary;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              StatisticTileHelpers.revenue(
                value: _formatCurrency(summary.totalRevenue),
                trend: '${summary.revenueGrowthRate > 0 ? '+' : ''}${summary.revenueGrowthRate.toStringAsFixed(1)}%',
                isTrendPositive: summary.revenueGrowthRate > 0,
              ),
              StatisticTileHelpers.order(
                value: summary.totalOrders.toString(),
                subtitle: '${summary.completedOrders} hoàn thành',
                trend: '${summary.orderCompletionRate.toStringAsFixed(1)}%',
                isTrendPositive: summary.orderCompletionRate > 85,
              ),
              StatisticTileHelpers.customer(
                value: summary.totalCustomers.toString(),
                subtitle: '${summary.activeCustomers} hoạt động',
                trend: '${summary.customerGrowthRate > 0 ? '+' : ''}${summary.customerGrowthRate.toStringAsFixed(1)}%',
                isTrendPositive: summary.customerGrowthRate > 0,
              ),
              StatisticTileHelpers.profit(
                value: _formatCurrency(summary.netProfit),
                subtitle: 'Tỷ suất: ${summary.profitMargin.toStringAsFixed(1)}%',
                trend: '${summary.profitMargin.toStringAsFixed(1)}%',
                isTrendPositive: summary.profitMargin > 20,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Additional Metrics
          _buildSectionTitle('Thống kê bổ sung'),
          const SizedBox(height: 16),
          
          _buildMetricRow('Trung bình giá trị đơn hàng', _formatCurrency(summary.averageOrderValue)),
          _buildMetricRow('Tổng số giao dịch', summary.totalTransactions.toString()),
          _buildMetricRow('Tỷ lệ hoàn thành đơn hàng', '${summary.orderCompletionRate.toStringAsFixed(1)}%'),
          _buildMetricRow('Tỷ lệ khách hàng hoạt động', '${summary.customerActivityRate.toStringAsFixed(1)}%'),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildRevenueTab(ReportsLoaded state) {
    final revenueReport = state.revenueReport;
    if (revenueReport == null) {
      return const Center(child: Text('Không có dữ liệu doanh thu'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Summary Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              StatisticTile(
                title: 'Tổng doanh thu',
                value: _formatCurrency(revenueReport.totalRevenue),
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF059669),
                backgroundColor: const Color(0xFFDCFCE7),
                trend: '${revenueReport.growthRate > 0 ? '+' : ''}${revenueReport.growthRate.toStringAsFixed(1)}%',
                isTrendPositive: revenueReport.isGrowthPositive,
              ),
              StatisticTile(
                title: 'Cao nhất trong ngày',
                value: _formatCurrency(revenueReport.highestDayRevenue),
                icon: Icons.star_outline,
                iconColor: const Color(0xFFDC2626),
                backgroundColor: const Color(0xFFFEE2E2),
              ),
              StatisticTile(
                title: 'Trung bình mỗi ngày',
                value: _formatCurrency(revenueReport.averageDailyRevenue),
                icon: Icons.timeline_outlined,
                iconColor: const Color(0xFF0EA5E9),
                backgroundColor: const Color(0xFFDEF7FF),
              ),
              StatisticTile(
                title: 'Thấp nhất trong ngày',
                value: _formatCurrency(revenueReport.lowestDayRevenue),
                icon: Icons.trending_down_rounded,
                iconColor: const Color(0xFF7C3AED),
                backgroundColor: const Color(0xFFF3E8FF),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Revenue by Type
          _buildSectionTitle('Doanh thu theo loại giao dịch'),
          const SizedBox(height: 16),
          _buildRevenueByTypeSection(revenueReport.revenueByType),

          const SizedBox(height: 24),

          // Revenue by Category
          _buildSectionTitle('Doanh thu theo danh mục sản phẩm'),
          const SizedBox(height: 16),
          _buildRevenueByCategorySection(revenueReport.revenueByCategory),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCustomerTab(ReportsLoaded state) {
    final customerReport = state.customerReport;
    if (customerReport == null) {
      return const Center(child: Text('Không có dữ liệu khách hàng'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Metrics
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              StatisticTile(
                title: 'Tổng khách hàng',
                value: customerReport.totalCustomers.toString(),
                icon: Icons.people_outline,
                iconColor: const Color(0xFF059669),
                backgroundColor: const Color(0xFFDCFCE7),
                trend: '${customerReport.customerGrowthRate > 0 ? '+' : ''}${customerReport.customerGrowthRate.toStringAsFixed(1)}%',
                isTrendPositive: customerReport.customerGrowthRate > 0,
              ),
              StatisticTile(
                title: 'Khách hàng mới',
                value: customerReport.newCustomers.toString(),
                icon: Icons.person_add_outlined,
                iconColor: const Color(0xFF0EA5E9),
                backgroundColor: const Color(0xFFDEF7FF),
                subtitle: 'Tỷ lệ thu hút: ${customerReport.acquisitionRate.toStringAsFixed(1)}%',
              ),
              StatisticTile(
                title: 'Giá trị trung bình',
                value: _formatCurrency(customerReport.averageCustomerValue),
                icon: Icons.attach_money_outlined,
                iconColor: const Color(0xFFDC2626),
                backgroundColor: const Color(0xFFFEE2E2),
              ),
              StatisticTile(
                title: 'Tỷ lệ giữ chân',
                value: '${customerReport.retentionRate.toStringAsFixed(1)}%',
                icon: Icons.favorite_outline,
                iconColor: const Color(0xFF7C3AED),
                backgroundColor: const Color(0xFFF3E8FF),
                trend: customerReport.retentionRate > 80 ? 'Tốt' : 'Cần cải thiện',
                isTrendPositive: customerReport.retentionRate > 80,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Top Spending Customers
          _buildSectionTitle('Top khách hàng chi tiêu'),
          const SizedBox(height: 16),
          _buildTopCustomersSection(customerReport.topSpendingCustomers.take(5).toList()),

          const SizedBox(height: 24),

          // Customer by Region
          _buildSectionTitle('Khách hàng theo khu vực'),
          const SizedBox(height: 16),
          _buildCustomerByRegionSection(customerReport.customersByRegion),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProductTab(ReportsLoaded state) {
    final productReport = state.productReport;
    if (productReport == null) {
      return const Center(child: Text('Không có dữ liệu sản phẩm'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Metrics
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              StatisticTile(
                title: 'Tổng sản phẩm bán',
                value: productReport.totalProductsSold.toString(),
                icon: Icons.inventory_outlined,
                iconColor: const Color(0xFF059669),
                backgroundColor: const Color(0xFFDCFCE7),
              ),
              StatisticTile(
                title: 'Doanh thu sản phẩm',
                value: _formatCurrency(productReport.totalProductRevenue),
                icon: Icons.monetization_on_outlined,
                iconColor: const Color(0xFF0EA5E9),
                backgroundColor: const Color(0xFFDEF7FF),
              ),
              StatisticTile(
                title: 'Giá trung bình',
                value: _formatCurrency(productReport.averageProductPrice),
                icon: Icons.price_check_outlined,
                iconColor: const Color(0xFFDC2626),
                backgroundColor: const Color(0xFFFEE2E2),
              ),
              StatisticTile(
                title: 'Sản phẩm bán chạy',
                value: productReport.bestPerformer.product.code ?? '',
                subtitle: '${productReport.bestPerformer.quantitySold} đã bán',
                icon: Icons.star_outline,
                iconColor: const Color(0xFF7C3AED),
                backgroundColor: const Color(0xFFF3E8FF),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Top Selling Products
          _buildSectionTitle('Sản phẩm bán chạy nhất'),
          const SizedBox(height: 16),
          _buildTopProductsSection(productReport.topSellingProducts.take(5).toList()),

          const SizedBox(height: 24),

          // Category Performance
          _buildSectionTitle('Hiệu suất theo danh mục'),
          const SizedBox(height: 16),
          _buildCategoryStatsSection(productReport.categoryStats),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2937),
        fontFamily: FontFamily.productSans,
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
              fontFamily: FontFamily.productSans,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              fontFamily: FontFamily.productSans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueByTypeSection(Map<dynamic, double> revenueByType) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: revenueByType.entries.map((entry) {
          final type = entry.key;
          final amount = entry.value;
          final typeName = type.toString().split('.').last;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getColorForTransactionType(typeName),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getTransactionTypeDisplayName(typeName),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                ),
                Text(
                  _formatCurrency(amount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRevenueByCategorySection(Map<String, double> revenueByCategory) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: revenueByCategory.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getColorForCategory(entry.key),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                ),
                Text(
                  _formatCurrency(entry.value),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopCustomersSection(List<dynamic> customers) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: customers.asMap().entries.map((entry) {
          final index = entry.key;
          final customer = entry.value;
          
          return Container(
            margin: EdgeInsets.only(bottom: index < customers.length - 1 ? 16 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.customer.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                      Text(
                        '${customer.orderCount} đơn hàng',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatCurrency(customer.totalSpent),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomerByRegionSection(Map<String, int> customersByRegion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: customersByRegion.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getColorForRegion(entry.key),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                ),
                Text(
                  '${entry.value} khách hàng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopProductsSection(List<dynamic> products) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: products.asMap().entries.map((entry) {
          final index = entry.key;
          final productPerformance = entry.value;
          
          return Container(
            margin: EdgeInsets.only(bottom: index < products.length - 1 ? 16 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${productPerformance.product.code} - ${productPerformance.product.name}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                      Text(
                        '${productPerformance.quantitySold} đã bán',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatCurrency(productPerformance.revenue),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0EA5E9),
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryStatsSection(Map<String, dynamic> categoryStats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: categoryStats.entries.map((entry) {
          final categoryName = entry.key;
          final stats = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getColorForCategory(categoryName),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                    ),
                    Text(
                      '${stats.marketShare.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669),
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã bán: ${stats.totalQuantitySold}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                    Text(
                      _formatCurrency(stats.totalRevenue),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toInt().toString();
  }

  Color _getColorForTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'purchase':
        return const Color(0xFF059669);
      case 'deposit':
        return const Color(0xFF0EA5E9);
      case 'bonus':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getTransactionTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'purchase':
        return 'Mua hàng';
      case 'deposit':
        return 'Nạp tiền';
      case 'bonus':
        return 'Thưởng';
      default:
        return type;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Thùng rác':
        return const Color(0xFF059669);
      case 'Túi rác':
        return const Color(0xFF0EA5E9);
      case 'Phụ kiện':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getColorForRegion(String region) {
    switch (region) {
      case 'Hà Nội':
        return const Color(0xFF059669);
      case 'TP.HCM':
        return const Color(0xFF0EA5E9);
      case 'Đà Nẵng':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }
} 