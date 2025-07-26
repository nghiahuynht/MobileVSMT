abstract class ReportEvent {}

// Load initial reports data
class LoadReportsEvent extends ReportEvent {
  final int year;

  LoadReportsEvent({required this.year});
}

// Load specific report type
class LoadReportTypeEvent extends ReportEvent {
  final ReportType reportType;

  LoadReportTypeEvent(this.reportType);
}

// Filter reports by date range
class FilterReportsByDateEvent extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  FilterReportsByDateEvent({
    required this.startDate,
    required this.endDate,
  });
}

// Export report data
class ExportReportEvent extends ReportEvent {
  final ReportType reportType;
  final String format; // 'pdf', 'excel', 'csv'

  ExportReportEvent({
    required this.reportType,
    required this.format,
  });
}

// Switch between report tabs
class SwitchReportTabEvent extends ReportEvent {
  final int tabIndex;

  SwitchReportTabEvent(this.tabIndex);
}

enum ReportType {
  overview,
  revenue,
  customers,
  products,
}
