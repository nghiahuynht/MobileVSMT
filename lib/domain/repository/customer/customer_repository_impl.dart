import 'dart:convert';

import 'package:trash_pay/constants/api_config.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/based_api_result/error_result_model.dart';
import 'package:trash_pay/domain/entities/common/pagination_wrapper_responsive.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/repository/customer/customer_repository.dart';
import 'package:trash_pay/services/api_service.dart';
import 'package:trash_pay/services/app_messenger.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final ApiService _apiService = ApiService.instance;

  @override
  Future<ApiResultModel<PaginationWrapperResponsive<CustomerModel>>> getCustomerPaging({
    required int pageIndex,
    required int pageSize,
    String searchString = '',
    String? areaSaleCode,
    String? routeSaleCode,
    String? saleUserCode,
  }) async {
    try {
      final requestBody = {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        'searchString': searchString,
        if (areaSaleCode != null) 'areaSaleCode': areaSaleCode,
        if (routeSaleCode != null) 'routeSaleCode': routeSaleCode,
        if (saleUserCode != null) 'saleUserCode': saleUserCode,
      };

      final result = await _apiService.post<PaginationWrapperResponsive<CustomerModel>>(
        ApiConfig.getCustomerPaging,
        data: requestBody,
        fromJson: (json) => PaginationWrapperResponsive<CustomerModel>.fromJson(
          json,
          fromMapT: (itemJson) => CustomerModel.fromMap(itemJson),
          pageIndex: pageIndex,
          pageSize: pageSize,
        ),
      );

      return result;
    } catch (e) {
      return ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(
          message: 'Failed to load customers: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<ApiResultModel<CustomerModel>> getCustomerById(int id) async {
    try {
      final result = await _apiService.get<CustomerModel>(
        '${ApiConfig.customerEndpoint}/$id',
        fromJson: (json) => CustomerModel.fromMap(json),
      );

      return result;
    } catch (e) {
      return ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(
          message: 'Failed to load customer: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<ApiResultModel<bool>> addCustomer(CustomerModel customer, {bool isEdit = false}) async {
    try {
      final result = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.insertOrUpdateCustomer,
        data: customer.toMap(isCreate: !isEdit),
        fromJson: (json) => jsonDecode(json),
      );

      if (result is Success<Map<String, dynamic>>) {
        final data = result.data;
        if (data['isSuccess'] == true) {
          return const ApiResultModel.success(data: true);
        } else {
          AppMessenger.showError(data['message']?.toString());
          return ApiResultModel.failure(
            errorResultEntity: ErrorResultModel(
              message: data['message']?.toString() ?? 'Thao tác thất bại',
            ),
          );
        }
      } else if (result is Failure<Map<String, dynamic>>) {
        AppMessenger.showError(result.errorResultEntity.message);
        return ApiResultModel.failure(
          errorResultEntity: result.errorResultEntity,
        );
      } else {
        return ApiResultModel.failure(
          errorResultEntity: const ErrorResultModel(
            message: 'Unexpected result type',
          ),
        );
      }
    } catch (e) {
      AppMessenger.showError(e.toString());
      return ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(
          message: 'Failed to add customer: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<ApiResultModel<CustomerModel>> updateCustomer(CustomerModel customer) async {
    try {
      final result = await _apiService.put<CustomerModel>(
        '${ApiConfig.customerEndpoint}/${customer.id}',
        data: customer.toMap(),
        fromJson: (json) => CustomerModel.fromMap(json),
      );

      return result;
    } catch (e) {
      AppMessenger.showError(e.toString());
      return ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(
          message: 'Failed to update customer: ${e.toString()}',
        ),
      );
    }
  }
}
