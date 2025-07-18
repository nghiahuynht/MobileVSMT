import '../../../domain/entities/report/report.dart';
import '../../../domain/entities/report/report_period.dart';
import 'report_events.dart';

abstract class ReportState {}

// Initial state
class ReportInitial extends ReportState {}

// Loading state
class ReportLoading extends ReportState {}

// Reports loaded successfully
class ReportsLoaded extends ReportState {
  final ReportPeriod currentPeriod;
  final DateRange dateRange;
  final ReportSummary summary;
  final RevenueReport? revenueReport;
  final CustomerReport? customerReport;
  final ProductReport? productReport;
  final int currentTabIndex;
  final bool isRefreshing;
  final DateTime lastUpdated;

  ReportsLoaded({
    required this.currentPeriod,
    required this.dateRange,
    required this.summary,
    this.revenueReport,
    this.customerReport,
    this.productReport,
    this.currentTabIndex = 0,
    this.isRefreshing = false,
    required this.lastUpdated,
  });

  ReportsLoaded copyWith({
    ReportPeriod? currentPeriod,
    DateRange? dateRange,
    ReportSummary? summary,
    RevenueReport? revenueReport,
    CustomerReport? customerReport,
    ProductReport? productReport,
    int? currentTabIndex,
    bool? isRefreshing,
    DateTime? lastUpdated,
  }) {
    return ReportsLoaded(
      currentPeriod: currentPeriod ?? this.currentPeriod,
      dateRange: dateRange ?? this.dateRange,
      summary: summary ?? this.summary,
      revenueReport: revenueReport ?? this.revenueReport,
      customerReport: customerReport ?? this.customerReport,
      productReport: productReport ?? this.productReport,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Get current report based on tab index
  dynamic get currentReport {
    switch (currentTabIndex) {
      case 0:
        return summary;
      case 1:
        return revenueReport;
      case 2:
        return customerReport;
      case 3:
        return productReport;
      default:
        return summary;
    }
  }

  String get currentReportTitle {
    switch (currentTabIndex) {
      case 0:
        return 'Tổng quan';
      case 1:
        return 'Doanh thu';
      case 2:
        return 'Khách hàng';
      case 3:
        return 'Sản phẩm';
      default:
        return 'Tổng quan';
    }
  }

  @override
  String toString() {
    return 'ReportsLoaded{period: $currentPeriod, tab: $currentTabIndex, revenue: ${summary.totalRevenue}}';
  }
}

// Period changed state
class ReportPeriodChanged extends ReportState {
  final ReportPeriod newPeriod;
  final DateRange dateRange;
  
  ReportPeriodChanged({
    required this.newPeriod,
    required this.dateRange,
  });
}

// Report exported successfully
class ReportExported extends ReportState {
  final String filePath;
  final ReportType reportType;
  final String format;
  
  ReportExported({
    required this.filePath,
    required this.reportType,
    required this.format,
  });
}

// Error state
class ReportError extends ReportState {
  final String message;
  final String? errorCode;
  
  ReportError({
    required this.message,
    this.errorCode,
  });

  @override
  String toString() {
    return 'ReportError{message: $message, errorCode: $errorCode}';
  }
}

// Loading specific report type
class ReportTypeLoading extends ReportState {
  final ReportType reportType;
  
  ReportTypeLoading(this.reportType);
}

// No data available for the selected period
class ReportNoData extends ReportState {
  final ReportPeriod period;
  final String message;
  
  ReportNoData({
    required this.period,
    required this.message,
  });

  @override
  String toString() {
    return 'ReportNoData{period: $period, message: $message}';
  }
} 