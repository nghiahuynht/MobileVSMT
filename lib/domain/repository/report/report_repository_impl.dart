import 'dart:convert';

import 'package:trash_pay/constants/api_config.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/report/monthly_revenue.dart';
import 'package:trash_pay/domain/repository/report/report_repository.dart';
import 'package:trash_pay/services/api_service.dart';

class ReportRepositoryImpl extends ReportRepository {
  final ApiService _apiService = ApiService.instance;

  @override
  Future<List<MonthlyRevenue>> getMonthlyRevenue(
      {required int year, required String saleUserCode}) async {
    try {
      final result = await _apiService.post<List<MonthlyRevenue>>(
        ApiConfig.getMonthlyRevenue,
        data: {
          'year': year,
          'saleUserCode': saleUserCode,
        },
        fromJson: (p0) {
          final data = jsonDecode(p0)['data'];

          return (data as List)
              .map((item) =>
                  MonthlyRevenue.fromMonthMap(item as Map<String, dynamic>))
              .toList();
        },
      );

      if (result is Success<List<MonthlyRevenue>>) {
        return result.data;
      } else if (result is Failure<List<MonthlyRevenue>>) {
        throw result.errorResultEntity.message ?? '';
      } else {
        throw 'Failed to load products';
      }
    } catch (e) {
      throw 'Error loading products: $e';
    }
  }

  @override
  Future<List<MonthlyRevenue>> getMonthlyRevenueDetail({
    required int year,
    required String saleUserCode,
    required int month,
  }) async {
    try {
      final result = await _apiService.post<List<MonthlyRevenue>>(
        ApiConfig.getMonthlyRevenueDetail,
        data: {
          'year': year,
          'saleUserCode': saleUserCode,
          'month': month,
        },
        fromJson: (p0) {
          final data = jsonDecode(p0)['data'];

          return (data as List)
              .map((item) =>
                  MonthlyRevenue.fromMonthMap(item as Map<String, dynamic>))
              .toList();
        },
      );

      if (result is Success<List<MonthlyRevenue>>) {
        return result.data;
      } else if (result is Failure<List<MonthlyRevenue>>) {
        throw result.errorResultEntity.message ?? '';
      } else {
        throw 'Failed to load products';
      }
    } catch (e) {
      throw 'Error loading products: $e';
    }
  }
}
