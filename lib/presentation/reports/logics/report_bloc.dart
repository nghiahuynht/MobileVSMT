import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/report/report.dart';
import '../../../domain/entities/report/report_period.dart';
import '../../../domain/entities/transaction/transaction.dart';
import '../../../domain/entities/customer/customer.dart';
import '../../../domain/entities/product/product.dart';
import 'report_events.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc() : super(ReportInitial()) {
    on<LoadReportsEvent>(_onLoadReports);
    on<ChangePeriodEvent>(_onChangePeriod);
    on<RefreshReportsEvent>(_onRefreshReports);
    on<LoadReportTypeEvent>(_onLoadReportType);
    on<FilterReportsByDateEvent>(_onFilterReportsByDate);
    on<ExportReportEvent>(_onExportReport);
    on<SwitchReportTabEvent>(_onSwitchReportTab);
  }

  // Handle loading initial reports
  Future<void> _onLoadReports(LoadReportsEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());

    try {
      final period = event.initialPeriod ?? ReportPeriod.thisMonth;
      final dateRange = period.dateRange;

      // Generate mock data for all report types
      final summary = await _generateReportSummary(period, dateRange);
      final revenueReport = await _generateRevenueReport(period, dateRange);
      final customerReport = await _generateCustomerReport(period, dateRange);
      final productReport = await _generateProductReport(period, dateRange);

      emit(ReportsLoaded(
        currentPeriod: period,
        dateRange: dateRange,
        summary: summary,
        revenueReport: revenueReport,
        customerReport: customerReport,
        productReport: productReport,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(ReportError(message: 'Không thể tải báo cáo: ${e.toString()}'));
    }
  }

  // Handle period change
  Future<void> _onChangePeriod(ChangePeriodEvent event, Emitter<ReportState> emit) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      
      emit(currentState.copyWith(isRefreshing: true));

      try {
        final dateRange = event.customRange ?? event.period.dateRange;

        // Generate new reports for the selected period
        final summary = await _generateReportSummary(event.period, dateRange);
        final revenueReport = await _generateRevenueReport(event.period, dateRange);
        final customerReport = await _generateCustomerReport(event.period, dateRange);
        final productReport = await _generateProductReport(event.period, dateRange);

        emit(ReportsLoaded(
          currentPeriod: event.period,
          dateRange: dateRange,
          summary: summary,
          revenueReport: revenueReport,
          customerReport: customerReport,
          productReport: productReport,
          currentTabIndex: currentState.currentTabIndex,
          lastUpdated: DateTime.now(),
        ));
      } catch (e) {
        emit(ReportError(message: 'Không thể cập nhật báo cáo: ${e.toString()}'));
      }
    }
  }

  // Handle refresh
  Future<void> _onRefreshReports(RefreshReportsEvent event, Emitter<ReportState> emit) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      add(ChangePeriodEvent(period: currentState.currentPeriod));
    } else {
      add(LoadReportsEvent());
    }
  }

  // Handle loading specific report type
  Future<void> _onLoadReportType(LoadReportTypeEvent event, Emitter<ReportState> emit) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      
      emit(ReportTypeLoading(event.reportType));

      try {
        // Simulate loading delay
        await Future.delayed(const Duration(milliseconds: 500));

        // The data is already loaded, just switch to the tab
        final tabIndex = _getTabIndexForReportType(event.reportType);
        emit(currentState.copyWith(currentTabIndex: tabIndex));
      } catch (e) {
        emit(ReportError(message: 'Không thể tải loại báo cáo: ${e.toString()}'));
      }
    }
  }

  // Handle filtering by date range
  Future<void> _onFilterReportsByDate(FilterReportsByDateEvent event, Emitter<ReportState> emit) async {
    final customRange = DateRange(start: event.startDate, end: event.endDate);
    add(ChangePeriodEvent(period: ReportPeriod.custom, customRange: customRange));
  }

  // Handle export
  Future<void> _onExportReport(ExportReportEvent event, Emitter<ReportState> emit) async {
    try {
      // Simulate export process
      await Future.delayed(const Duration(seconds: 2));
      
      final fileName = 'report_${event.reportType.name}_${DateTime.now().millisecondsSinceEpoch}.${event.format}';
      final filePath = '/exports/$fileName';
      
      emit(ReportExported(
        filePath: filePath,
        reportType: event.reportType,
        format: event.format,
      ));
    } catch (e) {
      emit(ReportError(message: 'Không thể xuất báo cáo: ${e.toString()}'));
    }
  }

  // Handle tab switch
  Future<void> _onSwitchReportTab(SwitchReportTabEvent event, Emitter<ReportState> emit) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      emit(currentState.copyWith(currentTabIndex: event.tabIndex));
    }
  }

  int _getTabIndexForReportType(ReportType reportType) {
    switch (reportType) {
      case ReportType.overview:
        return 0;
      case ReportType.revenue:
        return 1;
      case ReportType.customers:
        return 2;
      case ReportType.products:
        return 3;
    }
  }

  // Generate mock report summary
  Future<ReportSummary> _generateReportSummary(ReportPeriod period, DateRange dateRange) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final random = Random();
    final baseRevenue = _getBaseRevenueForPeriod(period);
    final variance = baseRevenue * 0.3;
    
    final totalRevenue = baseRevenue + (random.nextDouble() - 0.5) * variance;
    final totalExpenses = totalRevenue * (0.6 + random.nextDouble() * 0.2);
    final netProfit = totalRevenue - totalExpenses;
    
    final totalOrders = _getBaseOrdersForPeriod(period) + random.nextInt(20);
    final completedOrders = (totalOrders * (0.85 + random.nextDouble() * 0.1)).round();
    
    final totalCustomers = _getBaseCustomersForPeriod(period) + random.nextInt(10);
    final activeCustomers = (totalCustomers * (0.7 + random.nextDouble() * 0.2)).round();
    
    final totalTransactions = (totalOrders * (1.5 + random.nextDouble() * 0.5)).round();
    final averageOrderValue = totalRevenue / totalOrders;
    
    final customerGrowthRate = (random.nextDouble() - 0.3) * 50;
    final revenueGrowthRate = (random.nextDouble() - 0.2) * 80;

    return ReportSummary(
      period: period,
      dateRange: dateRange,
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      netProfit: netProfit,
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      totalCustomers: totalCustomers,
      activeCustomers: activeCustomers,
      totalTransactions: totalTransactions,
      averageOrderValue: averageOrderValue,
      customerGrowthRate: customerGrowthRate,
      revenueGrowthRate: revenueGrowthRate,
      generatedAt: DateTime.now(),
    );
  }

  // Generate mock revenue report
  Future<RevenueReport> _generateRevenueReport(ReportPeriod period, DateRange dateRange) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final random = Random();
    final days = dateRange.duration.inDays;
    final dailyBreakdown = <DailyRevenue>[];
    
    double totalRevenue = 0;
    
    for (int i = 0; i < days; i++) {
      final date = dateRange.start.add(Duration(days: i));
      final baseDaily = _getBaseDailyRevenue(period);
      final dailyRevenue = baseDaily + (random.nextDouble() - 0.5) * baseDaily * 0.6;
      final orderCount = 3 + random.nextInt(15);
      final transactionCount = orderCount + random.nextInt(8);
      
      totalRevenue += dailyRevenue;
      
      dailyBreakdown.add(DailyRevenue(
        date: date,
        revenue: dailyRevenue,
        orderCount: orderCount,
        transactionCount: transactionCount,
      ));
    }

    final revenueByType = <TransactionType, double>{
      TransactionType.purchase: totalRevenue * 0.8,
      TransactionType.deposit: totalRevenue * 0.15,
      TransactionType.bonus: totalRevenue * 0.05,
    };

    final revenueByCategory = <String, double>{
      'Thùng rác': totalRevenue * 0.6,
      'Túi rác': totalRevenue * 0.25,
      'Phụ kiện': totalRevenue * 0.15,
    };

    final previousPeriodRevenue = totalRevenue * (0.7 + random.nextDouble() * 0.6);
    final highestDayRevenue = dailyBreakdown.map((d) => d.revenue).reduce((a, b) => a > b ? a : b);
    final lowestDayRevenue = dailyBreakdown.map((d) => d.revenue).reduce((a, b) => a < b ? a : b);
    final averageDailyRevenue = totalRevenue / days;

    return RevenueReport(
      period: period,
      dateRange: dateRange,
      dailyBreakdown: dailyBreakdown,
      revenueByType: revenueByType,
      revenueByCategory: revenueByCategory,
      totalRevenue: totalRevenue,
      previousPeriodRevenue: previousPeriodRevenue,
      highestDayRevenue: highestDayRevenue,
      lowestDayRevenue: lowestDayRevenue,
      averageDailyRevenue: averageDailyRevenue,
      generatedAt: DateTime.now(),
    );
  }

  // Generate mock customer report
  Future<CustomerReport> _generateCustomerReport(ReportPeriod period, DateRange dateRange) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final random = Random();
    final totalCustomers = _getBaseCustomersForPeriod(period) + random.nextInt(20);
    final newCustomers = (totalCustomers * (0.1 + random.nextDouble() * 0.2)).round();
    final activeCustomers = (totalCustomers * (0.7 + random.nextDouble() * 0.2)).round();
    final retentionCustomers = totalCustomers - newCustomers;

    // Generate top spending customers
    final topSpendingCustomers = <CustomerSpending>[];
    for (int i = 0; i < 10; i++) {
      final customer = CustomerModel(
        id: 'customer_$i',
        name: _getRandomCustomerName(i),
        phone: '+84${900000000 + random.nextInt(99999999)}',
        status: 'active',
        totalSpent: 500000 + random.nextDouble() * 2000000,
      );
      
      final orderCount = 3 + random.nextInt(12);
      final totalSpent = customer.totalSpent ?? 0;
      final averageOrderValue = totalSpent / orderCount;
      final lastOrderDate = DateTime.now().subtract(Duration(days: random.nextInt(30)));

      topSpendingCustomers.add(CustomerSpending(
        customer: customer,
        totalSpent: totalSpent,
        orderCount: orderCount,
        averageOrderValue: averageOrderValue,
        lastOrderDate: lastOrderDate,
      ));
    }

    topSpendingCustomers.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));

    final averageCustomerValue = topSpendingCustomers.isNotEmpty
        ? topSpendingCustomers.map((c) => c.totalSpent).reduce((a, b) => a + b) / topSpendingCustomers.length
        : 0.0;

    final customerLifetimeValue = averageCustomerValue * (1.2 + random.nextDouble() * 0.8);
    final retentionRate = retentionCustomers / totalCustomers * 100;
    final acquisitionRate = newCustomers / totalCustomers * 100;

    final customersByRegion = <String, int>{
      'Hà Nội': (totalCustomers * 0.4).round(),
      'TP.HCM': (totalCustomers * 0.3).round(),
      'Đà Nẵng': (totalCustomers * 0.15).round(),
      'Khác': (totalCustomers * 0.15).round(),
    };

    return CustomerReport(
      period: period,
      dateRange: dateRange,
      totalCustomers: totalCustomers,
      newCustomers: newCustomers,
      activeCustomers: activeCustomers,
      retentionCustomers: retentionCustomers,
      topSpendingCustomers: topSpendingCustomers,
      averageCustomerValue: averageCustomerValue,
      customerLifetimeValue: customerLifetimeValue,
      retentionRate: retentionRate,
      acquisitionRate: acquisitionRate,
      customersByRegion: customersByRegion,
      generatedAt: DateTime.now(),
    );
  }

  // Generate mock product report
  Future<ProductReport> _generateProductReport(ReportPeriod period, DateRange dateRange) async {
    await Future.delayed(const Duration(milliseconds: 380));

    final random = Random();
    final products = _generateMockProducts();
    final totalProductsSold = _getBaseProductsSoldForPeriod(period) + random.nextInt(100);
    
    final topSellingProducts = <ProductPerformance>[];
    final lowPerformingProducts = <ProductPerformance>[];
    double totalProductRevenue = 0;

    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      final quantitySold = 10 + random.nextInt(50);
      final revenue = quantitySold * product.price;
      final orderCount = 5 + random.nextInt(20);
      final averageQuantityPerOrder = quantitySold / orderCount;
      final marketShare = (quantitySold / totalProductsSold) * 100;

      totalProductRevenue += revenue;

      final performance = ProductPerformance(
        product: product,
        quantitySold: quantitySold,
        revenue: revenue,
        orderCount: orderCount,
        averageQuantityPerOrder: averageQuantityPerOrder,
        marketShare: marketShare,
      );

      if (i < 5) {
        topSellingProducts.add(performance);
      } else if (i >= products.length - 3) {
        lowPerformingProducts.add(performance);
      }
    }

    topSellingProducts.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
    lowPerformingProducts.sort((a, b) => a.quantitySold.compareTo(b.quantitySold));

    final categoryStats = <String, ProductCategoryStats>{
      'Thùng rác': ProductCategoryStats(
        category: 'Thùng rác',
        productCount: 6,
        totalQuantitySold: (totalProductsSold * 0.6).round(),
        totalRevenue: totalProductRevenue * 0.6,
        averagePrice: 45000,
        marketShare: 60,
      ),
      'Túi rác': ProductCategoryStats(
        category: 'Túi rác',
        productCount: 2,
        totalQuantitySold: (totalProductsSold * 0.25).round(),
        totalRevenue: totalProductRevenue * 0.25,
        averagePrice: 35000,
        marketShare: 25,
      ),
      'Phụ kiện': ProductCategoryStats(
        category: 'Phụ kiện',
        productCount: 1,
        totalQuantitySold: (totalProductsSold * 0.15).round(),
        totalRevenue: totalProductRevenue * 0.15,
        averagePrice: 25000,
        marketShare: 15,
      ),
    };

    final averageProductPrice = totalProductRevenue / totalProductsSold;
    final bestPerformer = topSellingProducts.isNotEmpty 
        ? topSellingProducts.first 
        : ProductPerformance(
            product: products.first,
            quantitySold: 0,
            revenue: 0,
            orderCount: 0,
            averageQuantityPerOrder: 0,
            marketShare: 0,
          );

    return ProductReport(
      period: period,
      dateRange: dateRange,
      topSellingProducts: topSellingProducts,
      lowPerformingProducts: lowPerformingProducts,
      categoryStats: categoryStats,
      totalProductsSold: totalProductsSold,
      totalProductRevenue: totalProductRevenue,
      averageProductPrice: averageProductPrice,
      bestPerformer: bestPerformer,
      generatedAt: DateTime.now(),
    );
  }

  // Helper methods for generating realistic data based on period
  double _getBaseRevenueForPeriod(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.today:
        return 150000;
      case ReportPeriod.yesterday:
        return 140000;
      case ReportPeriod.thisWeek:
        return 1200000;
      case ReportPeriod.lastWeek:
        return 1100000;
      case ReportPeriod.thisMonth:
        return 4500000;
      case ReportPeriod.lastMonth:
        return 4200000;
      case ReportPeriod.thisQuarter:
        return 13500000;
      case ReportPeriod.lastQuarter:
        return 12800000;
      case ReportPeriod.thisYear:
        return 50000000;
      case ReportPeriod.lastYear:
        return 45000000;
      case ReportPeriod.custom:
        return 500000;
    }
  }

  int _getBaseOrdersForPeriod(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.today:
        return 8;
      case ReportPeriod.yesterday:
        return 7;
      case ReportPeriod.thisWeek:
        return 45;
      case ReportPeriod.lastWeek:
        return 42;
      case ReportPeriod.thisMonth:
        return 180;
      case ReportPeriod.lastMonth:
        return 165;
      case ReportPeriod.thisQuarter:
        return 540;
      case ReportPeriod.lastQuarter:
        return 520;
      case ReportPeriod.thisYear:
        return 2000;
      case ReportPeriod.lastYear:
        return 1850;
      case ReportPeriod.custom:
        return 20;
    }
  }

  int _getBaseCustomersForPeriod(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.today:
        return 5;
      case ReportPeriod.yesterday:
        return 4;
      case ReportPeriod.thisWeek:
        return 25;
      case ReportPeriod.lastWeek:
        return 23;
      case ReportPeriod.thisMonth:
        return 85;
      case ReportPeriod.lastMonth:
        return 78;
      case ReportPeriod.thisQuarter:
        return 250;
      case ReportPeriod.lastQuarter:
        return 235;
      case ReportPeriod.thisYear:
        return 950;
      case ReportPeriod.lastYear:
        return 850;
      case ReportPeriod.custom:
        return 15;
    }
  }

  int _getBaseProductsSoldForPeriod(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.today:
        return 15;
      case ReportPeriod.yesterday:
        return 12;
      case ReportPeriod.thisWeek:
        return 85;
      case ReportPeriod.lastWeek:
        return 78;
      case ReportPeriod.thisMonth:
        return 350;
      case ReportPeriod.lastMonth:
        return 320;
      case ReportPeriod.thisQuarter:
        return 1050;
      case ReportPeriod.lastQuarter:
        return 980;
      case ReportPeriod.thisYear:
        return 4000;
      case ReportPeriod.lastYear:
        return 3700;
      case ReportPeriod.custom:
        return 50;
    }
  }

  double _getBaseDailyRevenue(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.thisWeek:
      case ReportPeriod.lastWeek:
        return 170000;
      case ReportPeriod.thisMonth:
      case ReportPeriod.lastMonth:
        return 150000;
      case ReportPeriod.thisQuarter:
      case ReportPeriod.lastQuarter:
        return 145000;
      case ReportPeriod.thisYear:
      case ReportPeriod.lastYear:
        return 140000;
      default:
        return 150000;
    }
  }

  List<ProductModel> _generateMockProducts() {
    return [
      ProductModel(id: '1', code: 'THANG-1', name: 'Thùng rác 20L', price: 45000, category: 'Thùng rác', unit: 'cái', createdAt: DateTime.now()),
      ProductModel(id: '2', code: 'THANG-2', name: 'Thùng rác 40L', price: 45000, category: 'Thùng rác', unit: 'cái', createdAt: DateTime.now()),
      ProductModel(id: '3', code: 'THANG-3', name: 'Thùng rác 60L', price: 45000, category: 'Thùng rác', unit: 'cái', createdAt: DateTime.now()),
      ProductModel(id: '4', code: 'THANG-4', name: 'Thùng rác inox', price: 45000, category: 'Thùng rác', unit: 'cái', createdAt: DateTime.now()),
      ProductModel(id: '5', code: 'THANG-5', name: 'Thùng rác công cộng', price: 45000, category: 'Thùng rác', unit: 'cái', createdAt: DateTime.now()),
      ProductModel(id: '6', code: 'THANG-6', name: 'Thùng rác phân loại', price: 45000, category: 'Thùng rác', unit: 'cái', createdAt: DateTime.now()),
      ProductModel(id: '7', code: 'THANG-7', name: 'Túi rác sinh học', price: 45000, category: 'Túi rác', unit: 'thùng', createdAt: DateTime.now()),
      ProductModel(id: '8', code: 'THANG-8', name: 'Túi rác tái chế', price: 45000, category: 'Túi rác', unit: 'thùng', createdAt: DateTime.now()),
      ProductModel(id: '9', code: 'THANG-9', name: 'Phụ kiện thu gom', price: 45000, category: 'Phụ kiện', unit: 'bộ', createdAt: DateTime.now()),
    ];
  }

  String _getRandomCustomerName(int index) {
    final names = [
      'Nguyễn Văn An', 'Trần Thị Bình', 'Lê Hoàng Cường', 'Phạm Thị Dung',
      'Vũ Minh Đức', 'Hoàng Thị Ế', 'Đặng Văn Phúc', 'Bùi Thị Giang',
      'Ngô Văn Hạnh', 'Đinh Thị Lan', 'Phan Văn Kiên', 'Lý Thị Mai',
    ];
    return names[index % names.length];
  }
} 