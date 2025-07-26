import 'package:trash_pay/domain/entities/report/monthly_revenue.dart';

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
  final int year;
  final List<MonthlyRevenue> data;

  ReportsLoaded({
    required this.year,
    this.data = const [],
  });

  ReportsLoaded copyWith({
    int? year,
    DateRange? dateRange,
    ReportSummary? summary,
    RevenueReport? revenueReport,
    CustomerReport? customerReport,
    ProductReport? productReport,
    int? currentTabIndex,
    bool? isRefreshing,
    DateTime? lastUpdated,
    List<MonthlyRevenue>? data,
  }) {
    return ReportsLoaded(
      year: year ?? this.year,
      data: data ?? this.data,
    );
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
