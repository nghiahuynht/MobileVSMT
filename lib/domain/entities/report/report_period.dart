enum ReportPeriod {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisQuarter,
  lastQuarter,
  thisYear,
  lastYear,
  custom,
}

extension ReportPeriodExtension on ReportPeriod {
  String get displayName {
    switch (this) {
      case ReportPeriod.today:
        return 'Hôm nay';
      case ReportPeriod.yesterday:
        return 'Hôm qua';
      case ReportPeriod.thisWeek:
        return 'Tuần này';
      case ReportPeriod.lastWeek:
        return 'Tuần trước';
      case ReportPeriod.thisMonth:
        return 'Tháng này';
      case ReportPeriod.lastMonth:
        return 'Tháng trước';
      case ReportPeriod.thisQuarter:
        return 'Quý này';
      case ReportPeriod.lastQuarter:
        return 'Quý trước';
      case ReportPeriod.thisYear:
        return 'Năm này';
      case ReportPeriod.lastYear:
        return 'Năm trước';
      case ReportPeriod.custom:
        return 'Tùy chọn';
    }
  }

  DateRange get dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (this) {
      case ReportPeriod.today:
        return DateRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
      case ReportPeriod.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return DateRange(
          start: yesterday,
          end: today,
        );
      case ReportPeriod.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return DateRange(
          start: startOfWeek,
          end: startOfWeek.add(const Duration(days: 7)),
        );
      case ReportPeriod.lastWeek:
        final startOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
        final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
        return DateRange(
          start: startOfLastWeek,
          end: startOfThisWeek,
        );
      case ReportPeriod.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
        return DateRange(
          start: startOfMonth,
          end: startOfNextMonth,
        );
      case ReportPeriod.lastMonth:
        final startOfThisMonth = DateTime(now.year, now.month, 1);
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        return DateRange(
          start: startOfLastMonth,
          end: startOfThisMonth,
        );
      case ReportPeriod.thisQuarter:
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        final startOfQuarter = DateTime(now.year, quarterStartMonth, 1);
        final startOfNextQuarter = DateTime(now.year, quarterStartMonth + 3, 1);
        return DateRange(
          start: startOfQuarter,
          end: startOfNextQuarter,
        );
      case ReportPeriod.lastQuarter:
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        final startOfThisQuarter = DateTime(now.year, quarterStartMonth, 1);
        final startOfLastQuarter = DateTime(now.year, quarterStartMonth - 3, 1);
        return DateRange(
          start: startOfLastQuarter,
          end: startOfThisQuarter,
        );
      case ReportPeriod.thisYear:
        final startOfYear = DateTime(now.year, 1, 1);
        final startOfNextYear = DateTime(now.year + 1, 1, 1);
        return DateRange(
          start: startOfYear,
          end: startOfNextYear,
        );
      case ReportPeriod.lastYear:
        final startOfThisYear = DateTime(now.year, 1, 1);
        final startOfLastYear = DateTime(now.year - 1, 1, 1);
        return DateRange(
          start: startOfLastYear,
          end: startOfThisYear,
        );
      case ReportPeriod.custom:
        return DateRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
    }
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);
  
  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end);
  }

  @override
  String toString() {
    return 'DateRange{start: $start, end: $end}';
  }
} 