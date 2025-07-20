import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/product/product.dart';

abstract class ProductRepository {
  Future<ApiResultModel<List<ProductModel>>> getProducts({
    Map<String, dynamic>? queryParameters,
  });
  
  Future<ApiResultModel<ProductModel>> getProductById(int id);
  
  Future<ApiResultModel<List<ProductModel>>> searchProducts(String query);
} 