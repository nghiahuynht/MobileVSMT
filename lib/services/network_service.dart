import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:trash_pay/constants/api_config.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/based_api_result/error_result_model.dart';
import 'package:trash_pay/services/token_manager.dart';
import 'package:trash_pay/utils/dio/dio_error_util.dart';
import 'package:trash_pay/utils/dio/dio_retry_interceptor.dart';

class DioNetwork {
  static DioNetwork? _instance;
  static DioNetwork get instance => _instance ??= DioNetwork._internal();

  late Dio dio;
  final Logger _logger = Logger();

  DioNetwork._internal() {
    dio = Dio();
    _setupDio();
  }

  void _setupDio() {
    // Base configuration using ApiConfig
    dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: _getDefaultHeaders(),
    );

    // Add interceptors
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        options: RetryOptions(
          retries: ApiConfig.maxRetries,
          retryInterval: ApiConfig.retryInterval,
        ),
      ),
    );

    // Add logging interceptor in debug mode
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => _logger.d(obj),
      ),
    );

    // Add auth interceptor
    dio.interceptors.add(_AuthInterceptor());
  }

  Map<String, String> _getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Platform': Platform.isAndroid ? 'android' : 'ios',
    };
  }

  void setBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }

  void setAuthToken(String? token) {
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }

  void addHeader(String key, String value) {
    dio.options.headers[key] = value;
  }

  void removeHeader(String key) {
    dio.options.headers.remove(key);
  }

  // GET method
  Future<ApiResultModel<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST method
  Future<ApiResultModel<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT method
  Future<ApiResultModel<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // DELETE method
  Future<ApiResultModel<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PATCH method
  Future<ApiResultModel<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Upload file
  Future<ApiResultModel<T>> upload<T>(
    String path,
    String filePath, {
    String fileKey = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });

      final response = await dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Download file
  Future<ApiResultModel<String>> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      return const ApiResultModel.success(data: 'Download completed');
    } catch (e) {
      return _handleError<String>(e);
    }
  }

  ApiResultModel<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (fromJson != null) {
          final data = fromJson(response.data);
          return ApiResultModel.success(data: data);
        } else {
          return ApiResultModel.success(data: response.data as T);
        }
      } else {
        return ApiResultModel.failure(
          errorResultEntity: ErrorResultModel(
            statusCode: response.statusCode ?? 0,
            message: response.statusMessage ?? 'Unknown error',
          ),
        );
      }
    } catch (e) {
      _logger.e('Error parsing response: $e');
      return ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(
          statusCode: 0,
          message: 'Error parsing response: $e',
        ),
      );
    }
  }

  ApiResultModel<T> _handleError<T>(dynamic error) {
    String errorMessage = 'Unknown error occurred';
    int statusCode = 0;

    if (error is DioException) {
      errorMessage = DioExceptionUtil.handleError(error);
      statusCode = error.response?.statusCode ?? 0;

      _logger.e('DioException: $errorMessage', error: error);
    } else {
      errorMessage = error.toString();
      _logger.e('General error: $errorMessage', error: error);
    }

    return ApiResultModel.failure(
      errorResultEntity: ErrorResultModel(
        statusCode: statusCode,
        message: errorMessage,
      ),
    );
  }
}

// Auth interceptor to handle token refresh
class _AuthInterceptor extends Interceptor {

  _AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add auth token to all requests
    final token = TokenManager.instance.currentToken;
    if (token != null) {
      options.headers['Authorization'] = token.authorizationHeader;
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle token refresh logic here
      // You can implement token refresh mechanism
      // For now, just continue with the error
    }
    handler.next(err);
  }
}
