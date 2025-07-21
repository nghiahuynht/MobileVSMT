class ApiConfig {
  // Demo mode - set to false when using real API
  static const bool isDemoMode = false;
  
  // Base URLs for different environments
  static const String _baseUrlProduction = 'https://api.trashpay.com/api/v1';
  static const String _baseUrlStaging = 'https://staging-api.trashpay.com/api/v1';
  static const String _baseUrlDevelopment = 'https://dev-api.trashpay.com/api/v1';
  static const String _baseUrlLocal = 'http://localhost:3000/api/v1';
  
  // Current environment
  static const Environment environment = Environment.development;
  
  // Get base URL based on environment
  static String get baseUrl {

    return 'https://vsmt-api.gamanjsc.com/api';

    // switch (environment) {
    //   case Environment.production:
    //     return _baseUrlProduction;
    //   case Environment.staging:
    //     return _baseUrlStaging;
    //   case Environment.development:
    //     return _baseUrlDevelopment;
    //   case Environment.local:
    //     return _baseUrlLocal;
    // }
  }
  
  // API Endpoints
  static const String userEndpoint = '/User';
  static const String loginEndpoint = '$userEndpoint/Login';
  static const String profileEndpoint = '$userEndpoint/GetAccountInfo';

  static const String saleOrderEndpoint = '/SaleOrder';
  static const String getSaleOrderPaging = '$saleOrderEndpoint/GetSaleOrderPaging';
  static const String getSaleOrderById = '$saleOrderEndpoint/GetSaleOrderById';

  static const String customerEndpoint = '/Customer';
  static const String getCustomerPaging = '$customerEndpoint/GetCustomerPaging';

  static const String metaData = '/MetaData';
  static const String unitsEndpoint = '$metaData/GetAllCompany';
  static const String productsEndpoint = '$metaData/GetAllProduct';
  static const String customersEndpoint = '/customers';
  static const String ordersEndpoint = '/orders';
  static const String transactionsEndpoint = '/transactions';
  static const String reportsEndpoint = '/reports';
  static const String paymentsEndpoint = '/payments';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryInterval = Duration(seconds: 1);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

enum Environment {
  development,
  staging,
  production,
  local,
} 