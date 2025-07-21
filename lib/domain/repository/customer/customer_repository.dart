import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/common/pagination_wrapper_responsive.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';

abstract class CustomerRepository {
  /// Get paginated list of customers with search capability
  Future<ApiResultModel<PaginationWrapperResponsive<CustomerModel>>> getCustomerPaging({
    required int pageIndex,
    required int pageSize,
    String searchString = '',
  });

  /// Get single customer by ID
  Future<ApiResultModel<CustomerModel>> getCustomerById(int id);

  /// Add new customer
  Future<ApiResultModel<CustomerModel>> addCustomer(CustomerModel customer);

  /// Update existing customer
  Future<ApiResultModel<CustomerModel>> updateCustomer(CustomerModel customer);

  /// Delete customer
  Future<ApiResultModel<bool>> deleteCustomer(int id);
}

