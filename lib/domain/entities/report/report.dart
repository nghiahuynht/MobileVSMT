import 'report_period.dart';
import '../transaction/transaction.dart';
import '../order/order.dart';
import '../customer/customer.dart';
import '../product/product.dart';

// Main report summary containing overview statistics
class ReportSummary {
  final ReportPeriod period;
  final DateRange dateRange;
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final int totalOrders;
  final int completedOrders;
  final int totalCustomers;
  final int activeCustomers;
  final int totalTransactions;
  final double averageOrderValue;
  final double customerGrowthRate; // Percentage
  final double revenueGrowthRate; // Percentage
  final DateTime generatedAt;

  const ReportSummary({
    required this.period,
    required this.dateRange,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalOrders,
    required this.completedOrders,
    required this.totalCustomers,
    required this.activeCustomers,
    required this.totalTransactions,
    required this.averageOrderValue,
    required this.customerGrowthRate,
    required this.revenueGrowthRate,
    required this.generatedAt,
  });

  double get profitMargin => totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;
  double get orderCompletionRate => totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0;
  double get customerActivityRate => totalCustomers > 0 ? (activeCustomers / totalCustomers) * 100 : 0;

  @override
  String toString() {
    return 'ReportSummary{period: $period, totalRevenue: $totalRevenue, totalOrders: $totalOrders}';
  }
}

// Detailed revenue analysis
class RevenueReport {
  final ReportPeriod period;
  final DateRange dateRange;
  final List<DailyRevenue> dailyBreakdown;
  final Map<TransactionType, double> revenueByType;
  final Map<String, double> revenueByCategory; // Product categories
  final double totalRevenue;
  final double previousPeriodRevenue;
  final double highestDayRevenue;
  final double lowestDayRevenue;
  final double averageDailyRevenue;
  final DateTime generatedAt;

  const RevenueReport({
    required this.period,
    required this.dateRange,
    required this.dailyBreakdown,
    required this.revenueByType,
    required this.revenueByCategory,
    required this.totalRevenue,
    required this.previousPeriodRevenue,
    required this.highestDayRevenue,
    required this.lowestDayRevenue,
    required this.averageDailyRevenue,
    required this.generatedAt,
  });

  double get growthRate {
    if (previousPeriodRevenue <= 0) return 0;
    return ((totalRevenue - previousPeriodRevenue) / previousPeriodRevenue) * 100;
  }

  bool get isGrowthPositive => growthRate > 0;

  @override
  String toString() {
    return 'RevenueReport{period: $period, totalRevenue: $totalRevenue, growthRate: $growthRate%}';
  }
}

// Daily revenue breakdown
class DailyRevenue {
  final DateTime date;
  final double revenue;
  final int orderCount;
  final int transactionCount;

  const DailyRevenue({
    required this.date,
    required this.revenue,
    required this.orderCount,
    required this.transactionCount,
  });

  @override
  String toString() {
    return 'DailyRevenue{date: $date, revenue: $revenue, orders: $orderCount}';
  }
}

// Customer analytics report
class CustomerReport {
  final ReportPeriod period;
  final DateRange dateRange;
  final int totalCustomers;
  final int newCustomers;
  final int activeCustomers;
  final int retentionCustomers; // Customers from previous period still active
  final List<CustomerSpending> topSpendingCustomers;
  final double averageCustomerValue;
  final double customerLifetimeValue;
  final double retentionRate;
  final double acquisitionRate;
  final Map<String, int> customersByRegion; // If location data available
  final DateTime generatedAt;

  const CustomerReport({
    required this.period,
    required this.dateRange,
    required this.totalCustomers,
    required this.newCustomers,
    required this.activeCustomers,
    required this.retentionCustomers,
    required this.topSpendingCustomers,
    required this.averageCustomerValue,
    required this.customerLifetimeValue,
    required this.retentionRate,
    required this.acquisitionRate,
    required this.customersByRegion,
    required this.generatedAt,
  });

  double get customerGrowthRate {
    final previousTotal = totalCustomers - newCustomers;
    if (previousTotal <= 0) return 0;
    return (newCustomers / previousTotal) * 100;
  }

  @override
  String toString() {
    return 'CustomerReport{period: $period, totalCustomers: $totalCustomers, newCustomers: $newCustomers}';
  }
}

// Customer spending information
class CustomerSpending {
  final CustomerModel customer;
  final double totalSpent;
  final int orderCount;
  final double averageOrderValue;
  final DateTime lastOrderDate;

  const CustomerSpending({
    required this.customer,
    required this.totalSpent,
    required this.orderCount,
    required this.averageOrderValue,
    required this.lastOrderDate,
  });

  @override
  String toString() {
    return 'CustomerSpending{customer: ${customer.name}, totalSpent: $totalSpent}';
  }
}

// Product performance report
class ProductReport {
  final ReportPeriod period;
  final DateRange dateRange;
  final List<ProductPerformance> topSellingProducts;
  final List<ProductPerformance> lowPerformingProducts;
  final Map<String, ProductCategoryStats> categoryStats;
  final int totalProductsSold;
  final double totalProductRevenue;
  final double averageProductPrice;
  final ProductPerformance bestPerformer;
  final DateTime generatedAt;

  const ProductReport({
    required this.period,
    required this.dateRange,
    required this.topSellingProducts,
    required this.lowPerformingProducts,
    required this.categoryStats,
    required this.totalProductsSold,
    required this.totalProductRevenue,
    required this.averageProductPrice,
    required this.bestPerformer,
    required this.generatedAt,
  });

  @override
  String toString() {
    return 'ProductReport{period: $period, totalProductsSold: $totalProductsSold}';
  }
}

// Individual product performance
class ProductPerformance {
  final ProductModel product;
  final int quantitySold;
  final double revenue;
  final int orderCount;
  final double averageQuantityPerOrder;
  final double marketShare; // Percentage of total sales

  const ProductPerformance({
    required this.product,
    required this.quantitySold,
    required this.revenue,
    required this.orderCount,
    required this.averageQuantityPerOrder,
    required this.marketShare,
  });

  @override
  String toString() {
    return 'ProductPerformance{product: ${product.code}, quantitySold: $quantitySold, revenue: $revenue}';
  }
}

// Product category statistics
class ProductCategoryStats {
  final String category;
  final int productCount;
  final int totalQuantitySold;
  final double totalRevenue;
  final double averagePrice;
  final double marketShare;

  const ProductCategoryStats({
    required this.category,
    required this.productCount,
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.averagePrice,
    required this.marketShare,
  });

  @override
  String toString() {
    return 'ProductCategoryStats{category: $category, totalRevenue: $totalRevenue}';
  }
} 