import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/based_api_result/error_result_model.dart';
import 'package:trash_pay/domain/entities/product/product.dart';
import 'package:trash_pay/services/api_service.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiService _apiService = ApiService.instance;

  @override
  Future<ApiResultModel<List<ProductModel>>> getProducts({
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final result = await _apiService.getProducts<List<dynamic>>(
        queryParameters: queryParameters,
        fromJson: (json) => json as List<dynamic>,
      );

      if (result is Success<List<dynamic>>) {
        final products = result.data
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
        
        return ApiResultModel.success(data: products);
      } else if (result is Failure<List<dynamic>>) {
        return ApiResultModel.failure(
          errorResultEntity: result.errorResultEntity,
        );
      } else {
        return ApiResultModel.failure(
          errorResultEntity: const ErrorResultModel(
            message: 'Failed to load products',
          ),
        );
      }
    } catch (e) {
      return ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(
          message: 'Error loading products: $e',
        ),
      );
    }
  }

  @override
  Future<ApiResultModel<ProductModel>> getProductById(int id) async {
    try {
      final result = await _apiService.getProducts<Map<String, dynamic>>(
        queryParameters: {'id': id},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (result is Success<Map<String, dynamic>>) {
        final product = ProductModel.fromJson(result.data);
        return ApiResultModel.success(data: product);
      } else if (result is Failure<Map<String, dynamic>>) {
        return ApiResultModel.failure(
          errorResultEntity: result.errorResultEntity,
        );
      } else {
        return ApiResultModel.failure(
          errorResultEntity: const ErrorResultModel(
            message: 'Failed to load product',
          ),
        );
      }
    } catch (e) {
      return ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(
          message: 'Error loading product: $e',
        ),
      );
    }
  }

  @override
  Future<ApiResultModel<List<ProductModel>>> searchProducts(String query) async {
    try {
      final result = await _apiService.getProducts<List<dynamic>>(
        queryParameters: {'search': query},
        fromJson: (json) => json as List<dynamic>,
      );

      if (result is Success<List<dynamic>>) {
        final products = result.data
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
        
        return ApiResultModel.success(data: products);
      } else if (result is Failure<List<dynamic>>) {
        return ApiResultModel.failure(
          errorResultEntity: result.errorResultEntity,
        );
      } else {
        return ApiResultModel.failure(
          errorResultEntity: const ErrorResultModel(
            message: 'Failed to search products',
          ),
        );
      }
    } catch (e) {
      return ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(
          message: 'Error searching products: $e',
        ),
      );
    }
  }
} 