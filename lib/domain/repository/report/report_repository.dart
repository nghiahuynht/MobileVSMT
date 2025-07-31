import 'package:trash_pay/domain/entities/report/monthly_revenue.dart';

abstract class ReportRepository {
  Future<List<MonthlyRevenue>> getMonthlyRevenue({
    required int year,
    required String saleUserCode,
  });

    Future<List<MonthlyRevenue>> getMonthlyRevenueDetail({
    required int year,
    required String saleUserCode,
    required int month,
  });
}