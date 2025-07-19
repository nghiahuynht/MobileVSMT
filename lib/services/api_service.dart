import 'package:trash_pay/constants/api_config.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/services/network_service.dart';

/// Service class that provides easy access to network operations
/// This is a wrapper around DioNetwork to provide a simpler interface
class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;
  
  final DioNetwork _networkService = DioNetwork.instance;
  
  ApiService._internal();
  
  /// Initialize the API service with environment configuration
  void initialize() {
    // The base URL is already set in DioNetwork constructor via ApiConfig
    // This method can be used for any additional initialization if needed
  }
  
  /// Generic GET request
  Future<ApiResultModel<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) {
    return _networkService.get<T>(
      endpoint,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }
  
  /// Generic POST request
  Future<ApiResultModel<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) {
    return _networkService.post<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }
  
  /// Generic PUT request
  Future<ApiResultModel<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) {
    return _networkService.put<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }
  
  /// Generic DELETE request
  Future<ApiResultModel<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) {
    return _networkService.delete<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }
  
  /// Generic PATCH request
  Future<ApiResultModel<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) {
    return _networkService.patch<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }
  
  /// Upload file
  Future<ApiResultModel<T>> upload<T>(
    String endpoint,
    String filePath, {
    String fileKey = 'file',
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) {
    return _networkService.upload<T>(
      endpoint,
      filePath,
      fileKey: fileKey,
      data: data,
      fromJson: fromJson,
    );
  }
  
  /// Download file
  Future<ApiResultModel<String>> download(
    String endpoint,
    String savePath,
  ) {
    return _networkService.download(endpoint, savePath);
  }
  
  /// Helper methods for common API endpoints
  
  // Auth endpoints
  Future<ApiResultModel<T>> login<T>(
    Map<String, dynamic> credentials, {
    T Function(dynamic)? fromJson,
  }) {
    return post<T>(
      ApiConfig.loginEndpoint,
      data: credentials,
      fromJson: fromJson,
    );
  }
  
  Future<ApiResultModel<T>> logout<T>({T Function(dynamic)? fromJson}) {
    return post<T>(
      ApiConfig.logoutEndpoint,
      fromJson: fromJson,
    );
  }
  
  Future<ApiResultModel<T>> refreshToken<T>({T Function(dynamic)? fromJson}) {
    return post<T>(
      ApiConfig.refreshTokenEndpoint,
      fromJson: fromJson,
    );
  }
  
  // Profile endpoints
  Future<ApiResultModel<T>> getProfile<T>({T Function(dynamic)? fromJson}) {
    return get<T>(
      ApiConfig.profileEndpoint,
      fromJson: fromJson,
    );
  }
  
  Future<ApiResultModel<T>> updateProfile<T>(
    Map<String, dynamic> profileData, {
    T Function(dynamic)? fromJson,
  }) {
    return put<T>(
      ApiConfig.profileEndpoint,
      data: profileData,
      fromJson: fromJson,
    );
  }
  
  // Units endpoints
  Future<ApiResultModel<T>> getUnits<T>({T Function(dynamic)? fromJson}) {
    return get<T>(
      ApiConfig.unitsEndpoint,
      fromJson: fromJson,
    );
  }
  
  // Customers endpoints
  Future<ApiResultModel<T>> getCustomers<T>({
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) {
    return get<T>(
      ApiConfig.customersEndpoint,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }
  
  // Orders endpoints
  Future<ApiResultModel<T>> getOrders<T>({
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) {
    return get<T>(
      ApiConfig.ordersEndpoint,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }
  
  Future<ApiResultModel<T>> createOrder<T>(
    Map<String, dynamic> orderData, {
    T Function(dynamic)? fromJson,
  }) {
    return post<T>(
      ApiConfig.ordersEndpoint,
      data: orderData,
      fromJson: fromJson,
    );
  }
  
  // Transactions endpoints
  Future<ApiResultModel<T>> getTransactions<T>({
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) {
    return get<T>(
      ApiConfig.transactionsEndpoint,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }
  
  // Reports endpoints
  Future<ApiResultModel<T>> getReports<T>({
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) {
    return get<T>(
      ApiConfig.reportsEndpoint,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }
  
  // Payments endpoints
  Future<ApiResultModel<T>> processPayment<T>(
    Map<String, dynamic> paymentData, {
    T Function(dynamic)? fromJson,
  }) {
    return post<T>(
      ApiConfig.paymentsEndpoint,
      data: paymentData,
      fromJson: fromJson,
    );
  }
} 