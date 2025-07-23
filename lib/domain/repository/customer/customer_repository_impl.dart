import 'package:trash_pay/constants/api_config.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/based_api_result/error_result_model.dart';
import 'package:trash_pay/domain/entities/common/pagination_wrapper_responsive.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/repository/customer/customer_repository.dart';
import 'package:trash_pay/services/api_service.dart';

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
  Future<ApiResultModel<CustomerModel>> addCustomer(CustomerModel customer) async {
    try {
      final result = await _apiService.post<CustomerModel>(
        ApiConfig.insertOrUpdateCustomer,
        data: customer.toMap(isCreate: true),
        fromJson: (json) => CustomerModel.fromJson(json),
      );

      return result;
    } catch (e) {
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
      return ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(
          message: 'Failed to update customer: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<ApiResultModel<bool>> deleteCustomer(int id) async {
    try {
      final result = await _apiService.delete<bool>(
        '${ApiConfig.customerEndpoint}/$id',
        fromJson: (json) => json as bool,
      );

      return result;
    } catch (e) {
      return ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(
          message: 'Failed to delete customer: ${e.toString()}',
        ),
      );
    }
  }
}
