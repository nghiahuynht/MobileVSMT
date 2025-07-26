import 'dart:convert';

import 'package:trash_pay/constants/api_config.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/common/pagination_wrapper_responsive.dart';
import 'package:trash_pay/domain/entities/order/order.dart';
import 'package:trash_pay/domain/repository/order/order_repository.dart';
import 'package:trash_pay/services/api_service.dart';
import 'package:trash_pay/utils/extension.dart';

class OrderRepositoryImpl implements OrderRepository {
  final ApiService _apiService = ApiService.instance;

  @override
  Future<PaginationWrapperResponsive<OrderModel>> getSaleOrders({
    int pageIndex = 1,
    int pageSize = 10,
    int dateType = 1,
    String searchString = "",
    DateTime? fromDate,
    DateTime? toDate,
    String? routeSaleCode,
    String? areaSaleCode,
    String? saleUserCode,
  }) async {
    try {
      final result =
          await _apiService.post<PaginationWrapperResponsive<OrderModel>>(
        ApiConfig.getSaleOrderPaging,
        data: {
          "pageIndex": pageIndex,
          "pageSize": pageSize,
          "searchString": searchString,
          if (fromDate != null || toDate != null) "dateType": dateType,
          if (fromDate != null) "fromDate": fromDate.getDateString(),
          if (toDate != null) "toDate": toDate.getDateString(),
          if (routeSaleCode != null) "routeSaleCode": routeSaleCode,
          if (areaSaleCode != null) "areaSaleCode": areaSaleCode,
          if (saleUserCode != null) "saleUserCode": saleUserCode,
        },
        fromJson: (json) {
          return PaginationWrapperResponsive.fromJson(
            json as String,
            fromMapT: (data) => OrderModel.fromMap(data),
            pageIndex: pageIndex,
            pageSize: pageSize,
          );
        },
      );
      if (result is Success<PaginationWrapperResponsive<OrderModel>>) {
        return result.data;
      } else if (result is Failure<PaginationWrapperResponsive<OrderModel>>) {
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<OrderModel> getOrderById(int id) async {
    try {
      final result = await _apiService.post<OrderModel>(
        ApiConfig.getSaleOrderById,
        queryParameters: {
          "id": id,
        },
        fromJson: (json) {
          return OrderModel.fromJson(
            json as String,
          );
        },
      );
      if (result is Success<OrderModel>) {
        return result.data;
      } else if (result is Failure<OrderModel>) {
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    try {
      final result = await _apiService.post<bool>(
        ApiConfig.insertSaleOrder,
        data: orderData,
        fromJson: (json) => jsonDecode(json)['isSuccess'],
      );
      if (result is Success<bool>) {
        return result.data;
      } else if (result is Failure<bool>) {
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
